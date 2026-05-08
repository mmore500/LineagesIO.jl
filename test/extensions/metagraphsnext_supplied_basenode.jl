using MetaGraphsNext

struct SuppliedBranchAVertexData
    label::String
    posterior::Union{Nothing, String}
end

function SuppliedBranchAVertexData(nodedata::LineagesIO.NodeRowRef)
    posterior = :posterior in Tables.columnnames(nodedata) ?
        LineagesIO.node_property(nodedata, :posterior) : nothing
    return SuppliedBranchAVertexData(
        String(LineagesIO.node_property(nodedata, :label)),
        posterior === nothing ? nothing : string(posterior),
    )
end

Base.:(==)(lhs::SuppliedBranchAVertexData, rhs::SuppliedBranchAVertexData) =
    lhs.label == rhs.label && lhs.posterior == rhs.posterior

struct MissingSuppliedBranchAVertexData end

struct SuppliedBranchAEdgeData
    edgeweight::LineagesIO.EdgeWeightType
    support::Union{Nothing, String}
end

function SuppliedBranchAEdgeData(
    edgeweight::LineagesIO.EdgeWeightType,
    edgedata::LineagesIO.EdgeRowRef,
)
    support = :support in Tables.columnnames(edgedata) ?
        LineagesIO.edge_property(edgedata, :support) : nothing
    return SuppliedBranchAEdgeData(
        edgeweight,
        support === nothing ? nothing : string(support),
    )
end

Base.:(==)(lhs::SuppliedBranchAEdgeData, rhs::SuppliedBranchAEdgeData) =
    lhs.edgeweight == rhs.edgeweight && lhs.support == rhs.support

struct MissingSuppliedBranchAEdgeData end

function supplied_branch_a_vertex_graph()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        SuppliedBranchAVertexData,
        Float64,
        nothing,
        identity,
        0.0,
    )
end

function supplied_branch_a_network_graph()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        SuppliedBranchAVertexData,
        SuppliedBranchAEdgeData,
        nothing,
        edge -> edge.edgeweight === nothing ? 1.0 : edge.edgeweight,
        1.0,
    )
end

function missing_supplied_branch_a_edge_graph()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        Nothing,
        MissingSuppliedBranchAEdgeData,
        nothing,
        edge -> 1.0,
        1.0,
    )
end

@testset "MetaGraphsNext supplied-basenode binding" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        Nothing,
    )
    store = load(fixture_path, graph)
    asset = first(store.graphs)

    @test asset.graph === graph
    @test asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(graph) == 5
    @test MetaGraphsNext.Graphs.ne(graph) == 4
    @test LineagesIO.node_property(asset.node_table, 1, :posterior) == "0.99"

    multi_graph_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_basenode_binding_source.trees"))
    multi_graph_error = capture_expected_load_error() do
        load(multi_graph_path, extension.default_metagraph())
    end
    @test multi_graph_error isa ArgumentError
    @test occursin("exactly one graph", sprint(showerror, multi_graph_error))

    occupied_graph = extension.default_metagraph()
    MetaGraphsNext.Graphs.add_vertex!(occupied_graph, Symbol(999))
    occupied_error = capture_expected_load_error() do
        load(fixture_path, occupied_graph)
    end
    @test occupied_error isa ArgumentError
    @test occursin("must be empty", sprint(showerror, occupied_error))

    wrong_label_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        String,
        Nothing,
        Nothing,
    )
    wrong_label_error = capture_expected_load_error() do
        load(fixture_path, wrong_label_graph)
    end
    @test wrong_label_error isa ArgumentError
    @test occursin("must use `Symbol`", sprint(showerror, wrong_label_error))
end

