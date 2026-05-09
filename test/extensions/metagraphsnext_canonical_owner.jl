using AbstractTrees
using MetaGraphsNext

function method_first_argument_type(method::Method)
    signature = Base.unwrap_unionall(method.sig)
    return signature.parameters[2]
end

function metagraphsnext_canonical_child_nodekeys(graph, nodekey::Integer)
    nodecode = MetaGraphsNext.code_for(graph, Symbol(nodekey))
    return [
        parse(Int, String(MetaGraphsNext.label_for(graph, child_code))) for
        child_code in MetaGraphsNext.Graphs.outneighbors(graph, nodecode)
    ]
end

function metagraphsnext_table_snapshot(table)
    names = Tables.columnnames(table)
    return NamedTuple{names}(
        Tuple(collect(Tables.getcolumn(table, name)) for name in names),
    )
end

function metagraphsnext_edge_data_snapshot(graph)
    edge_data = Tuple{Symbol, Symbol, Any}[]
    for src in MetaGraphsNext.Graphs.vertices(graph)
        for dst in MetaGraphsNext.Graphs.outneighbors(graph, src)
            src_label = MetaGraphsNext.label_for(graph, src)
            dst_label = MetaGraphsNext.label_for(graph, dst)
            push!(edge_data, (src_label, dst_label, graph[src_label, dst_label]))
        end
    end
    sort!(edge_data; by = entry -> (String(entry[1]), String(entry[2])))
    return edge_data
end

function metagraphsnext_vertex_data_snapshot(graph)
    vertex_data = Tuple{Symbol, Any}[]
    for code in MetaGraphsNext.Graphs.vertices(graph)
        label = MetaGraphsNext.label_for(graph, code)
        push!(vertex_data, (label, graph[label]))
    end
    sort!(vertex_data; by = entry -> String(entry[1]))
    return vertex_data
end

function metagraphsnext_weight_snapshot(graph)
    weight_entries = Tuple{Int, Int, Float64}[]
    weights = MetaGraphsNext.Graphs.weights(graph)
    for src in MetaGraphsNext.Graphs.vertices(graph)
        for dst in MetaGraphsNext.Graphs.outneighbors(graph, src)
            push!(weight_entries, (src, dst, Float64(weights[src, dst])))
        end
    end
    sort!(weight_entries)
    return weight_entries
end

function metagraphsnext_graph_contract(graph)
    child_map = Pair{Int, Vector{Int}}[]
    for nodekey in 1:MetaGraphsNext.Graphs.nv(graph)
        push!(
            child_map,
            nodekey => metagraphsnext_canonical_child_nodekeys(graph, nodekey),
        )
    end
    return (
        nv = MetaGraphsNext.Graphs.nv(graph),
        ne = MetaGraphsNext.Graphs.ne(graph),
        labels = [
            MetaGraphsNext.label_for(graph, code) for
            code in MetaGraphsNext.Graphs.vertices(graph)
        ],
        child_map = child_map,
        edge_data = metagraphsnext_edge_data_snapshot(graph),
        weights = metagraphsnext_weight_snapshot(graph),
    )
end

function weighted_metagraph_target()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        Float64,
        nothing,
        identity,
        0.0,
    )
end

function handwritten_partial_metagraph_request()
    return MetaGraphsNext.MetaGraph{
        Int,
        MetaGraphsNext.Graphs.SimpleDiGraph{Int},
        Symbol,
        Nothing,
    }
end

function owner_derived_library_created_metagraph_type()::Type
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    return typeof(extension.default_metagraph())
end

struct CanonicalBranchAVertexData
    label::String
    posterior::Union{Nothing, String}
end

function CanonicalBranchAVertexData(nodedata::LineagesIO.NodeRowRef)
    posterior = :posterior in Tables.columnnames(nodedata) ?
        LineagesIO.node_property(nodedata, :posterior) : nothing
    return CanonicalBranchAVertexData(
        String(LineagesIO.node_property(nodedata, :label)),
        posterior === nothing ? nothing : string(posterior),
    )
end

Base.:(==)(lhs::CanonicalBranchAVertexData, rhs::CanonicalBranchAVertexData) =
    lhs.label == rhs.label && lhs.posterior == rhs.posterior

struct MissingCanonicalBranchAVertexData end

struct CanonicalBranchAEdgeData
    edgeweight::LineagesIO.EdgeWeightType
    support::Union{Nothing, String}
end

function CanonicalBranchAEdgeData(
    edgeweight::LineagesIO.EdgeWeightType,
    edgedata::LineagesIO.EdgeRowRef,
)
    support = :support in Tables.columnnames(edgedata) ?
        LineagesIO.edge_property(edgedata, :support) : nothing
    return CanonicalBranchAEdgeData(
        edgeweight,
        support === nothing ? nothing : string(support),
    )
end

Base.:(==)(lhs::CanonicalBranchAEdgeData, rhs::CanonicalBranchAEdgeData) =
    lhs.edgeweight == rhs.edgeweight && lhs.support == rhs.support

