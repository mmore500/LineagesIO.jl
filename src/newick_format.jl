struct ParsedNewickNode
    label::String
    node_annotations::Dict{Symbol, String}
    edgeweight::EdgeWeightType
    edge_annotations::Dict{Symbol, String}
    children::Vector{ParsedNewickNode}
end

mutable struct NewickParserState
    text::String
    index::Int
    source_label::OptionalString
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
    root::ParsedNewickNode,
    graph_index::Int,
    source_path::OptionalString,
)::LineageGraphAsset
    root.edgeweight === nothing || throw(ArgumentError("Simple rooted Newick root incoming edge weights are out of scope for tranche 2 loads."))
    isempty(root.edge_annotations) || throw(ArgumentError("Simple rooted Newick root incoming edge annotations are out of scope for tranche 2 loads."))

    nodekeys = StructureKeyType[]
    labels = String[]
    node_annotation_rows = Dict{Symbol, String}[]
    node_annotation_names = Symbol[]

    edgekeys = StructureKeyType[]
    src_nodekeys = StructureKeyType[]
    dst_nodekeys = StructureKeyType[]
    edgeweights = EdgeWeightType[]
    edge_annotation_rows = Dict{Symbol, String}[]
    edge_annotation_names = Symbol[]

    append_graph_tables!(
        root,
        nothing,
        nodekeys,
        labels,
        node_annotation_rows,
        node_annotation_names,
        edgekeys,
        src_nodekeys,
        dst_nodekeys,
        edgeweights,
        edge_annotation_rows,
        edge_annotation_names,
    )

    node_table = NodeTable(
        nodekey = nodekeys,
        label = labels,
        annotation_columns = build_annotation_columns(node_annotation_rows, node_annotation_names),
    )
    edge_table = EdgeTable(
        edgekey = edgekeys,
        src_nodekey = src_nodekeys,
        dst_nodekey = dst_nodekeys,
        edgeweight = edgeweights,
        annotation_columns = build_annotation_columns(edge_annotation_rows, edge_annotation_names),
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

function append_graph_tables!(
    node::ParsedNewickNode,
    parent_nodekey::Union{Nothing, StructureKeyType},
    nodekeys::Vector{StructureKeyType},
    labels::Vector{String},
    node_annotation_rows::Vector{Dict{Symbol, String}},
    node_annotation_names::Vector{Symbol},
    edgekeys::Vector{StructureKeyType},
    src_nodekeys::Vector{StructureKeyType},
    dst_nodekeys::Vector{StructureKeyType},
    edgeweights::Vector{EdgeWeightType},
    edge_annotation_rows::Vector{Dict{Symbol, String}},
    edge_annotation_names::Vector{Symbol},
)::StructureKeyType
    nodekey = StructureKeyType(length(nodekeys) + 1)
    push!(nodekeys, nodekey)
    push!(labels, node.label)
    push!(node_annotation_rows, node.node_annotations)
    append_annotation_names!(node_annotation_names, node.node_annotations)

    if parent_nodekey !== nothing
        edgekey = StructureKeyType(length(edgekeys) + 1)
        push!(edgekeys, edgekey)
        push!(src_nodekeys, parent_nodekey)
        push!(dst_nodekeys, nodekey)
        push!(edgeweights, node.edgeweight)
        push!(edge_annotation_rows, node.edge_annotations)
        append_annotation_names!(edge_annotation_names, node.edge_annotations)
    end

    for child in node.children
        append_graph_tables!(
            child,
            nodekey,
            nodekeys,
            labels,
            node_annotation_rows,
            node_annotation_names,
            edgekeys,
            src_nodekeys,
            dst_nodekeys,
            edgeweights,
            edge_annotation_rows,
            edge_annotation_names,
        )
    end
    return nodekey
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
    for annotation_name in keys(annotation_row)
        annotation_name in annotation_names || push!(annotation_names, annotation_name)
    end
    return nothing
end

function parse_newick_source(
    text::String,
    source_label::OptionalString,
)::Vector{ParsedNewickNode}
    parser = NewickParserState(text, firstindex(text), source_label)
    roots = ParsedNewickNode[]
    skip_whitespace!(parser)
    while !parser_at_end(parser)
        push!(roots, parse_graph!(parser))
        skip_whitespace!(parser)
    end
    isempty(roots) && throw(ArgumentError("Newick sources must contain at least one rooted graph."))
    return roots
end

function parse_graph!(parser::NewickParserState)::ParsedNewickNode
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "expected a rooted graph before end of input")
    parser_peek(parser) == ';' && throw_parse_error(parser, "expected a rooted graph before `;`")
    root = parse_subtree!(parser)
    skip_whitespace!(parser)
    parser_peek(parser) == ';' || throw_parse_error(parser, "expected `;` after rooted graph")
    advance!(parser)
    return root
