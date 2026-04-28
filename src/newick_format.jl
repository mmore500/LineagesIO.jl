struct ParsedNewickOccurrence
    label::String
    hybrid_label::OptionalString
    node_annotations::Dict{Symbol, String}
    edgeweight::EdgeWeightType
    edge_annotations::Dict{Symbol, String}
    children::Vector{ParsedNewickOccurrence}
end

mutable struct NewickParserState
    text::String
    index::Int
    source_label::OptionalString
end

mutable struct HybridOccurrenceState
    occurrence_count::Int
    child_owner_count::Int
end

mutable struct NewickGraphBuildState
    nodekeys::Vector{StructureKeyType}
    labels::Vector{String}
    node_annotation_rows::Vector{Dict{Symbol, String}}
    node_annotation_names::Vector{Symbol}
    edgekeys::Vector{StructureKeyType}
    src_nodekeys::Vector{StructureKeyType}
    dst_nodekeys::Vector{StructureKeyType}
    edgeweights::Vector{EdgeWeightType}
    edge_annotation_rows::Vector{Dict{Symbol, String}}
    edge_annotation_names::Vector{Symbol}
    hybrid_nodekey_by_label::Dict{String, StructureKeyType}
    hybrid_occurrence_state_by_label::Dict{String, HybridOccurrenceState}
end

function build_newick_store(
    text::String,
    source_path::OptionalString,
)::LineageGraphStore
    return build_newick_store(text, source_path, TablesOnlyLoadRequest())
end

function build_newick_store(
    text::String,
    source_path::OptionalString,
    request::AbstractLoadRequest,
)::LineageGraphStore
    roots = parse_newick_source(text, source_path)
    graph_assets = [build_graph_asset(root, graph_index, source_path) for (graph_index, root) in enumerate(roots)]
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

function build_graph_asset(
    root::ParsedNewickOccurrence,
    graph_index::Int,
    source_path::OptionalString,
)::LineageGraphAsset
    root.edgeweight === nothing || throw(ArgumentError("Incoming root edge weights are out of scope for tranche 4 rooted-network-capable Newick loads because the authoritative core tables do not yet have an honest owner for them."))
    isempty(root.edge_annotations) || throw(ArgumentError("Incoming root edge annotations are out of scope for tranche 4 rooted-network-capable Newick loads because the authoritative core tables do not yet have an honest owner for them."))

    state = NewickGraphBuildState(
        StructureKeyType[],
        String[],
        Dict{Symbol, String}[],
        Symbol[],
        StructureKeyType[],
        StructureKeyType[],
        StructureKeyType[],
        EdgeWeightType[],
        Dict{Symbol, String}[],
        Symbol[],
        Dict{String, StructureKeyType}(),
        Dict{String, HybridOccurrenceState}(),
    )
    rootnodekey = append_occurrence!(state, root, nothing)
    rootnodekey == StructureKeyType(1) || throw(ArgumentError("Rooted-network-capable Newick table assembly must preserve the tranche-4 `rootnodekey == 1` invariant, but the root resolved to nodekey $(rootnodekey)."))
    validate_hybrid_occurrence_counts!(state)

    node_table = NodeTable(
        nodekey = state.nodekeys,
        label = state.labels,
        annotation_columns = build_annotation_columns(state.node_annotation_rows, state.node_annotation_names),
    )
    edge_table = EdgeTable(
        edgekey = state.edgekeys,
        src_nodekey = state.src_nodekeys,
        dst_nodekey = state.dst_nodekeys,
        edgeweight = state.edgeweights,
        annotation_columns = build_annotation_columns(state.edge_annotation_rows, state.edge_annotation_names),
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
        source_path,
    )
end

function append_occurrence!(
    state::NewickGraphBuildState,
    occurrence::ParsedNewickOccurrence,
    parent_nodekey::Union{Nothing, StructureKeyType},
)::StructureKeyType
    nodekey = resolve_occurrence_nodekey!(state, occurrence)
    if parent_nodekey !== nothing
        append_edge_row!(
            state,
            parent_nodekey,
            nodekey,
            occurrence.edgeweight,
            occurrence.edge_annotations,
        )
    end
    append_occurrence_children!(state, occurrence, nodekey)
    return nodekey
