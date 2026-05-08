using MetaGraphsNext

struct PublicSurfaceBranchAVertexData
    label::String
    posterior::Union{Nothing, String}
end

function PublicSurfaceBranchAVertexData(nodedata::LineagesIO.NodeRowRef)
    posterior = :posterior in Tables.columnnames(nodedata) ?
        LineagesIO.node_property(nodedata, :posterior) : nothing
    return PublicSurfaceBranchAVertexData(
        String(LineagesIO.node_property(nodedata, :label)),
        posterior === nothing ? nothing : string(posterior),
    )
end

Base.:(==)(lhs::PublicSurfaceBranchAVertexData, rhs::PublicSurfaceBranchAVertexData) =
    lhs.label == rhs.label && lhs.posterior == rhs.posterior

struct MissingPublicSurfaceBranchAVertexData end

struct PublicSurfaceBranchAEdgeData
    edgeweight::LineagesIO.EdgeWeightType
    support::Union{Nothing, String}
end

function PublicSurfaceBranchAEdgeData(
    edgeweight::LineagesIO.EdgeWeightType,
    edgedata::LineagesIO.EdgeRowRef,
)
    support = :support in Tables.columnnames(edgedata) ?
        LineagesIO.edge_property(edgedata, :support) : nothing
    return PublicSurfaceBranchAEdgeData(
        edgeweight,
        support === nothing ? nothing : string(support),
    )
end

Base.:(==)(lhs::PublicSurfaceBranchAEdgeData, rhs::PublicSurfaceBranchAEdgeData) =
    lhs.edgeweight == rhs.edgeweight && lhs.support == rhs.support

struct MissingPublicSurfaceBranchAEdgeData end

function public_surface_branch_a_metagraph_target()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        PublicSurfaceBranchAVertexData,
        PublicSurfaceBranchAEdgeData,
        nothing,
        edge -> edge.edgeweight === nothing ? 1.0 : edge.edgeweight,
        1.0,
    )
end

@testset "MetaGraphsNext read_lineages public surface parity — tree node-type" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"),
    )
    direct_store = LineagesIO.read_lineages(fixture_path, MetaGraphsNext.MetaGraph)
    wrapper_store = load(fixture_path, MetaGraphsNext.MetaGraph)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test metagraphsnext_table_snapshot(direct_asset.node_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.node_table)
    @test metagraphsnext_table_snapshot(direct_asset.edge_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode == wrapper_asset.basenode
    @test direct_asset.basenode == Symbol(1)
    @test metagraphsnext_graph_contract(direct_asset.graph) ==
        metagraphsnext_graph_contract(wrapper_asset.graph)
end

@testset "MetaGraphsNext read_lineages public surface parity — custom metadata" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    direct_target = public_surface_branch_a_metagraph_target()
    direct_store = LineagesIO.read_lineages(fixture_path, direct_target)
    wrapper_target = public_surface_branch_a_metagraph_target()
    wrapper_store = load(fixture_path, wrapper_target)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test direct_asset.graph === direct_target
    @test wrapper_asset.graph === wrapper_target
    @test metagraphsnext_table_snapshot(direct_asset.node_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.node_table)
    @test metagraphsnext_table_snapshot(direct_asset.edge_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode == wrapper_asset.basenode
    @test direct_asset.basenode == Symbol(1)
    @test metagraphsnext_vertex_data_snapshot(direct_asset.graph) ==
        metagraphsnext_vertex_data_snapshot(wrapper_asset.graph)
    @test metagraphsnext_graph_contract(direct_asset.graph) ==
        metagraphsnext_graph_contract(wrapper_asset.graph)
    @test direct_target[Symbol(1)] == PublicSurfaceBranchAVertexData("Root", "0.99")
    @test direct_target[Symbol(6), Symbol(4)] == PublicSurfaceBranchAEdgeData(0.0, "55")
end

@testset "MetaGraphsNext read_lineages public surface parity — missing vertex constructor" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"),
    )
    direct_target = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        MissingPublicSurfaceBranchAVertexData,
        Float64,
        nothing,
        identity,
        0.0,
    )
    direct_error = capture_expected_load_error() do
        LineagesIO.read_lineages(fixture_path, direct_target)
    end
    wrapper_target = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        MissingPublicSurfaceBranchAVertexData,
        Float64,
        nothing,
        identity,
        0.0,
    )
    wrapper_error = capture_expected_load_error() do
        load(fixture_path, wrapper_target)
    end

    @test direct_error isa MethodError
    @test wrapper_error isa MethodError
    direct_text = sprint(showerror, direct_error)
    wrapper_text = sprint(showerror, wrapper_error)
    @test occursin("MissingPublicSurfaceBranchAVertexData", direct_text)
    @test occursin("MissingPublicSurfaceBranchAVertexData", wrapper_text)
    @test occursin("NodeRowRef", direct_text)
    @test occursin("NodeRowRef", wrapper_text)
    @test !occursin("add_node_to_metagraph!", direct_text)
    @test !occursin("add_node_to_metagraph!", wrapper_text)
end

@testset "MetaGraphsNext read_lineages public surface parity — missing edge constructor" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    direct_target = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        MissingPublicSurfaceBranchAEdgeData,
        nothing,
        edge -> 1.0,
        1.0,
    )
    direct_error = capture_expected_load_error() do
        LineagesIO.read_lineages(fixture_path, direct_target)
    end
    wrapper_target = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        MissingPublicSurfaceBranchAEdgeData,
        nothing,
        edge -> 1.0,
        1.0,
    )
    wrapper_error = capture_expected_load_error() do
        load(fixture_path, wrapper_target)
    end

    @test direct_error isa MethodError
    @test wrapper_error isa MethodError
    direct_text = sprint(showerror, direct_error)
    wrapper_text = sprint(showerror, wrapper_error)
    @test occursin("MissingPublicSurfaceBranchAEdgeData", direct_text)
    @test occursin("MissingPublicSurfaceBranchAEdgeData", wrapper_text)
    @test occursin("EdgeRowRef", direct_text)
    @test occursin("EdgeRowRef", wrapper_text)
    @test !occursin("add_edge_to_metagraph!", direct_text)
    @test !occursin("add_edge_to_metagraph!", wrapper_text)
end

@testset "MetaGraphsNext read_lineages public surface parity — supplied instance" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    direct_target = weighted_metagraph_target()
    direct_store = LineagesIO.read_lineages(fixture_path, direct_target)
    wrapper_target = weighted_metagraph_target()
    wrapper_store = load(fixture_path, wrapper_target)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test direct_asset.graph === direct_target
    @test wrapper_asset.graph === wrapper_target
    @test metagraphsnext_table_snapshot(direct_asset.node_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.node_table)
    @test metagraphsnext_table_snapshot(direct_asset.edge_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode == wrapper_asset.basenode
    @test direct_asset.basenode == Symbol(1)
    @test metagraphsnext_graph_contract(direct_asset.graph) ==
        metagraphsnext_graph_contract(wrapper_asset.graph)
end