end

function parse_subtree!(parser::NewickParserState)::ParsedNewickNode
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "tree ends prematurely while reading a subtree")
    if parser_peek(parser) == '('
        advance!(parser)
        children = ParsedNewickNode[parse_subtree!(parser)]
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
        label = parse_optional_label!(parser)
        node_annotations = parse_optional_annotations!(parser, "node")
        edgeweight, edge_annotations = parse_optional_edgeweight!(parser)
        return ParsedNewickNode(label, node_annotations, edgeweight, edge_annotations, children)
    end
    label = parse_optional_label!(parser)
    node_annotations = parse_optional_annotations!(parser, "node")
    edgeweight, edge_annotations = parse_optional_edgeweight!(parser)
    return ParsedNewickNode(label, node_annotations, edgeweight, edge_annotations, ParsedNewickNode[])
end

function parse_optional_label!(parser::NewickParserState)::String
    skip_whitespace!(parser)
    parser_at_end(parser) && return ""
    next_character = parser_peek(parser)
    next_character in (',', ')', ';', ':') && return ""
    next_character == '#' && throw_parse_error(parser, "extended Newick hybrid nodes are out of scope for tranche 2 simple rooted Newick loads")
    next_character == '\'' && return parse_quoted_text!(parser, '\'')
    next_character == '"' && return parse_quoted_text!(parser, '"')
    return parse_unquoted_label!(parser)
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
            throw_parse_error(parser, "extended Newick hybrid nodes are out of scope for tranche 2 simple rooted Newick loads")
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
    parser_peek(parser) == '&' || throw_parse_error(parser, "only `[&...]` retained annotation comments are supported for tranche 2 simple rooted Newick loads")
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
            throw_parse_error(parser, "structured retained $(scope) annotation field names are out of scope for tranche 2 simple rooted Newick loads")
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
    next_character == '{' && throw_parse_error(parser, "structured retained $(scope) annotation values such as `{...}` are out of scope for tranche 2 simple rooted Newick loads")
    next_character == '\'' && return parse_quoted_text!(parser, '\'')
    next_character == '"' && return parse_quoted_text!(parser, '"')

    value_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (',', ']')
            break
        elseif current_character == '{'
            throw_parse_error(parser, "structured retained $(scope) annotation values such as `{...}` are out of scope for tranche 2 simple rooted Newick loads")
        elseif current_character == '['
            throw_parse_error(parser, "nested retained $(scope) annotation comments are out of scope for tranche 2 simple rooted Newick loads")
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
    skip_whitespace!(parser)
    append_parsed_annotations!(edge_annotations, parse_optional_annotations!(parser, "edge"), "edge")
    parser_at_end(parser) && throw_parse_error(parser, "expected a numeric edge weight after `:`")
    parser_peek(parser) == ':' && throw_parse_error(parser, "extended Newick edge fields are out of scope for tranche 2 simple rooted Newick loads")
    parser_peek(parser) in (',', ')', ';') && throw_parse_error(parser, "expected a numeric edge weight after `:`")

    token_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (',', ')', ';')
            break
        elseif current_character == '['
            break
        elseif current_character == ':'
            throw_parse_error(parser, "extended Newick edge fields are out of scope for tranche 2 simple rooted Newick loads")
        elseif isspace(current_character)
            break
        end
        print(token_buffer, advance!(parser))
    end
    skip_whitespace!(parser)
    weight_token = String(take!(token_buffer))
    isempty(weight_token) && throw_parse_error(parser, "expected a numeric edge weight after `:`")
    weight = try
        parse(Float64, weight_token)
    catch
        throw_parse_error(parser, "invalid edge weight `$(weight_token)`")
    end
    isfinite(weight) || throw_parse_error(parser, "edge weights must be finite values")
    weight < 0.0 && throw_parse_error(parser, "edge weights must be non-negative for tranche 2 simple rooted Newick loads")

    append_parsed_annotations!(edge_annotations, parse_optional_annotations!(parser, "edge"), "edge")
    skip_whitespace!(parser)
    if !parser_at_end(parser)
        next_character = parser_peek(parser)
        next_character in (',', ')', ';') || throw_parse_error(parser, "edge weights may only be followed by a delimiter or retained `[&...]` annotations")
    end
    return weight, edge_annotations
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