end

function resolve_occurrence_nodekey!(
    state::NewickGraphBuildState,
    occurrence::ParsedNewickOccurrence,
)::StructureKeyType
    occurrence.hybrid_label === nothing && return append_new_node!(state, occurrence)

    hybrid_label = occurrence.hybrid_label
    if haskey(state.hybrid_nodekey_by_label, hybrid_label)
        nodekey = state.hybrid_nodekey_by_label[hybrid_label]
        hybrid_state = state.hybrid_occurrence_state_by_label[hybrid_label]
        hybrid_state.occurrence_count += 1
        hybrid_state.occurrence_count <= 2 || throw(ArgumentError("Repeated hybrid label `#$(hybrid_label)` is structurally ambiguous for tranche 4 rooted-network-capable Newick loads because it appears more than twice in one graph."))
        merge_hybrid_occurrence_node!(state, nodekey, occurrence, hybrid_label)
        return nodekey
    end

    nodekey = append_new_node!(state, occurrence)
    state.hybrid_nodekey_by_label[hybrid_label] = nodekey
    state.hybrid_occurrence_state_by_label[hybrid_label] = HybridOccurrenceState(1, 0)
    return nodekey
end

function append_new_node!(
    state::NewickGraphBuildState,
    occurrence::ParsedNewickOccurrence,
)::StructureKeyType
    nodekey = StructureKeyType(length(state.nodekeys) + 1)
    push!(state.nodekeys, nodekey)
    push!(state.labels, occurrence.label)
    push!(state.node_annotation_rows, copy(occurrence.node_annotations))
    append_annotation_names!(state.node_annotation_names, occurrence.node_annotations)
    return nodekey
end

function merge_hybrid_occurrence_node!(
    state::NewickGraphBuildState,
    nodekey::StructureKeyType,
    occurrence::ParsedNewickOccurrence,
    hybrid_label::AbstractString,
)::Nothing
    state.labels[nodekey] == occurrence.label || throw(ArgumentError("Repeated hybrid label `#$(hybrid_label)` was associated with conflicting structural labels `$(state.labels[nodekey])` and `$(occurrence.label)`."))
    merged_annotations = state.node_annotation_rows[nodekey]
    for (annotation_name, annotation_value) in occurrence.node_annotations
        if haskey(merged_annotations, annotation_name)
            merged_annotations[annotation_name] == annotation_value || throw(ArgumentError("Repeated hybrid label `#$(hybrid_label)` was associated with conflicting retained node annotation values for `$(annotation_name)`."))
        else
            merged_annotations[annotation_name] = annotation_value
        end
    end
    append_annotation_names!(state.node_annotation_names, occurrence.node_annotations)
    return nothing
end

function append_occurrence_children!(
    state::NewickGraphBuildState,
    occurrence::ParsedNewickOccurrence,
    nodekey::StructureKeyType,
)::Nothing
    occurrence.hybrid_label === nothing && return append_all_occurrence_children!(state, occurrence.children, nodekey)
    isempty(occurrence.children) && return nothing

    hybrid_label = occurrence.hybrid_label
    hybrid_state = state.hybrid_occurrence_state_by_label[hybrid_label]
    hybrid_state.child_owner_count += 1
    hybrid_state.child_owner_count == 1 || throw(ArgumentError("Repeated hybrid label `#$(hybrid_label)` is structurally ambiguous for tranche 4 rooted-network-capable Newick loads because more than one occurrence lists descendants. Successors of one hybrid node must appear in only one occurrence."))
    append_all_occurrence_children!(state, occurrence.children, nodekey)
    return nothing
end

function append_all_occurrence_children!(
    state::NewickGraphBuildState,
    children::Vector{ParsedNewickOccurrence},
    parent_nodekey::StructureKeyType,
)::Nothing
    for child in children
        append_occurrence!(state, child, parent_nodekey)
    end
    return nothing
end

