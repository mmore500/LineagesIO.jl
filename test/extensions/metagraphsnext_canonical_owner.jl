using AbstractTrees
using MetaGraphsNext

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

@testset "MetaGraphsNext canonical owner dispatch and no-shim proof" begin
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
        Base.get_extension(LineagesIO, :MetaGraphsNextIO)
    @test occursin("ext/MetaGraphsNextIO.jl", String(dispatch_method.file))
    @test !any(
        method -> occursin(
            "AbstractVector{<:MetaGraph}",
            sprint(show, method.sig),
        ),
        methods(LineagesIO.add_child),
    )

    extension_source = read(
        abspath(joinpath(@__DIR__, "..", "..", "ext", "MetaGraphsNextIO.jl")),
        String,
    )
    @test !occursin("probe shim", extension_source)
    @test !occursin("AbstractVector{<:MetaGraph}", extension_source)
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

    @test metagraphsnext_table_snapshot(direct_asset.node_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.node_table)
    @test metagraphsnext_table_snapshot(direct_asset.edge_table) ==
        metagraphsnext_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode == wrapper_asset.basenode
    @test direct_asset.basenode == Symbol(1)
    @test metagraphsnext_graph_contract(direct_asset.graph) ==
        metagraphsnext_graph_contract(wrapper_asset.graph)
    @test [node.nodekey for node in AbstractTrees.PreOrderDFS(LineagesIO.MetaGraphsNextTreeView(direct_asset))] ==
        [node.nodekey for node in AbstractTrees.PreOrderDFS(LineagesIO.MetaGraphsNextTreeView(wrapper_asset))]
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
