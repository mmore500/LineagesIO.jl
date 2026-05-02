const ALIFE_ID_COLUMN = :id
const ALIFE_ANCESTOR_LIST_COLUMN = :ancestor_list

struct ParsedAlifeRow
    id::Int
    ancestor_ids::Vector{Int}
    annotations::Dict{Symbol, String}
    record_index::Int
end

function build_alife_store(
    text::String,
    source_path::OptionalString,
)::LineageGraphStore
    return build_alife_store(text, source_path, TablesOnlyLoadRequest())
end

function build_alife_store(
    text::String,
    source_path::OptionalString,
    request::AbstractLoadRequest,
)::LineageGraphStore
    header, rows = parse_alife_source(text, source_path)
    annotation_names = collect_alife_annotation_names(header)
    components = partition_alife_components(rows, source_path)
    graph_assets = [
        build_alife_graph_asset(component, graph_index, source_path, annotation_names)
        for (graph_index, component) in enumerate(components)
    ]
    graph_assets = materialize_graphs(graph_assets, request)
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
        index = [graph_asset.index for graph_asset in graph_assets],
        source_idx = [graph_asset.source_idx for graph_asset in graph_assets],
        collection_idx = [graph_asset.collection_idx for graph_asset in graph_assets],
        collection_graph_idx = [graph_asset.collection_graph_idx for graph_asset in graph_assets],
        collection_label = [graph_asset.collection_label for graph_asset in graph_assets],
        graph_label = [graph_asset.graph_label for graph_asset in graph_assets],
        node_count = [lineagetable_nrows(graph_asset.node_table) for graph_asset in graph_assets],
        edge_count = [lineagetable_nrows(graph_asset.edge_table) for graph_asset in graph_assets],
    )
    graphs = GraphAssetIterator(graph_assets)
    return LineageGraphStore(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )
end

function parse_alife_source(
    text::AbstractString,
    source_path::OptionalString,
)::Tuple{Vector{Symbol}, Vector{ParsedAlifeRow}}
    records = split_csv_records(text, source_path)
    isempty(records) && throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one header row.")))
    header_record = first(records)
    header = [Symbol(strip(field)) for field in header_record]
    validate_alife_header(header, source_path)
    id_column_index = findfirst(==(ALIFE_ID_COLUMN), header)
    ancestor_column_index = findfirst(==(ALIFE_ANCESTOR_LIST_COLUMN), header)

    rows = ParsedAlifeRow[]
    seen_ids = Dict{Int, Int}()
    for (record_index, record) in enumerate(@view records[2:end])
        all(isempty, record) && continue
        length(record) == length(header) || throw(ArgumentError(format_alife_error(
            source_path,
            "data record $(record_index) has $(length(record)) fields but the header declares $(length(header)).",
        )))
        id = parse_alife_id(record[id_column_index], record_index, source_path)
        if haskey(seen_ids, id)
            throw(ArgumentError(format_alife_error(
                source_path,
                "duplicate `id=$(id)` at data record $(record_index); previously seen at record $(seen_ids[id]).",
            )))
        end
        seen_ids[id] = record_index
        ancestor_ids = parse_alife_ancestor_list(record[ancestor_column_index], record_index, source_path)
        annotations = Dict{Symbol, String}()
        for (column_index, column_name) in enumerate(header)
            column_index == id_column_index && continue
            column_index == ancestor_column_index && continue
            value = strip(record[column_index])
            isempty(value) && continue
            annotations[column_name] = String(value)
        end
        push!(rows, ParsedAlifeRow(id, ancestor_ids, annotations, record_index))
    end
    isempty(rows) && throw(ArgumentError(format_alife_error(source_path, "alife sources must contain at least one data row after the header.")))

    for row in rows
        for ancestor_id in row.ancestor_ids
            haskey(seen_ids, ancestor_id) || throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(row.record_index) references unknown `ancestor_list` id=$(ancestor_id) for `id=$(row.id)`.",
            )))
        end
    end
    return header, rows
end

function validate_alife_header(header::Vector{Symbol}, source_path::OptionalString)::Nothing
    isempty(header) && throw(ArgumentError(format_alife_error(source_path, "alife header row may not be empty.")))
    ALIFE_ID_COLUMN in header || throw(ArgumentError(format_alife_error(source_path, "alife sources must declare a required `id` header column.")))
    ALIFE_ANCESTOR_LIST_COLUMN in header || throw(ArgumentError(format_alife_error(source_path, "alife sources must declare a required `ancestor_list` header column.")))
    seen = Set{Symbol}()
    for column_name in header
        column_name in seen && throw(ArgumentError(format_alife_error(source_path, "duplicate header column `$(column_name)`.")))
        push!(seen, column_name)
    end
    return nothing
end