function append_edge_row!(
    state::NewickGraphBuildState,
    src_nodekey::StructureKeyType,
    dst_nodekey::StructureKeyType,
    edgeweight::EdgeWeightType,
    edge_annotations::Dict{Symbol, String},
)::StructureKeyType
    edgekey = StructureKeyType(length(state.edgekeys) + 1)
    push!(state.edgekeys, edgekey)
    push!(state.src_nodekeys, src_nodekey)
    push!(state.dst_nodekeys, dst_nodekey)
    push!(state.edgeweights, edgeweight)
    push!(state.edge_annotation_rows, copy(edge_annotations))
    append_annotation_names!(state.edge_annotation_names, edge_annotations)
    return edgekey
end

function validate_hybrid_occurrence_counts!(
    state::NewickGraphBuildState,
)::Nothing
    for (hybrid_label, hybrid_state) in state.hybrid_occurrence_state_by_label
        hybrid_state.occurrence_count == 2 && continue
        throw(ArgumentError("Unmatched hybrid label `#$(hybrid_label)` is out of scope for tranche 4 rooted-network-capable Newick loads because this phase supports only the repeated two-occurrence hybrid convention."))
    end
    return nothing
end

function build_annotation_columns(
    annotation_rows::Vector{Dict{Symbol, String}},
    annotation_names::Vector{Symbol},
)::NamedTuple
    annotation_columns = NamedTuple()
    for annotation_name in annotation_names
        annotation_column = OptionalString[get(annotation_row, annotation_name, nothing) for annotation_row in annotation_rows]
        annotation_columns = merge(annotation_columns, NamedTuple{(annotation_name,)}((annotation_column,)))
    end
    return annotation_columns
end

function append_annotation_names!(
    annotation_names::Vector{Symbol},
    annotation_row::Dict{Symbol, String},
)::Nothing
    for annotation_name in sort!(collect(keys(annotation_row)))
        annotation_name in annotation_names || push!(annotation_names, annotation_name)
    end
    return nothing
end

function parse_newick_source(
    text::String,
    source_label::OptionalString,
)::Vector{ParsedNewickOccurrence}
    parser = NewickParserState(text, firstindex(text), source_label)
    roots = ParsedNewickOccurrence[]
    skip_whitespace!(parser)
    while !parser_at_end(parser)
        push!(roots, parse_graph!(parser))
        skip_whitespace!(parser)
    end
    isempty(roots) && throw(ArgumentError("Newick sources must contain at least one rooted graph."))
    return roots
end

function parse_graph!(parser::NewickParserState)::ParsedNewickOccurrence
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "expected a rooted graph before end of input")
    parser_peek(parser) == ';' && throw_parse_error(parser, "expected a rooted graph before `;`")
    root = parse_subtree!(parser)
    skip_whitespace!(parser)
    parser_peek(parser) == ';' || throw_parse_error(parser, "expected `;` after rooted graph")
    advance!(parser)
    return root
end

function parse_subtree!(parser::NewickParserState)::ParsedNewickOccurrence
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "tree ends prematurely while reading a subtree")
    if parser_peek(parser) == '('
        advance!(parser)
        children = ParsedNewickOccurrence[parse_subtree!(parser)]
        while true
            skip_whitespace!(parser)
            next_character = parser_peek(parser)
            if next_character == ','
                advance!(parser)
                push!(children, parse_subtree!(parser))
            elseif next_character == ')'
                advance!(parser)
                break
            else
                throw_parse_error(parser, "expected `,` or `)` while reading descendant list")
            end
        end
        label, hybrid_label = parse_optional_node_identity!(parser)
        node_annotations = parse_optional_annotations!(parser, "node")
        edgeweight, edge_annotations = parse_optional_edgeweight!(parser)
        return ParsedNewickOccurrence(label, hybrid_label, node_annotations, edgeweight, edge_annotations, children)
    end

    label, hybrid_label = parse_optional_node_identity!(parser)
    node_annotations = parse_optional_annotations!(parser, "node")
    edgeweight, edge_annotations = parse_optional_edgeweight!(parser)
    return ParsedNewickOccurrence(label, hybrid_label, node_annotations, edgeweight, edge_annotations, ParsedNewickOccurrence[])
end

