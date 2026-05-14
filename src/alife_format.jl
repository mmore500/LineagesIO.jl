const ALIFE_ID_COLUMN = :id
const ALIFE_ANCESTOR_LIST_COLUMN = :ancestor_list
const ALIFE_ANCESTOR_ID_COLUMN = :ancestor_id

"""
Sentinel marker stored in the `parents` column of an `AlifeTreeColumns` to
indicate a basenode entry (no parent). Alife `id` values are validated as
non-negative, so `-1` is unambiguous.
"""
const ALIFE_NO_PARENT_ID = -1

"""
Column-oriented snapshot of an alife source after parsing. `parents` is the
per-row ancestor representation: `Vector{Vector{Int}}` for `ancestor_list`
sources (DAG-capable) or `Vector{Int}` for `ancestor_id` sources (strict tree;
`ALIFE_NO_PARENT_ID` marks a basenode). `annotation_columns` is aligned with
`annotation_names`.
"""
struct AlifeColumns{ParentsT}
    n::Int
    ids::Vector{Int}
    parents::ParentsT
    annotation_names::Vector{Symbol}
    annotation_columns::Vector{Vector{OptionalString}}
end

const AlifeNetworkColumns = AlifeColumns{Vector{Vector{Int}}}
const AlifeTreeColumns = AlifeColumns{Vector{Int}}