function collect_alife_annotation_names(header::Vector{Symbol})::Vector{Symbol}
    return Symbol[
        column_name for column_name in header
        if column_name != ALIFE_ID_COLUMN && column_name != ALIFE_ANCESTOR_LIST_COLUMN
    ]
end

function parse_alife_id(field::AbstractString, record_index::Int, source_path::OptionalString)::Int
    token = strip(field)
    isempty(token) && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) is missing the required `id` value.")))
    parsed_id = try
        parse(Int, token)
    catch
        throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) has a non-integer `id` value `$(token)`.")))
    end
    parsed_id < 0 && throw(ArgumentError(format_alife_error(source_path, "data record $(record_index) has a negative `id` value `$(parsed_id)`; alife `id` values must be non-negative.")))
    return parsed_id
end

function parse_alife_ancestor_list(field::AbstractString, record_index::Int, source_path::OptionalString)::Vector{Int}
    token = strip(field)
    isempty(token) && return Int[]
    (startswith(token, '[') && endswith(token, ']')) || throw(ArgumentError(format_alife_error(
        source_path,
        "data record $(record_index) has a malformed `ancestor_list` `$(token)`; alife `ancestor_list` values must be bracketed `[...]`.",
    )))
    inner = strip(SubString(token, nextind(token, firstindex(token)), prevind(token, lastindex(token))))
    isempty(inner) && return Int[]
    uppercase(String(inner)) == "NONE" && return Int[]

    ancestor_ids = Int[]
    for raw_token in split(inner, ',')
        ancestor_token = strip(raw_token)
        isempty(ancestor_token) && continue
        if uppercase(String(ancestor_token)) == "NONE"
            throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(record_index) lists `NONE` alongside other ancestors; `NONE` must be the sole `ancestor_list` token for root entries.",
            )))
        end
        parsed_ancestor_id = try
            parse(Int, ancestor_token)
        catch
            throw(ArgumentError(format_alife_error(
                source_path,
                "data record $(record_index) has a non-integer `ancestor_list` token `$(ancestor_token)`.",
            )))
        end
        parsed_ancestor_id < 0 && throw(ArgumentError(format_alife_error(
            source_path,
            "data record $(record_index) has a negative `ancestor_list` token `$(parsed_ancestor_id)`; alife `id` values must be non-negative.",
        )))
        push!(ancestor_ids, parsed_ancestor_id)
    end
    return ancestor_ids
end

function partition_alife_components(rows::Vector{ParsedAlifeRow}, source_path::OptionalString)::Vector{Vector{ParsedAlifeRow}}
    nrows = length(rows)
    nrows == 0 && return Vector{ParsedAlifeRow}[]
    index_by_id = Dict{Int, Int}()
    for (i, row) in enumerate(rows)
        index_by_id[row.id] = i
    end
    parent_uf = collect(1:nrows)
    for (i, row) in enumerate(rows)
        for ancestor_id in row.ancestor_ids
            union_find_union!(parent_uf, i, index_by_id[ancestor_id])
        end
    end
    grouped = Dict{Int, Vector{Int}}()
    for i in 1:nrows
        root = union_find_root!(parent_uf, i)
        push!(get!(grouped, root, Int[]), i)
    end
    component_keys = sort(collect(keys(grouped)); by = key -> minimum(grouped[key]))
    return [ParsedAlifeRow[rows[i] for i in grouped[key]] for key in component_keys]
end

function union_find_root!(parent_uf::Vector{Int}, x::Int)::Int
    while parent_uf[x] != x
        parent_uf[x] = parent_uf[parent_uf[x]]
        x = parent_uf[x]
    end
    return x
end

function union_find_union!(parent_uf::Vector{Int}, a::Int, b::Int)::Nothing
    root_a = union_find_root!(parent_uf, a)
    root_b = union_find_root!(parent_uf, b)
    root_a == root_b && return nothing
    parent_uf[root_a] = root_b
    return nothing
end