struct MissingCanonicalBranchAEdgeData end

struct ThrowingCanonicalBranchAEdgeData
    edgeweight::LineagesIO.EdgeWeightType
    support::Union{Nothing, String}
end

function ThrowingCanonicalBranchAEdgeData(
    edgeweight::LineagesIO.EdgeWeightType,
    edgedata::LineagesIO.EdgeRowRef,
)
    support = :support in Tables.columnnames(edgedata) ?
        LineagesIO.edge_property(edgedata, :support) : nothing
    support == "55" && error("boom55")
    return ThrowingCanonicalBranchAEdgeData(
        edgeweight,
        support === nothing ? nothing : string(support),
    )
end

function canonical_branch_a_metagraph_target()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        CanonicalBranchAVertexData,
        CanonicalBranchAEdgeData,
        nothing,
        edge -> edge.edgeweight === nothing ? 1.0 : edge.edgeweight,
        1.0,
    )
end

function missing_canonical_branch_a_edge_graph()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        MissingCanonicalBranchAEdgeData,
        nothing,
        edge -> 1.0,
        1.0,
    )
end

function throwing_canonical_branch_a_edge_graph()
    return MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        ThrowingCanonicalBranchAEdgeData,
        nothing,
        edge -> edge.edgeweight === nothing ? 1.0 : edge.edgeweight,
        1.0,
    )
end

@testset "MetaGraphsNext canonical owner dispatch and no-shim proof" begin
    extension = Base.get_extension(LineagesIO, :MetaGraphsNextIO)
    @test extension !== nothing

    basenode = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        Nothing,
    )
    request = LineagesIO.BasenodeLoadRequest(
        basenode,
        LineagesIO.construction_handle_type(basenode),
    )
    sample_parents = LineagesIO.build_parent_collection_sample(request)
    dispatch_method = which(
        LineagesIO.add_child,
        (
            typeof(sample_parents),
            LineagesIO.StructureKeyType,
            String,
            Vector{LineagesIO.StructureKeyType},
            Vector{LineagesIO.EdgeWeightType},
        ),
    )

    @test dispatch_method.module ===
        extension
    @test occursin("ext/MetaGraphsNextIO.jl", String(dispatch_method.file))

    extension_multi_parent_methods = [
        method for method in methods(LineagesIO.add_child) if
        method.module === extension &&
        method_first_argument_type(method) <: AbstractVector
    ]
    @test length(extension_multi_parent_methods) == 1
    @test dispatch_method === only(extension_multi_parent_methods)

    graph_vector_dispatch = which(
        LineagesIO.add_child,
        (
            Vector{typeof(basenode)},
            LineagesIO.StructureKeyType,
            String,
            Vector{LineagesIO.StructureKeyType},
            Vector{LineagesIO.EdgeWeightType},
        ),
    )
    @test graph_vector_dispatch.module === LineagesIO
    @test occursin(
        "src/construction.jl",
        String(graph_vector_dispatch.file),
    )
end

@testset "MetaGraphsNext canonical owner parity — tree node-type" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.NodeTypeLoadRequest(MetaGraphsNext.MetaGraph),
    )
    wrapper_store = load(fixture_path, MetaGraphsNext.MetaGraph)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)
    owner_type = owner_derived_library_created_metagraph_type()

    @test metagraphsnext_table_snapshot(direct_asset.node_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.node_table)
    @test metagraphsnext_table_snapshot(direct_asset.edge_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode == wrapper_asset.basenode
    @test direct_asset.basenode == Symbol(1)
    @test typeof(direct_asset.graph) === owner_type
    @test typeof(wrapper_asset.graph) === owner_type
    @test metagraphsnext_graph_contract(direct_asset.graph) ==
        metagraphsnext_graph_contract(wrapper_asset.graph)
    @test [node.nodekey for node in AbstractTrees.PreOrderDFS(LineagesIO.MetaGraphsNextTreeView(direct_asset))] ==
        [node.nodekey for node in AbstractTrees.PreOrderDFS(LineagesIO.MetaGraphsNextTreeView(wrapper_asset))]
end

@testset "MetaGraphsNext canonical owner — exact library-created concrete request" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    requested_type = owner_derived_library_created_metagraph_type()

    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.NodeTypeLoadRequest(requested_type),
    )
    direct_asset = first(direct_store.graphs)

    @test typeof(direct_asset.graph) === requested_type
    @test direct_asset.basenode == Symbol(1)
    @test metagraphsnext_graph_contract(direct_asset.graph) == (
        nv = 5,
        ne = 4,
        labels = [Symbol(1), Symbol(2), Symbol(3), Symbol(4), Symbol(5)],
        child_map = [
            1 => [2, 5],
            2 => [3, 4],
            3 => Int[],
            4 => Int[],
            5 => Int[],
        ],
        edge_data = [
            (Symbol(1), Symbol(2), 2.0),
            (Symbol(1), Symbol(5), nothing),
            (Symbol(2), Symbol(3), 1.5),
            (Symbol(2), Symbol(4), 0.25),
        ],
        weights = [
            (1, 2, 2.0),
            (1, 5, 1.0),
            (2, 3, 1.5),
            (2, 4, 0.25),
        ],
    )