function parse_optional_node_identity!(
    parser::NewickParserState,
)::Tuple{String, OptionalString}
    skip_whitespace!(parser)
    parser_at_end(parser) && return "", nothing
    next_character = parser_peek(parser)
    next_character in (',', ')', ';', ':') && return "", nothing
    next_character == '#' && return parse_hybrid_label!(parser)
    next_character == '\'' && return parse_quoted_text!(parser, '\''), nothing
    next_character == '"' && return parse_quoted_text!(parser, '"'), nothing
    return parse_unquoted_label!(parser), nothing
end

function parse_hybrid_label!(
    parser::NewickParserState,
)::Tuple{String, OptionalString}
    advance!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "expected a hybrid label after `#`")
    next_character = parser_peek(parser)
    next_character === nothing && throw_parse_error(parser, "expected a hybrid label after `#`")
    isletter(next_character) || throw_parse_error(parser, "expected an alphabetic hybrid label after `#`")

    label_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (',', '(', ')', ';', ':')
            break
        elseif current_character == '['
            break
        elseif current_character == '#'
            throw_parse_error(parser, "hybrid labels may contain only one leading `#` marker")
        elseif isspace(current_character)
            break
        end
        print(label_buffer, advance!(parser))
    end
    skip_whitespace!(parser)

    hybrid_label = String(take!(label_buffer))
    isempty(hybrid_label) && throw_parse_error(parser, "expected a hybrid label after `#`")
    if !parser_at_end(parser)
        next_character = parser_peek(parser)
        next_character in (',', ')', ';', ':', '[') || throw_parse_error(parser, "hybrid labels may not contain whitespace; quote the label explicitly if whitespace is required")
    end
    return hybrid_label, hybrid_label
end

function parse_quoted_text!(parser::NewickParserState, quote_character::Char)::String
    advance!(parser)
    text_buffer = IOBuffer()
    while true
        parser_at_end(parser) && throw_parse_error(parser, "quoted text must be closed before end of input")
        current_character = advance!(parser)
        if current_character == quote_character
            if !parser_at_end(parser) && parser_peek(parser) == quote_character
                print(text_buffer, advance!(parser))
                continue
            end
            break
        end
        print(text_buffer, current_character)
    end
    skip_whitespace!(parser)
    return String(take!(text_buffer))
end

function parse_unquoted_label!(parser::NewickParserState)::String
    label_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (',', '(', ')', ';', ':')
            break
        elseif current_character == '['
            break
        elseif current_character == '#'
            throw_parse_error(parser, "hybrid labels must occupy the entire unquoted node label token in tranche 4 rooted-network-capable Newick loads")
        elseif isspace(current_character)
            break
        end
        print(label_buffer, advance!(parser))
    end
    skip_whitespace!(parser)
    parser_at_end(parser) && return String(take!(label_buffer))
    next_character = parser_peek(parser)
    if !(next_character in (',', ')', ';', ':', '['))
        throw_parse_error(parser, "unquoted labels may not contain whitespace; quote the label explicitly if whitespace is required")
    end
    return String(take!(label_buffer))
end

function parse_optional_annotations!(
    parser::NewickParserState,
    scope::AbstractString,
)::Dict{Symbol, String}
    annotations = Dict{Symbol, String}()
    skip_whitespace!(parser)
    while !parser_at_end(parser) && parser_peek(parser) == '['
        parse_annotation_block!(parser, annotations, scope)
        skip_whitespace!(parser)
    end
    return annotations
end

function parse_annotation_block!(
    parser::NewickParserState,
    annotations::Dict{Symbol, String},
    scope::AbstractString,
)::Nothing
    advance!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "unterminated `[&...]` retained annotation block")
    parser_peek(parser) == '&' || throw_parse_error(parser, "only `[&...]` retained annotation comments are supported for tranche 4 rooted-network-capable Newick loads")
    advance!(parser)
    skip_whitespace!(parser)
    while true
        parser_at_end(parser) && throw_parse_error(parser, "unterminated `[&...]` retained annotation block")
        parser_peek(parser) == ']' && break
        annotation_name = parse_annotation_field_name!(parser, scope)
        parser_at_end(parser) && throw_parse_error(parser, "retained $(scope) annotation `$(annotation_name)` must assign one scalar value with `=` or `:`")
        separator = parser_peek(parser)
        separator in ('=', ':') || throw_parse_error(parser, "retained $(scope) annotation `$(annotation_name)` must assign one scalar value with `=` or `:`")
        advance!(parser)
        annotation_value = parse_annotation_scalar_value!(parser, annotation_name, scope)
        haskey(annotations, annotation_name) && throw_parse_error(parser, "duplicate retained $(scope) annotation field `$(annotation_name)` is not supported within one row")
        annotations[annotation_name] = annotation_value
        skip_whitespace!(parser)
        parser_at_end(parser) && throw_parse_error(parser, "unterminated `[&...]` retained annotation block")
        if parser_peek(parser) == ','
            advance!(parser)
            skip_whitespace!(parser)
            continue
        elseif parser_peek(parser) == ']'
            break
        else
            throw_parse_error(parser, "expected `,` or `]` while reading retained $(scope) annotations")
        end
    end
    advance!(parser)
    return nothing