function build_alife_graph_asset(
    component::Vector{ParsedAlifeRow},
    graph_index::Int,
    source_path::OptionalString,
    annotation_names::Vector{Symbol},
)::LineageGraphAsset
    root_rows = ParsedAlifeRow[row for row in component if isempty(row.ancestor_ids)]
    length(root_rows) == 1 || throw(ArgumentError(format_alife_error(
        source_path,
        "each connected alife component must declare exactly one root entry (with `[NONE]` `ancestor_list`), but graph $(graph_index) yielded $(length(root_rows)) candidate roots.",
    )))
    root = first(root_rows)

    rows_by_id = Dict{Int, ParsedAlifeRow}(row.id => row for row in component)
    children_by_id = Dict{Int, Vector{Int}}()
    for row in component
        for ancestor_id in row.ancestor_ids
            push!(get!(children_by_id, ancestor_id, Int[]), row.id)
        end
    end

    nodekey_by_id = Dict{Int, StructureKeyType}()
    bfs_ordered_ids = Int[]
    nodekey_by_id[root.id] = StructureKeyType(1)
    push!(bfs_ordered_ids, root.id)
    queue_index = 1
    while queue_index <= length(bfs_ordered_ids)
        current_id = bfs_ordered_ids[queue_index]
        queue_index += 1
        child_ids = sort(get(children_by_id, current_id, Int[]))
        for child_id in child_ids
            haskey(nodekey_by_id, child_id) && continue
            nodekey_by_id[child_id] = StructureKeyType(length(bfs_ordered_ids) + 1)
            push!(bfs_ordered_ids, child_id)
        end
    end
    if length(bfs_ordered_ids) != length(component)
        throw(ArgumentError(format_alife_error(
            source_path,
            "alife graph $(graph_index) has $(length(component) - length(bfs_ordered_ids)) entries unreachable from its root; this typically indicates an `ancestor_list` cycle.",
        )))
    end

    nodekeys = StructureKeyType[]
    labels = String[]
    node_annotation_rows = Dict{Symbol, String}[]
    for id in bfs_ordered_ids
        push!(nodekeys, nodekey_by_id[id])
        push!(labels, string(id))
        push!(node_annotation_rows, copy(rows_by_id[id].annotations))
    end
    annotation_columns = build_annotation_columns(node_annotation_rows, copy(annotation_names))
    node_table = NodeTable(nodekey = nodekeys, label = labels, annotation_columns = annotation_columns)

    edgekeys = StructureKeyType[]
    src_nodekeys = StructureKeyType[]
    dst_nodekeys = StructureKeyType[]
    edgeweights = EdgeWeightType[]
    for id in bfs_ordered_ids
        row = rows_by_id[id]
        for ancestor_id in row.ancestor_ids
            push!(edgekeys, StructureKeyType(length(edgekeys) + 1))
            push!(src_nodekeys, nodekey_by_id[ancestor_id])
            push!(dst_nodekeys, nodekey_by_id[id])
            push!(edgeweights, nothing)
        end
    end
    edge_table = EdgeTable(
        edgekey = edgekeys,
        src_nodekey = src_nodekeys,
        dst_nodekey = dst_nodekeys,
        edgeweight = edgeweights,
    )
    return LineageGraphAsset(
        graph_index,
        1,
        1,
        graph_index,
        nothing,
        nothing,
        node_table,
        edge_table,
        nothing,
        nothing,
        source_path,
    )
end

function split_csv_records(text::AbstractString, source_path::OptionalString)::Vector{Vector{String}}
    records = Vector{String}[]
    current_record = String[]
    field_buffer = IOBuffer()
    in_quoted_field = false
    has_field_content = false
    has_record_content = false
    text_index = firstindex(text)
    text_end = lastindex(text)

    while text_index <= text_end
        current_character = text[text_index]
        if in_quoted_field
            if current_character == '"'
                next_text_index = nextind(text, text_index)
                if next_text_index <= text_end && text[next_text_index] == '"'
                    print(field_buffer, '"')
                    has_field_content = true
                    text_index = nextind(text, next_text_index)
                    continue
                end
                in_quoted_field = false
                text_index = next_text_index
                continue
            end
            print(field_buffer, current_character)
            has_field_content = true
            text_index = nextind(text, text_index)
            continue
        end
        if current_character == '"'
            in_quoted_field = true
            has_field_content = true
            text_index = nextind(text, text_index)
            continue
        end
        if current_character == ','
            push!(current_record, String(take!(field_buffer)))
            has_field_content = false
            has_record_content = true
            text_index = nextind(text, text_index)
            continue
        end
        if current_character == '\r' || current_character == '\n'
            push!(current_record, String(take!(field_buffer)))
            push!(records, current_record)
            current_record = String[]
            has_field_content = false
            has_record_content = false
            text_index = nextind(text, text_index)
            if current_character == '\r' && text_index <= text_end && text[text_index] == '\n'
                text_index = nextind(text, text_index)
            end
            continue
        end
        print(field_buffer, current_character)
        has_field_content = true
        text_index = nextind(text, text_index)
    end

    in_quoted_field && throw(ArgumentError(format_alife_error(source_path, "unterminated quoted CSV field; check for an unmatched `\"`.")))
    if has_field_content || has_record_content
        push!(current_record, String(take!(field_buffer)))
        push!(records, current_record)
    end
    return records
end

function format_alife_error(source_path::OptionalString, message::AbstractString)::String
    source_label = source_path === nothing ? "<input>" : source_path
    return "Alife standard parse error in $(source_label): $(message)"
end