function build_alife_store(
        text::String,
        source_path::OptionalString;
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::LineageGraphStore
    return build_alife_store(
        text, source_path, TablesOnlyLoadRequest();
        allow_forest = allow_forest,
        assume_topological_ordering = assume_topological_ordering,
        normalize_annotation_values = normalize_annotation_values,
    )
end

function build_alife_store(
        text::String,
        source_path::OptionalString,
        request::AbstractLoadRequest;
        allow_forest::Bool,
        assume_topological_ordering::Bool,
        normalize_annotation_values::Bool,
    )::LineageGraphStore
    columns = parse_alife_text_source(
        text, source_path; normalize_annotation_values = normalize_annotation_values,
    )
    return build_alife_store_from_columns(
        columns, source_path, request;
        allow_forest = allow_forest,
        assume_topological_ordering = assume_topological_ordering,
    )
end

function build_alife_store_from_table(
        table,
        source_path::OptionalString,
        request::AbstractLoadRequest;
        allow_forest::Bool,
        assume_topological_ordering::Bool,
        normalize_annotation_values::Bool,
    )::LineageGraphStore
    columns = parse_alife_columnar_table(
        table, source_path; normalize_annotation_values = normalize_annotation_values,
    )
    return build_alife_store_from_columns(
        columns, source_path, request;
        allow_forest = allow_forest,
        assume_topological_ordering = assume_topological_ordering,
    )
end

function build_alife_store_from_columns(
        columns::AlifeColumns,
        source_path::OptionalString,
        request::AbstractLoadRequest;
        allow_forest::Bool,
        assume_topological_ordering::Bool,
    )::LineageGraphStore
    maybe_warn_about_origin_time_column(columns, source_path)
    row_index_by_id = build_row_index_by_id(columns)
    basenode_row_indices = find_basenode_row_indices(columns)
    assert_basenode_count(length(basenode_row_indices), allow_forest, source_path)
    components = if assume_topological_ordering
        @assert input_is_topologically_ordered(columns, row_index_by_id) format_alife_error(
            source_path,
            "alife source is not in topological row order (an ancestor entry appears at or after one of its descendants), but `assume_topological_ordering = true` was passed; drop the flag to let LineagesIO reorder rows automatically.",
        )
        partition_components_input_order(columns, row_index_by_id)
    else
        partition_components_bfs(columns, row_index_by_id, basenode_row_indices, source_path)
    end
    graph_assets = LineageGraphAsset[
        build_alife_graph_asset(columns, component_row_indices, graph_index, source_path)
            for (graph_index, component_row_indices) in enumerate(components)
    ]
    graph_assets = materialize_graphs(graph_assets, request)
    return assemble_alife_lineage_graph_store(graph_assets, source_path)
end

function maybe_warn_about_origin_time_column(
        columns::AlifeColumns, source_path::OptionalString,
    )::Nothing
    :origin_time in columns.annotation_names || return nothing
    source_label = source_path === nothing ? "<input>" : source_path
    @warn string(
        "alife source `",
        source_label,
        "` declares an `origin_time` annotation column, but LineagesIO does not yet derive `edgeweight` from it; the column is retained as a node annotation only.",
    )
    return nothing
end

function build_row_index_by_id(columns::AlifeColumns)::Dict{Int, Int}
    row_index_by_id = Dict{Int, Int}()
    for i in 1:columns.n
        row_index_by_id[columns.ids[i]] = i
    end
    return row_index_by_id
end

function find_basenode_row_indices(columns::AlifeColumns)::Vector{Int}
    basenode_row_indices = Int[]
    for i in 1:columns.n
        is_basenode_row(columns, i) && push!(basenode_row_indices, i)
    end
    return basenode_row_indices
end

is_basenode_row(columns::AlifeNetworkColumns, i::Int)::Bool = isempty(columns.parents[i])
is_basenode_row(columns::AlifeTreeColumns, i::Int)::Bool = columns.parents[i] == ALIFE_NO_PARENT_ID

n_parents_at_row(columns::AlifeNetworkColumns, i::Int)::Int = length(columns.parents[i])
n_parents_at_row(columns::AlifeTreeColumns, i::Int)::Int =
    columns.parents[i] == ALIFE_NO_PARENT_ID ? 0 : 1

parent_ids_at_row(columns::AlifeNetworkColumns, i::Int) = columns.parents[i]
function parent_ids_at_row(columns::AlifeTreeColumns, i::Int)
    parent_id = columns.parents[i]
    range = parent_id == ALIFE_NO_PARENT_ID ? (i:(i - 1)) : (i:i)
    return view(columns.parents, range)
end

first_parent_id(columns::AlifeNetworkColumns, i::Int)::Int = columns.parents[i][1]
first_parent_id(columns::AlifeTreeColumns, i::Int)::Int = columns.parents[i]

function input_is_topologically_ordered(
        columns::AlifeColumns, row_index_by_id::Dict{Int, Int},
    )::Bool
    for i in 1:columns.n
        for parent_id in parent_ids_at_row(columns, i)
            row_index_by_id[parent_id] < i || return false
        end
    end
    return true
end

function partition_components_input_order(
        columns::AlifeColumns, row_index_by_id::Dict{Int, Int},
    )::Vector{Vector{Int}}
    component_of_row = Vector{Int}(undef, columns.n)
    components = Vector{Vector{Int}}()
    for i in 1:columns.n
        if is_basenode_row(columns, i)
            push!(components, Int[i])
            component_of_row[i] = length(components)
        else
            component_id = component_of_row[row_index_by_id[first_parent_id(columns, i)]]
            component_of_row[i] = component_id
            push!(components[component_id], i)
        end
    end
    return components
end

function assert_basenode_count(
        n_basenodes::Int, allow_forest::Bool, source_path::OptionalString,
    )::Nothing
    (allow_forest || n_basenodes == 1) && return nothing
    throw(alife_error(source_path, "alife source declares $(n_basenodes) basenode entries (with `[NONE]`/empty `ancestor_list` or self-referencing `ancestor_id`), but `allow_forest = false`; pass `allow_forest = true` to load multi-basenode sources as a forest of separate graphs."))
end

function assemble_alife_lineage_graph_store(
        graph_assets::AbstractVector{<:LineageGraphAsset},
        source_path::OptionalString,
    )::LineageGraphStore
    graph_count = length(graph_assets)
    source_table = SourceTable(
        source_idx = [1],
        source_path = [source_path],
        collection_count = [1],
        graph_count = [graph_count],
    )
    collection_table = CollectionTable(
        collection_idx = [1],
        source_idx = [1],
        collection_label = [nothing],
        graph_count = [graph_count],
    )
    graph_table = GraphTable(
        index = [a.index for a in graph_assets],
        source_idx = [a.source_idx for a in graph_assets],
        collection_idx = [a.collection_idx for a in graph_assets],
        collection_graph_idx = [a.collection_graph_idx for a in graph_assets],
        collection_label = [a.collection_label for a in graph_assets],
        graph_label = [a.graph_label for a in graph_assets],
        node_count = [lineagetable_nrows(a.node_table) for a in graph_assets],
        edge_count = [lineagetable_nrows(a.edge_table) for a in graph_assets],
    )
    return LineageGraphStore(
        source_table, collection_table, graph_table, GraphAssetIterator(graph_assets),
    )
end

function parse_alife_text_source(
        text::AbstractString,
        source_path::OptionalString;
        normalize_annotation_values::Bool = false,
    )::Union{AlifeNetworkColumns, AlifeTreeColumns}
    isempty(strip(text)) && throw(alife_error(source_path, "alife sources must contain at least one header row."))
    delimited_result = try
        DelimitedFiles.readdlm(IOBuffer(String(text)), ',', String; quotes = true)
    catch err
        throw(alife_error(source_path, "could not parse delimited input: $(sprint(showerror, err))"))
    end
    delimited_result isa AbstractMatrix || throw(alife_error(source_path, "DelimitedFiles returned an unexpected non-matrix result; this is a LineagesIO bug."))
    raw_matrix = delimited_result
    matrix_rows = size(raw_matrix, 1)
    matrix_rows >= 1 || throw(alife_error(source_path, "alife sources must contain at least one header row."))
    matrix_cols = size(raw_matrix, 2)
    header = Symbol[Symbol(strip(raw_matrix[1, column_index])) for column_index in 1:matrix_cols]
    validate_alife_header(header, source_path)

    kept_record_indices = Int[]
    for record_index in 1:(matrix_rows - 1)
        all_empty = true
        for column_index in 1:matrix_cols
            if !isempty(strip(raw_matrix[record_index + 1, column_index]))
                all_empty = false
                break
            end
        end
        all_empty || push!(kept_record_indices, record_index)
    end
    isempty(kept_record_indices) && throw(alife_error(source_path, "alife sources must contain at least one data row after the header."))

    n = length(kept_record_indices)
    id_column_index = findfirst(==(ALIFE_ID_COLUMN), header)::Int
    ancestor_list_index = findfirst(==(ALIFE_ANCESTOR_LIST_COLUMN), header)
    ancestor_id_index = findfirst(==(ALIFE_ANCESTOR_ID_COLUMN), header)

    ids = Vector{Int}(undef, n)
    seen_ids = Dict{Int, Int}()
    for (i, record_index) in enumerate(kept_record_indices)
        ids[i] = parse_alife_id(
            raw_matrix[record_index + 1, id_column_index], record_index, source_path,
        )
        if haskey(seen_ids, ids[i])
            throw(alife_error(source_path, "duplicate `id=$(ids[i])` at data record $(record_index); previously seen at record $(seen_ids[ids[i]])."))
        end
        seen_ids[ids[i]] = record_index
    end

    ancestor_columns = if ancestor_list_index !== nothing
        parse_ancestor_list_column_from_matrix(
            raw_matrix, kept_record_indices, ids, ancestor_list_index, source_path,
        )
    else
        parse_ancestor_id_column_from_matrix(
            raw_matrix, kept_record_indices, ids, ancestor_id_index::Int, source_path,
        )
    end

    annotation_names = collect_alife_annotation_names(header)
    annotation_columns = Vector{Vector{OptionalString}}(undef, length(annotation_names))
    for (slot_index, annotation_name) in enumerate(annotation_names)
        column_index = findfirst(==(annotation_name), header)::Int
        annotation_column = Vector{OptionalString}(undef, n)
        for (i, record_index) in enumerate(kept_record_indices)
            cell = raw_matrix[record_index + 1, column_index]
            if normalize_annotation_values
                stripped = strip(cell)
                annotation_column[i] = isempty(stripped) ? nothing : String(stripped)
            else
                annotation_column[i] = String(cell)
            end
        end
        annotation_columns[slot_index] = annotation_column
    end

    validate_ancestor_references(ids, ancestor_columns, kept_record_indices, seen_ids, source_path)
    return AlifeColumns(n, ids, ancestor_columns, annotation_names, annotation_columns)
end

function parse_alife_columnar_table(
        table,
        source_path::OptionalString;
        normalize_annotation_values::Bool = false,
    )::Union{AlifeNetworkColumns, AlifeTreeColumns}
    column_table = Tables.columns(table)
    column_name_tuple = Tables.columnnames(column_table)
    header = Symbol[Symbol(name) for name in column_name_tuple]
    validate_alife_header(header, source_path)

    id_column = Tables.getcolumn(column_table, ALIFE_ID_COLUMN)
    ancestor_list_column = ALIFE_ANCESTOR_LIST_COLUMN in header ?
        Tables.getcolumn(column_table, ALIFE_ANCESTOR_LIST_COLUMN) : nothing
    ancestor_id_column = ALIFE_ANCESTOR_ID_COLUMN in header ?
        Tables.getcolumn(column_table, ALIFE_ANCESTOR_ID_COLUMN) : nothing

    n = length(id_column)
    n >= 1 || throw(alife_error(source_path, "alife sources must contain at least one data row."))

    ids = Vector{Int}(undef, n)
    seen_ids = Dict{Int, Int}()
    for i in 1:n
        ids[i] = coerce_alife_id(id_column[i], i, source_path)
        if haskey(seen_ids, ids[i])
            throw(alife_error(source_path, "duplicate `id=$(ids[i])` at data record $(i); previously seen at record $(seen_ids[ids[i]])."))
        end
        seen_ids[ids[i]] = i
    end

    ancestor_columns = if ancestor_list_column !== nothing
        coerce_ancestor_list_column(ancestor_list_column, ids, source_path)
    else
        coerce_ancestor_id_column(
            ancestor_id_column::AbstractVector, ids, source_path,
        )
    end

    annotation_names = collect_alife_annotation_names(header)
    annotation_columns = Vector{Vector{OptionalString}}(undef, length(annotation_names))
    for (slot_index, annotation_name) in enumerate(annotation_names)
        raw_column = Tables.getcolumn(column_table, annotation_name)
        annotation_columns[slot_index] = normalize_annotation_values ?
            normalize_annotation_column_cells(raw_column) :
            stringify_annotation_column_cells(raw_column)
    end

    validate_ancestor_references(ids, ancestor_columns, 1:n, seen_ids, source_path)
    return AlifeColumns(n, ids, ancestor_columns, annotation_names, annotation_columns)
end

function stringify_annotation_column_cells(raw_column)::Vector{OptionalString}
    n = length(raw_column)
    out = Vector{OptionalString}(undef, n)
    for i in 1:n
        value = raw_column[i]
        if value === missing || value === nothing
            out[i] = nothing
        elseif value isa AbstractString
            out[i] = String(value)
        else
            out[i] = string(value)
        end
    end
    return out
end

function coerce_ancestor_list_column(
        ancestor_list_column,
        ids::Vector{Int},
        source_path::OptionalString,
    )::Vector{Vector{Int}}
    n = length(ids)
    out = Vector{Vector{Int}}(undef, n)
    for i in 1:n
        parents = coerce_alife_ancestor_list(ancestor_list_column[i], i, source_path)
        out[i] = Int[parent_id for parent_id in parents if parent_id != ids[i]]
    end
    return out
end

function coerce_ancestor_id_column(
        ancestor_id_column,
        ids::Vector{Int},
        source_path::OptionalString,
    )::Vector{Int}
    n = length(ids)
    out = Vector{Int}(undef, n)
    for i in 1:n
        parent_id = coerce_alife_ancestor_id_scalar(
            ancestor_id_column[i], ids[i], i, source_path,
        )
        out[i] = parent_id == ids[i] ? ALIFE_NO_PARENT_ID : parent_id
    end
    return out
end

function parse_ancestor_list_column_from_matrix(
        raw_matrix::AbstractMatrix,
        kept_record_indices::Vector{Int},
        ids::Vector{Int},
        ancestor_list_index::Int,
        source_path::OptionalString,
    )::Vector{Vector{Int}}
    n = length(kept_record_indices)
    out = Vector{Vector{Int}}(undef, n)
    for (i, record_index) in enumerate(kept_record_indices)
        parents = parse_alife_ancestor_list(
            raw_matrix[record_index + 1, ancestor_list_index], record_index, source_path,
        )
        out[i] = Int[parent_id for parent_id in parents if parent_id != ids[i]]
    end
    return out
end

function parse_ancestor_id_column_from_matrix(
        raw_matrix::AbstractMatrix,
        kept_record_indices::Vector{Int},
        ids::Vector{Int},
        ancestor_id_index::Int,
        source_path::OptionalString,
    )::Vector{Int}
    n = length(kept_record_indices)
    out = Vector{Int}(undef, n)
    for (i, record_index) in enumerate(kept_record_indices)
        parent_id = parse_alife_ancestor_id_scalar(
            raw_matrix[record_index + 1, ancestor_id_index], record_index, source_path,
        )
        out[i] = parent_id == ids[i] ? ALIFE_NO_PARENT_ID : parent_id
    end
    return out
end

function validate_alife_header(header::Vector{Symbol}, source_path::OptionalString)::Nothing
    isempty(header) && throw(alife_error(source_path, "alife header row may not be empty."))
    ALIFE_ID_COLUMN in header || throw(alife_error(source_path, "alife sources must declare a required `id` header column."))
    has_ancestor_list = ALIFE_ANCESTOR_LIST_COLUMN in header
    has_ancestor_id = ALIFE_ANCESTOR_ID_COLUMN in header
    (has_ancestor_list || has_ancestor_id) || throw(alife_error(source_path, "alife sources must declare a required `ancestor_list` or `ancestor_id` header column."))
    seen = Set{Symbol}()
    for column_name in header
        column_name in seen && throw(alife_error(source_path, "duplicate header column `$(column_name)`."))
        push!(seen, column_name)
    end
    return nothing
end

function collect_alife_annotation_names(header::Vector{Symbol})::Vector{Symbol}
    return Symbol[
        column_name for column_name in header
            if column_name != ALIFE_ID_COLUMN &&
                column_name != ALIFE_ANCESTOR_LIST_COLUMN &&
                column_name != ALIFE_ANCESTOR_ID_COLUMN
    ]
end

function validate_ancestor_references(
        ids::Vector{Int},
        ancestor_lists::Vector{Vector{Int}},
        record_indices::AbstractVector{Int},
        seen_ids::Dict{Int, Int},
        source_path::OptionalString,
    )::Nothing
    for (i, parents) in enumerate(ancestor_lists)
        for parent_id in parents
            haskey(seen_ids, parent_id) || throw(alife_error(source_path, "data record $(record_indices[i]) references unknown ancestor `id=$(parent_id)` for `id=$(ids[i])`."))
        end
    end
    return nothing
end

function validate_ancestor_references(
        ids::Vector{Int},
        parent_ids::Vector{Int},
        record_indices::AbstractVector{Int},
        seen_ids::Dict{Int, Int},
        source_path::OptionalString,
    )::Nothing
    for i in 1:length(parent_ids)
        parent_id = parent_ids[i]
        parent_id == ALIFE_NO_PARENT_ID && continue
        haskey(seen_ids, parent_id) || throw(alife_error(source_path, "data record $(record_indices[i]) references unknown ancestor `id=$(parent_id)` for `id=$(ids[i])`."))
    end
    return nothing
end

function parse_alife_id(
        field::AbstractString, record_index::Int, source_path::OptionalString,
    )::Int
    token = strip(field)
    isempty(token) && throw(alife_error(source_path, "data record $(record_index) is missing the required `id` value."))
    parsed_id = try
        parse(Int, token)
    catch
        throw(alife_error(source_path, "data record $(record_index) has a non-integer `id` value `$(token)`."))
    end
    parsed_id < 0 && throw(alife_error(source_path, "data record $(record_index) has a negative `id` value `$(parsed_id)`; alife `id` values must be non-negative."))
    return parsed_id
end

function parse_alife_ancestor_list(
        field::AbstractString, record_index::Int, source_path::OptionalString,
    )::Vector{Int}
    token = strip(field)
    isempty(token) && return Int[]
    (startswith(token, '[') && endswith(token, ']')) || throw(alife_error(source_path, "data record $(record_index) has a malformed `ancestor_list` `$(token)`; alife `ancestor_list` values must be bracketed `[...]`."))
    inner = strip(SubString(token, nextind(token, firstindex(token)), prevind(token, lastindex(token))))
    isempty(inner) && return Int[]
    uppercase(String(inner)) == "NONE" && return Int[]

    ancestor_ids = Int[]
    for raw_token in split(inner, ',')
        ancestor_token = strip(raw_token)
        isempty(ancestor_token) && continue
        if uppercase(String(ancestor_token)) == "NONE"
            throw(alife_error(source_path, "data record $(record_index) lists `NONE` alongside other ancestors; `NONE` must be the sole `ancestor_list` token for basenode entries."))
        end
        parsed_ancestor_id = try
            parse(Int, ancestor_token)
        catch
            throw(alife_error(source_path, "data record $(record_index) has a non-integer `ancestor_list` token `$(ancestor_token)`."))
        end
        parsed_ancestor_id < 0 && throw(alife_error(source_path, "data record $(record_index) has a negative `ancestor_list` token `$(parsed_ancestor_id)`; alife `id` values must be non-negative."))
        push!(ancestor_ids, parsed_ancestor_id)
    end
    return ancestor_ids
end

function parse_alife_ancestor_id_scalar(
        field::AbstractString, record_index::Int, source_path::OptionalString,
    )::Int
    token = strip(field)
    isempty(token) && throw(alife_error(source_path, "data record $(record_index) is missing the required `ancestor_id` value; basenode entries must set `ancestor_id` equal to their own `id`."))
    parsed_ancestor_id = try
        parse(Int, token)
    catch
        throw(alife_error(source_path, "data record $(record_index) has a non-integer `ancestor_id` value `$(token)`."))
    end
    parsed_ancestor_id < 0 && throw(alife_error(source_path, "data record $(record_index) has a negative `ancestor_id` value `$(parsed_ancestor_id)`; alife `id` values must be non-negative."))
    return parsed_ancestor_id
end

function coerce_alife_id(value, record_index::Int, source_path::OptionalString)::Int
    value === missing && throw(alife_error(source_path, "data record $(record_index) is missing the required `id` value."))
    value === nothing && throw(alife_error(source_path, "data record $(record_index) is missing the required `id` value."))
    if value isa Integer
        value < 0 && throw(alife_error(source_path, "data record $(record_index) has a negative `id` value `$(value)`; alife `id` values must be non-negative."))
        return Int(value)
    end
    if value isa AbstractString
        return parse_alife_id(value, record_index, source_path)
    end
    throw(alife_error(source_path, "data record $(record_index) `id` value `$(value)` of type `$(typeof(value))` is not coercible to an integer."))
end

function coerce_alife_ancestor_list(value, record_index::Int, source_path::OptionalString)::Vector{Int}
    (value === missing || value === nothing) && return Int[]
    value isa AbstractString && return parse_alife_ancestor_list(value, record_index, source_path)
    if value isa AbstractVector
        ancestor_ids = Int[]
        for element in value
            push!(ancestor_ids, coerce_alife_id(element, record_index, source_path))
        end
        return ancestor_ids
    end
    throw(alife_error(source_path, "data record $(record_index) `ancestor_list` value `$(value)` of type `$(typeof(value))` is not coercible to a list of integers."))
end

function coerce_alife_ancestor_id_scalar(
        value, self_id::Int, record_index::Int, source_path::OptionalString,
    )::Int
    (value === missing || value === nothing) && throw(alife_error(source_path, "data record $(record_index) is missing the required `ancestor_id` value; basenode entries must set `ancestor_id` equal to their own `id`."))
    if value isa Integer
        value < 0 && throw(alife_error(source_path, "data record $(record_index) has a negative `ancestor_id` value `$(value)`; alife `id` values must be non-negative."))
        return Int(value)
    end
    value isa AbstractString && return parse_alife_ancestor_id_scalar(value, record_index, source_path)
    throw(alife_error(source_path, "data record $(record_index) `ancestor_id` value `$(value)` of type `$(typeof(value))` is not coercible to an integer."))
end

function normalize_annotation_column_cells(raw_column)::Vector{OptionalString}
    n = length(raw_column)
    out = Vector{OptionalString}(undef, n)
    for i in 1:n
        value = raw_column[i]
        if value === missing || value === nothing
            out[i] = nothing
        elseif value isa AbstractString
            stripped = strip(value)
            out[i] = isempty(stripped) ? nothing : String(stripped)
        else
            stripped = strip(string(value))
            out[i] = isempty(stripped) ? nothing : String(stripped)
        end
    end
    return out
end

function partition_components_bfs(
        columns::AlifeColumns,
        row_index_by_id::Dict{Int, Int},
        basenode_row_indices::Vector{Int},
        source_path::OptionalString,
    )::Vector{Vector{Int}}
    n = columns.n
    children_ids_by_parent_id = Dict{Int, Vector{Int}}()
    for i in 1:n
        for parent_id in parent_ids_at_row(columns, i)
            push!(get!(children_ids_by_parent_id, parent_id, Int[]), columns.ids[i])
        end
    end
    for child_ids in values(children_ids_by_parent_id)
        sort!(child_ids)
    end

    component_of_row = fill(0, n)
    components = Vector{Vector{Int}}()
    for basenode_row_index in basenode_row_indices
        push!(components, Int[basenode_row_index])
        component_id = length(components)
        component_of_row[basenode_row_index] = component_id
        component_rows = components[component_id]
        queue_index = 1
        while queue_index <= length(component_rows)
            current_row_index = component_rows[queue_index]
            queue_index += 1
            current_id = columns.ids[current_row_index]
            haskey(children_ids_by_parent_id, current_id) || continue
            for child_id in children_ids_by_parent_id[current_id]
                child_row_index = row_index_by_id[child_id]
                component_of_row[child_row_index] == 0 || continue
                component_of_row[child_row_index] = component_id
                push!(component_rows, child_row_index)
            end
        end
    end

    unreached_count = count(==(0), component_of_row)
    unreached_count == 0 || throw(alife_error(source_path, "alife source has $(unreached_count) entries unreachable from any basenode; this typically indicates an ancestor cycle."))
    return components
end

function build_alife_graph_asset(
        columns::AlifeColumns,
        component_row_indices::Vector{Int},
        graph_index::Int,
        source_path::OptionalString,
    )::LineageGraphAsset
    nodekey_by_row_index = assign_alife_nodekeys(component_row_indices)
    row_index_by_id_local = Dict{Int, Int}(
        columns.ids[row_index] => row_index for row_index in component_row_indices
    )
    node_table = build_alife_node_table(columns, component_row_indices)
    edge_table = build_alife_edge_table(
        columns, component_row_indices, nodekey_by_row_index, row_index_by_id_local,
    )
    return LineageGraphAsset(
        graph_index, 1, 1, graph_index, nothing, nothing,
        node_table, edge_table, nothing, nothing, source_path,
    )
end

function assign_alife_nodekeys(
        component_row_indices::AbstractVector{Int},
    )::Dict{Int, StructureKeyType}
    nodekey_by_row_index = Dict{Int, StructureKeyType}()
    for (k, row_index) in enumerate(component_row_indices)
        nodekey_by_row_index[row_index] = StructureKeyType(k)
    end
    return nodekey_by_row_index
end

function build_alife_node_table(
        columns::AlifeColumns,
        component_row_indices::AbstractVector{Int},
    )::NodeTable
    n_nodes = length(component_row_indices)
    nodekeys = StructureKeyType[StructureKeyType(k) for k in 1:n_nodes]
    labels = String[string(columns.ids[row_index]) for row_index in component_row_indices]
    annotation_columns_nt = select_annotation_columns(columns, component_row_indices)
    return NodeTable(
        nodekey = nodekeys, label = labels, annotation_columns = annotation_columns_nt,
    )
end

function count_alife_edges(
        columns::AlifeColumns,
        component_row_indices::AbstractVector{Int},
    )::Int
    n_edges = 0
    for row_index in component_row_indices
        n_edges += n_parents_at_row(columns, row_index)
    end
    return n_edges
end

function build_alife_edge_table(
        columns::AlifeColumns,
        component_row_indices::AbstractVector{Int},
        nodekey_by_row_index::Dict{Int, StructureKeyType},
        row_index_by_id_local::Dict{Int, Int},
    )::EdgeTable
    n_edges = count_alife_edges(columns, component_row_indices)
    edgekeys = Vector{StructureKeyType}(undef, n_edges)
    src_nodekeys = Vector{StructureKeyType}(undef, n_edges)
    dst_nodekeys = Vector{StructureKeyType}(undef, n_edges)
    edgeweights = Vector{EdgeWeightType}(undef, n_edges)
    edge_cursor = 0
    for row_index in component_row_indices
        dst_nodekey = nodekey_by_row_index[row_index]
        for parent_id in parent_ids_at_row(columns, row_index)
            edge_cursor += 1
            parent_row_index = row_index_by_id_local[parent_id]
            edgekeys[edge_cursor] = StructureKeyType(edge_cursor)
            src_nodekeys[edge_cursor] = nodekey_by_row_index[parent_row_index]
            dst_nodekeys[edge_cursor] = dst_nodekey
            edgeweights[edge_cursor] = nothing
        end
    end
    return EdgeTable(
        edgekey = edgekeys,
        src_nodekey = src_nodekeys,
        dst_nodekey = dst_nodekeys,
        edgeweight = edgeweights,
    )
end

function select_annotation_columns(
        columns::AlifeColumns,
        ordered_row_indices::AbstractVector{Int},
    )::NamedTuple
    annotation_columns_nt = NamedTuple()
    identity_slice = is_identity_slice(ordered_row_indices, columns.n)
    for (slot_index, annotation_name) in enumerate(columns.annotation_names)
        source_column = columns.annotation_columns[slot_index]
        selected_column = identity_slice ?
            source_column :
            OptionalString[source_column[row_index] for row_index in ordered_row_indices]
        annotation_columns_nt = merge(
            annotation_columns_nt,
            NamedTuple{(annotation_name,)}((selected_column,)),
        )
    end
    return annotation_columns_nt
end

function is_identity_slice(ordered_row_indices::AbstractVector{Int}, n_total::Int)::Bool
    length(ordered_row_indices) == n_total || return false
    for i in 1:n_total
        ordered_row_indices[i] == i || return false
    end
    return true
end

function format_alife_error(source_path::OptionalString, message::AbstractString)::String
    source_label = source_path === nothing ? "<input>" : source_path
    return "Alife standard parse error in $(source_label): $(message)"
end

function alife_error(source_path::OptionalString, message::AbstractString)::ArgumentError
    return ArgumentError(format_alife_error(source_path, message))
end

"""
    load_alife_table(table; allow_forest = false, assume_topological_ordering = false, source_path = nothing) -> LineageGraphStore
    load_alife_table(table, NodeT; kwargs...) -> LineageGraphStore
    load_alife_table(table, basenode; kwargs...) -> LineageGraphStore
    load_alife_table(table, BuilderDescriptor(...); kwargs...) -> LineageGraphStore
    load_alife_table(table; builder = fn, kwargs...) -> LineageGraphStore

Load a Tables.jl-compatible columnar object whose schema follows the alife
phylogeny data standard. The table must declare an `id` column and at
least one of `ancestor_list` or `ancestor_id`; if both are present,
`ancestor_list` is used and `ancestor_id` is ignored. Basenode entries are identified by
`[NONE]`/empty `ancestor_list` or by `ancestor_id` equal to the row's own
`id`. All other columns are retained as node annotations.

`allow_forest = false` (the default) raises when the source contains more
than one basenode. Pass `allow_forest = true` to materialize one graph per
connected component.

`assume_topological_ordering = false` (the default) runs a BFS partition
that validates reachability and rejects cycles. Pass
`assume_topological_ordering = true` to skip the validating BFS and use a
single forward sweep instead, which trusts the caller that every ancestor
appears at an earlier input row index than each of its descendants. The
assumption is verified via `@assert` so a violation surfaces immediately
in normal builds, and is elidable under `--check-bounds=no`.

`normalize_annotation_values = false` (the default) leaves annotation cell
content unchanged: `missing`/`nothing` cells become `nothing`,
`AbstractString` cells pass through verbatim (whitespace preserved, empty
strings retained as `""`), and any other cell type is stringified via
`string(value)` so the column round-trips into the
`Vector{Union{Nothing, String}}` storage. Pass
`normalize_annotation_values = true` to additionally strip whitespace from
string cells and coerce empty strings to `nothing`.

When the source declares an `origin_time` annotation column, a warning is
emitted noting that LineagesIO does not yet derive `edgeweight` from it —
the column is retained as a node annotation only.
"""
function load_alife_table(
        table,
        builder_descriptor::BuilderDescriptor;
        source_path::Union{Nothing, AbstractString} = nothing,
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::LineageGraphStore
    source_descriptor = AlifeTableSourceDescriptor(
        table, normalize_source_path(source_path);
        allow_forest = allow_forest,
        assume_topological_ordering = assume_topological_ordering,
        normalize_annotation_values = normalize_annotation_values,
    )
    request = typed_builder_request(builder_descriptor)
    return canonical_load(source_descriptor, request)
end

function load_alife_table(
        table,
        args...;
        builder = nothing,
        source_path::Union{Nothing, AbstractString} = nothing,
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::LineageGraphStore
    return compat_load(
        AlifeTableSourceDescriptor(
            table, normalize_source_path(source_path);
            allow_forest = allow_forest,
            assume_topological_ordering = assume_topological_ordering,
            normalize_annotation_values = normalize_annotation_values,
        ),
        args...;
        builder = builder,
    )
end