@testset "MetaGraphsNext supplied-instance EdgeData dispatch" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))

    float_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        Nothing,
        Float64,
        nothing,
        identity,
        0.0,
    )
    float_store = load(fixture_path, float_graph)
    float_asset = first(float_store.graphs)

    @test float_asset.graph === float_graph
    @test float_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(float_graph) == 5
    @test MetaGraphsNext.Graphs.ne(float_graph) == 4
    @test float_graph[Symbol(1), Symbol(2)] ≈ 2.0   # Root→Inner
    @test float_graph[Symbol(2), Symbol(3)] ≈ 1.5   # Inner→A
    @test float_graph[Symbol(2), Symbol(4)] ≈ 0.25  # Inner→(unnamed)

    rowref_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        LineagesIO.NodeRowRef,
        LineagesIO.EdgeRowRef,
        nothing,
        ed -> begin
            w = LineagesIO.edge_property(ed, :edgeweight)
            w === nothing ? 1.0 : w
        end,
        1.0,
    )
    rowref_store = load(fixture_path, rowref_graph)
    rowref_asset = first(rowref_store.graphs)
    rowref_graph_out = rowref_asset.graph

    @test rowref_graph_out === rowref_graph
    @test rowref_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(rowref_graph_out) == 5
    @test LineagesIO.node_property(rowref_graph_out[Symbol(1)], :label) == "Root"
    @test LineagesIO.edge_property(rowref_graph_out[Symbol(1), Symbol(2)], :edgeweight) ≈ 2.0
end

@testset "MetaGraphsNext supplied-instance custom metadata — Branch A" begin
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    network_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )

    vertex_graph = supplied_branch_a_vertex_graph()
    vertex_store = load(tree_path, vertex_graph)
    vertex_asset = first(vertex_store.graphs)

    @test vertex_asset.graph === vertex_graph
    @test vertex_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(vertex_graph) == 5
    @test MetaGraphsNext.Graphs.ne(vertex_graph) == 4
    @test vertex_graph[Symbol(1)] == SuppliedBranchAVertexData("Root", nothing)
    @test vertex_graph[Symbol(3)] == SuppliedBranchAVertexData("A", nothing)
    @test vertex_graph[Symbol(2), Symbol(3)] ≈ 1.5
    @test LineagesIO.node_property(vertex_asset.node_table, 1, :label) == "Root"

    network_graph = supplied_branch_a_network_graph()
    network_store = load(network_path, network_graph)
    network_asset = first(network_store.graphs)

    @test network_asset.graph === network_graph
    @test network_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(network_graph) == 7
    @test MetaGraphsNext.Graphs.ne(network_graph) == 7
    @test network_graph[Symbol(1)] == SuppliedBranchAVertexData("Root", "0.99")
    @test network_graph[Symbol(6), Symbol(4)] == SuppliedBranchAEdgeData(0.0, "55")
    @test MetaGraphsNext.Graphs.weights(network_graph)[
        MetaGraphsNext.code_for(network_graph, Symbol(6)),
        MetaGraphsNext.code_for(network_graph, Symbol(4)),
    ] == 0.0
    @test LineagesIO.edge_property(network_asset.edge_table, 6, :support) == "55"

    missing_vertex_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        MissingSuppliedBranchAVertexData,
        Float64,
        nothing,
        identity,
        0.0,
    )
    missing_vertex_error = capture_expected_load_error() do
        load(tree_path, missing_vertex_graph)
    end
    @test missing_vertex_error isa MethodError
    missing_vertex_text = sprint(showerror, missing_vertex_error)
    @test occursin("MissingSuppliedBranchAVertexData", missing_vertex_text)
    @test occursin("NodeRowRef", missing_vertex_text)
    @test !occursin("add_node_to_metagraph!", missing_vertex_text)

    missing_edge_graph = missing_supplied_branch_a_edge_graph()
    missing_edge_error = capture_expected_load_error() do
        load(network_path, missing_edge_graph)
    end
    @test missing_edge_error isa MethodError
    missing_edge_text = sprint(showerror, missing_edge_error)
    @test occursin("MissingSuppliedBranchAEdgeData", missing_edge_text)
    @test occursin("EdgeRowRef", missing_edge_text)
    @test !occursin("add_edge_to_metagraph!", missing_edge_text)
    @test MetaGraphsNext.Graphs.nv(missing_edge_graph) == 0
    @test MetaGraphsNext.Graphs.ne(missing_edge_graph) == 0

    missing_edge_retry_error = capture_expected_load_error() do
        load(network_path, missing_edge_graph)
    end
    @test missing_edge_retry_error isa MethodError
    missing_edge_retry_text = sprint(showerror, missing_edge_retry_error)
    @test missing_edge_retry_text == missing_edge_text
    @test !occursin("must be empty", missing_edge_retry_text)
    @test MetaGraphsNext.Graphs.nv(missing_edge_graph) == 0
    @test MetaGraphsNext.Graphs.ne(missing_edge_graph) == 0
end