end

function parse_annotation_field_name!(
    parser::NewickParserState,
    scope::AbstractString,
)::Symbol
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "retained $(scope) annotations require a field name")
    next_character = parser_peek(parser)
    next_character == '\'' && return Symbol(parse_quoted_text!(parser, '\''))
    next_character == '"' && return Symbol(parse_quoted_text!(parser, '"'))

    field_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in ('=', ':', ',', ']') || isspace(current_character)
            break
        elseif current_character == '{'
            throw_parse_error(parser, "structured retained $(scope) annotation field names are out of scope for tranche 4 rooted-network-capable Newick loads")
        end
        print(field_buffer, advance!(parser))
    end
    field_name = strip(String(take!(field_buffer)))
    isempty(field_name) && throw_parse_error(parser, "retained $(scope) annotations require a field name")
    skip_whitespace!(parser)
    return Symbol(field_name)
end

function parse_annotation_scalar_value!(
    parser::NewickParserState,
    annotation_name::Symbol,
    scope::AbstractString,
)::String
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "retained $(scope) annotation `$(annotation_name)` must provide one scalar value")
    next_character = parser_peek(parser)
    next_character == '{' && throw_parse_error(parser, "structured retained $(scope) annotation values such as `{...}` are out of scope for tranche 4 rooted-network-capable Newick loads")
    next_character == '\'' && return parse_quoted_text!(parser, '\'')
    next_character == '"' && return parse_quoted_text!(parser, '"')

    value_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (',', ']')
            break
        elseif current_character == '{'
            throw_parse_error(parser, "structured retained $(scope) annotation values such as `{...}` are out of scope for tranche 4 rooted-network-capable Newick loads")
        elseif current_character == '['
            throw_parse_error(parser, "nested retained $(scope) annotation comments are out of scope for tranche 4 rooted-network-capable Newick loads")
        end
        print(value_buffer, advance!(parser))
    end
    annotation_value = strip(String(take!(value_buffer)))
    isempty(annotation_value) && throw_parse_error(parser, "retained $(scope) annotation `$(annotation_name)` must provide one scalar value")
    return annotation_value
end

function parse_optional_edgeweight!(parser::NewickParserState)::Tuple{EdgeWeightType, Dict{Symbol, String}}
    edge_annotations = Dict{Symbol, String}()
    skip_whitespace!(parser)
    parser_at_end(parser) && return nothing, edge_annotations
    parser_peek(parser) == ':' || return nothing, edge_annotations
    advance!(parser)

    edgeweight = nothing
    for field_index in 1:3
        skip_whitespace!(parser)
        append_parsed_annotations!(edge_annotations, parse_optional_annotations!(parser, "edge"), "edge")
        field_token = parse_optional_edge_field_token!(parser)
        if field_index == 1
            edgeweight = parse_edgeweight_token!(parser, field_token)
        elseif field_token !== nothing
            field_name = field_index == 2 ? :support : :gamma
            validate_numeric_edge_field_token!(parser, field_token, field_name)
            append_positional_edge_annotation!(edge_annotations, field_name, field_token)
        end
        append_parsed_annotations!(edge_annotations, parse_optional_annotations!(parser, "edge"), "edge")
        skip_whitespace!(parser)
        parser_at_end(parser) && return edgeweight, edge_annotations

        next_character = parser_peek(parser)
        if next_character == ':'
            field_index == 3 && throw_parse_error(parser, "extended edge fields beyond `:length:support:gamma` are out of scope for tranche 4 rooted-network-capable Newick loads")
            advance!(parser)
            continue
        elseif next_character in (',', ')', ';')
            return edgeweight, edge_annotations
        else
            throw_parse_error(parser, "extended edge data may only be followed by another `:` field, a delimiter, or retained `[&...]` annotations")
        end
    end
    return edgeweight, edge_annotations
