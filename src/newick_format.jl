struct ParsedNewickNode
    label::String
    edgeweight::EdgeWeightType
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
    roots = parse_newick_source(text, source_path)
    stored_graphs = [build_stored_graph(root, graph_index, source_path) for (graph_index, root) in enumerate(roots)]
    graph_count = length(stored_graphs)
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
        index = [stored_graph.index for stored_graph in stored_graphs],
        source_idx = [stored_graph.source_idx for stored_graph in stored_graphs],
        collection_idx = [stored_graph.collection_idx for stored_graph in stored_graphs],
        collection_graph_idx = [stored_graph.collection_graph_idx for stored_graph in stored_graphs],
        collection_label = [stored_graph.collection_label for stored_graph in stored_graphs],
        graph_label = [stored_graph.graph_label for stored_graph in stored_graphs],
        node_count = [lineagetable_nrows(stored_graph.node_table) for stored_graph in stored_graphs],
        edge_count = [lineagetable_nrows(stored_graph.edge_table) for stored_graph in stored_graphs],
    )
    graphs = GraphAssetIterator(stored_graphs)
    return LineageGraphStore(
        source_table,
        collection_table,
        graph_table,
        graphs,
    )
end

function build_stored_graph(
    root::ParsedNewickNode,
    graph_index::Int,
    source_path::OptionalString,
)::StoredGraph
    root.edgeweight === nothing || throw(ArgumentError("Simple rooted Newick root branch lengths are out of scope for tranche 1 tables-only loads."))
    nodekeys = StructureKeyType[]
    labels = String[]
    edgekeys = StructureKeyType[]
    src_nodekeys = StructureKeyType[]
    dst_nodekeys = StructureKeyType[]
    edgeweights = EdgeWeightType[]
    append_graph_tables!(root, nothing, nodekeys, labels, edgekeys, src_nodekeys, dst_nodekeys, edgeweights)
    node_table = NodeTable(nodekey = nodekeys, label = labels)
    edge_table = EdgeTable(
        edgekey = edgekeys,
        src_nodekey = src_nodekeys,
        dst_nodekey = dst_nodekeys,
        edgeweight = edgeweights,
    )
    return StoredGraph(
        graph_index,
        1,
        1,
        graph_index,
        nothing,
        nothing,
        node_table,
        edge_table,
        source_path,
    )
end

function append_graph_tables!(
    node::ParsedNewickNode,
    parent_nodekey::Union{Nothing, StructureKeyType},
    nodekeys::Vector{StructureKeyType},
    labels::Vector{String},
    edgekeys::Vector{StructureKeyType},
    src_nodekeys::Vector{StructureKeyType},
    dst_nodekeys::Vector{StructureKeyType},
    edgeweights::Vector{EdgeWeightType},
)::StructureKeyType
    nodekey = StructureKeyType(length(nodekeys) + 1)
    push!(nodekeys, nodekey)
    push!(labels, node.label)
    if parent_nodekey !== nothing
        edgekey = StructureKeyType(length(edgekeys) + 1)
        push!(edgekeys, edgekey)
        push!(src_nodekeys, parent_nodekey)
        push!(dst_nodekeys, nodekey)
        push!(edgeweights, node.edgeweight)
    end
    for child in node.children
        append_graph_tables!(child, nodekey, nodekeys, labels, edgekeys, src_nodekeys, dst_nodekeys, edgeweights)
    end
    return nodekey
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
        edgeweight = parse_optional_edgeweight!(parser)
        return ParsedNewickNode(label, edgeweight, children)
    end
    label = parse_optional_label!(parser)
    edgeweight = parse_optional_edgeweight!(parser)
    return ParsedNewickNode(label, edgeweight, ParsedNewickNode[])
end

function parse_optional_label!(parser::NewickParserState)::String
    skip_whitespace!(parser)
    parser_at_end(parser) && return ""
    next_character = parser_peek(parser)
    next_character in (',', ')', ';', ':') && return ""
    next_character == '[' && throw_parse_error(parser, "comments and retained annotations are not yet supported for tranche 1 Newick loads")
    next_character == '#' && throw_parse_error(parser, "extended Newick hybrid nodes are out of scope for tranche 1 tables-only loads")
    next_character == '\'' && return parse_quoted_label!(parser, '\'')
    next_character == '"' && return parse_quoted_label!(parser, '"')
    return parse_unquoted_label!(parser)
end

function parse_quoted_label!(parser::NewickParserState, quote_character::Char)::String
    advance!(parser)
    label_buffer = IOBuffer()
    while true
        parser_at_end(parser) && throw_parse_error(parser, "quoted labels must be closed before end of input")
        current_character = advance!(parser)
        if current_character == quote_character
            if !parser_at_end(parser) && parser_peek(parser) == quote_character
                print(label_buffer, advance!(parser))
                continue
            end
            break
        end
        print(label_buffer, current_character)
    end
    skip_whitespace!(parser)
    parser_at_end(parser) && return String(take!(label_buffer))
    parser_peek(parser) == '[' && throw_parse_error(parser, "comments and retained annotations are not yet supported for tranche 1 Newick loads")
    return String(take!(label_buffer))
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
            throw_parse_error(parser, "extended Newick hybrid nodes are out of scope for tranche 1 tables-only loads")
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
    next_character == '[' && throw_parse_error(parser, "comments and retained annotations are not yet supported for tranche 1 Newick loads")
    return String(take!(label_buffer))
end

function parse_optional_edgeweight!(parser::NewickParserState)::EdgeWeightType
    skip_whitespace!(parser)
    parser_at_end(parser) && return nothing
    parser_peek(parser) == ':' || return nothing
    advance!(parser)
    skip_whitespace!(parser)
    parser_at_end(parser) && throw_parse_error(parser, "expected a numeric edge weight after `:`")
    parser_peek(parser) == ':' && throw_parse_error(parser, "extended Newick edge fields are out of scope for tranche 1 tables-only loads")
    parser_peek(parser) == '[' && throw_parse_error(parser, "comments and retained annotations are not yet supported for tranche 1 Newick loads")
    token_buffer = IOBuffer()
    while !parser_at_end(parser)
        current_character = parser_peek(parser)
        current_character === nothing && break
        if current_character in (',', ')', ';')
            break
        elseif current_character == '['
            throw_parse_error(parser, "comments and retained annotations are not yet supported for tranche 1 Newick loads")
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
    weight < 0.0 && throw_parse_error(parser, "edge weights must be non-negative for tranche 1 simple rooted Newick loads")
    return weight
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