end

@testset "MetaGraphsNext canonical owner — hand-written partial library-created request rejection" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    requested_type = handwritten_partial_metagraph_request()

    direct_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
            LineagesIO.NodeTypeLoadRequest(requested_type),
        )
    end

    @test direct_error isa ArgumentError
    direct_text = sprint(showerror, direct_error)
    @test occursin(string(requested_type), direct_text)
    @test occursin("caller-supplied `MetaGraph` path", direct_text)
    @test occursin("owner-derived concrete type", direct_text)
end

@testset "MetaGraphsNext canonical owner parity — supplied-instance network" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    direct_target = weighted_metagraph_target()
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.BasenodeLoadRequest(
            direct_target,
            LineagesIO.construction_handle_type(direct_target),
        ),
    )
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

@testset "MetaGraphsNext canonical owner parity — supplied-instance custom metadata" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    direct_target = canonical_branch_a_metagraph_target()
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.BasenodeLoadRequest(
            direct_target,
            LineagesIO.construction_handle_type(direct_target),
        ),
    )
    wrapper_target = canonical_branch_a_metagraph_target()
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
    @test direct_target[Symbol(1)] == CanonicalBranchAVertexData("Root", "0.99")
    @test direct_target[Symbol(6), Symbol(4)] == CanonicalBranchAEdgeData(0.0, "55")
end

@testset "MetaGraphsNext canonical owner — missing Branch A constructors" begin
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    network_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )

    missing_vertex_target = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        MissingCanonicalBranchAVertexData,
        Float64,
        nothing,
        identity,
        0.0,
    )
    missing_vertex_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(tree_path),
            LineagesIO.BasenodeLoadRequest(
                missing_vertex_target,
                LineagesIO.construction_handle_type(missing_vertex_target),
            ),
        )
    end
    @test missing_vertex_error isa MethodError
    missing_vertex_text = sprint(showerror, missing_vertex_error)
    @test occursin("MissingCanonicalBranchAVertexData", missing_vertex_text)
    @test occursin("NodeRowRef", missing_vertex_text)
    @test !occursin("add_node_to_metagraph!", missing_vertex_text)

    missing_edge_target = missing_canonical_branch_a_edge_graph()
    missing_edge_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(network_path),
            LineagesIO.BasenodeLoadRequest(
                missing_edge_target,
                LineagesIO.construction_handle_type(missing_edge_target),
            ),
        )
    end
    @test missing_edge_error isa MethodError
    missing_edge_text = sprint(showerror, missing_edge_error)
    @test occursin("MissingCanonicalBranchAEdgeData", missing_edge_text)
    @test occursin("EdgeRowRef", missing_edge_text)
    @test !occursin("add_edge_to_metagraph!", missing_edge_text)
    @test MetaGraphsNext.Graphs.nv(missing_edge_target) == 0
    @test MetaGraphsNext.Graphs.ne(missing_edge_target) == 0

    missing_edge_retry_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(network_path),
            LineagesIO.BasenodeLoadRequest(
                missing_edge_target,
                LineagesIO.construction_handle_type(missing_edge_target),
            ),
        )
    end
    @test missing_edge_retry_error isa MethodError
    missing_edge_retry_text = sprint(showerror, missing_edge_retry_error)
    @test missing_edge_retry_text == missing_edge_text
    @test !occursin("must be empty", missing_edge_retry_text)
    @test MetaGraphsNext.Graphs.nv(missing_edge_target) == 0
    @test MetaGraphsNext.Graphs.ne(missing_edge_target) == 0
end

@testset "MetaGraphsNext canonical owner — multi-parent edge constructor failure" begin
    network_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    throwing_target = throwing_canonical_branch_a_edge_graph()

    thrown_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(network_path),
            LineagesIO.BasenodeLoadRequest(
                throwing_target,
                LineagesIO.construction_handle_type(throwing_target),
            ),
        )
    end

    @test thrown_error isa ErrorException
    @test sprint(showerror, thrown_error) == "boom55"
    @test MetaGraphsNext.Graphs.nv(throwing_target) == 4
    @test MetaGraphsNext.Graphs.ne(throwing_target) == 3
    @test [label for (label, _data) in metagraphsnext_vertex_data_snapshot(throwing_target)] ==
        [Symbol(1), Symbol(2), Symbol(3), Symbol(6)]
    @test [
        (src_label, dst_label) for
        (src_label, dst_label, _data) in metagraphsnext_edge_data_snapshot(throwing_target)
    ] == [
        (Symbol(1), Symbol(2)),
        (Symbol(1), Symbol(6)),
        (Symbol(2), Symbol(3)),
    ]
    @test !haskey(throwing_target, Symbol(4))
end