end

function parse_optional_edge_field_token!(
    parser::NewickParserState,
)::OptionalString
    token_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (':', ',', ')', ';')
            break
        elseif current_character == '['
            break
        elseif isspace(current_character)
            break
        end
        print(token_buffer, advance!(parser))
    end
    skip_whitespace!(parser)
    token = String(take!(token_buffer))
    isempty(token) && return nothing
    return token
end

function parse_edgeweight_token!(
    parser::NewickParserState,
    edgeweight_token::OptionalString,
)::EdgeWeightType
    edgeweight_token === nothing && return nothing
    edgeweight = try
        parse(Float64, edgeweight_token)
    catch
        throw_parse_error(parser, "invalid edge weight `$(edgeweight_token)`")
    end
    isfinite(edgeweight) || throw_parse_error(parser, "edge weights must be finite values")
    edgeweight < 0.0 && throw_parse_error(parser, "edge weights must be non-negative for tranche 4 rooted-network-capable Newick loads")
    return edgeweight
end

function validate_numeric_edge_field_token!(
    parser::NewickParserState,
    field_token::AbstractString,
    field_name::Symbol,
)::Nothing
    parsed_value = try
        parse(Float64, field_token)
    catch
        throw_parse_error(parser, "invalid positional edge field `$(field_name)` value `$(field_token)`")
    end
    isfinite(parsed_value) || throw_parse_error(parser, "positional edge field `$(field_name)` values must be finite")
    parsed_value < 0.0 && throw_parse_error(parser, "positional edge field `$(field_name)` values must be non-negative for tranche 4 rooted-network-capable Newick loads")
    return nothing
end

function append_positional_edge_annotation!(
    edge_annotations::Dict{Symbol, String},
    field_name::Symbol,
    field_value::String,
)::Nothing
    haskey(edge_annotations, field_name) && throw(ArgumentError("Duplicate retained edge annotation field `$(field_name)` is not supported within one row."))
    edge_annotations[field_name] = field_value
    return nothing
end

function append_parsed_annotations!(
    destination::Dict{Symbol, String},
    source::Dict{Symbol, String},
    scope::AbstractString,
)::Nothing
    for (annotation_name, annotation_value) in source
        haskey(destination, annotation_name) && throw(ArgumentError("Duplicate retained $(scope) annotation field `$(annotation_name)` is not supported within one row."))
        destination[annotation_name] = annotation_value
    end
    return nothing
end

function parser_at_end(parser::NewickParserState)::Bool
    return parser.index > lastindex(parser.text)
end

function parser_peek(parser::NewickParserState)::Union{Nothing, Char}
    parser_at_end(parser) && return nothing
    return parser.text[parser.index]
end

function advance!(parser::NewickParserState)::Char
    current_character = parser_peek(parser)
    current_character === nothing && throw_parse_error(parser, "unexpected end of input")
    parser.index = nextind(parser.text, parser.index)
    return current_character
end

function skip_whitespace!(parser::NewickParserState)::Nothing
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        isspace(current_character) || break
        advance!(parser)
    end
    return nothing
end

function throw_parse_error(parser::NewickParserState, message::AbstractString)::Nothing
    line_number, column_number = parser_location(parser)
    source_name = parser.source_label === nothing ? "<input>" : parser.source_label
    throw(ArgumentError("Newick parse error in $(source_name) at line $(line_number), column $(column_number): $(message)"))
end

function parser_location(parser::NewickParserState)::Tuple{Int, Int}
    line_number = 1
    column_number = 1
    idx = firstindex(parser.text)
    while idx < parser.index && idx <= lastindex(parser.text)
        current_character = parser.text[idx]
        if current_character == '\n'
            line_number += 1
            column_number = 1
        else
            column_number += 1
        end
        idx = nextind(parser.text, idx)
    end
    return line_number, column_number
end
