using PhyloNetworks

function phylonetworks_canonical_node(
    graph::PhyloNetworks.HybridNetwork,
    number::Integer,
)
    matches = [node for node in graph.node if node.number == number]
    @test length(matches) == 1
    return only(matches)
end

function phylonetworks_canonical_child_numbers(node::PhyloNetworks.Node)
    return sort!(
        [
            PhyloNetworks.getchild(edge).number for
            edge in node.edge if PhyloNetworks.getparent(edge) === node
        ],
    )
end

function phylonetworks_table_snapshot(table)
    names = Tables.columnnames(table)
    return NamedTuple{names}(
        Tuple(collect(Tables.getcolumn(table, name)) for name in names),
    )
end

function phylonetworks_graph_contract(graph::PhyloNetworks.HybridNetwork)
    internal_children = Pair{Int, Vector{Int}}[]
    for node in graph.node
        node.leaf && continue
        push!(
            internal_children,
            node.number => phylonetworks_canonical_child_numbers(node),
        )
    end
    sort!(internal_children; by = first)
    hybrid_edges = [
        (
            edge.number,
            edge.ismajor,
            round(edge.gamma; digits = 8),
            round(edge.length; digits = 8),
        ) for edge in graph.edge if edge.hybrid
    ]
    sort!(hybrid_edges)
    return (
        numnodes = graph.numnodes,
        numedges = graph.numedges,
        numhybrids = graph.numhybrids,
        numtaxa = graph.numtaxa,
        isrooted = graph.isrooted,
        basenode_number = graph.node[graph.rooti].number,
        basenode_name = graph.node[graph.rooti].name,
        internal_children = internal_children,
        hybrid_nodes = sort!([node.number for node in graph.hybrid]),
        hybrid_edges = hybrid_edges,
        leaf_names = sort!([String(node.name) for node in graph.leaf]),
    )
end

@testset "PhyloNetworks canonical owner dispatch and anti-regrowth" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    table_asset = first(load(fixture_path).graphs)
    request = LineagesIO.NodeTypeLoadRequest(PhyloNetworks.HybridNetwork)
    basenode_handle = LineagesIO.emit_basenode(
        request,
        LineagesIO.StructureKeyType(1),
        Tables.getcolumn(table_asset.node_table, :label)[1],
        LineagesIO.NodeRowRef(
            table_asset.node_table,
            LineagesIO.StructureKeyType(1),
        ),
    )
    dispatch_method = which(
        LineagesIO.build_parent_collection,
        (typeof(request), Vector{typeof(basenode_handle)}),
    )

    @test dispatch_method.module === LineagesIO
    @test occursin("src/construction.jl", String(dispatch_method.file))

    extension_source = read(
        abspath(joinpath(@__DIR__, "..", "..", "ext", "PhyloNetworksIO.jl")),
        String,
    )
    @test !occursin("reduce(typejoin", extension_source)
    @test !occursin("Any[]", extension_source)
    @test !occursin("Vector{Any}", extension_source)
end

@testset "PhyloNetworks canonical owner parity — rooted-network node-type" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.NodeTypeLoadRequest(PhyloNetworks.HybridNetwork),
    )
    wrapper_store = load(fixture_path, PhyloNetworks.HybridNetwork)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test phylonetworks_table_snapshot(direct_asset.node_table) ==
        phylonetworks_table_snapshot(wrapper_asset.node_table)
    @test phylonetworks_table_snapshot(direct_asset.edge_table) ==
        phylonetworks_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode.number == wrapper_asset.basenode.number
    @test phylonetworks_graph_contract(direct_asset.graph) ==
        phylonetworks_graph_contract(wrapper_asset.graph)
    @test PhyloNetworks.writenewick(direct_asset.graph) ==
        PhyloNetworks.writenewick(wrapper_asset.graph)
end

@testset "PhyloNetworks canonical owner parity — tree-compatible node-type" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.NodeTypeLoadRequest(PhyloNetworks.HybridNetwork),
    )
    wrapper_store = load(fixture_path, PhyloNetworks.HybridNetwork)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test phylonetworks_table_snapshot(direct_asset.node_table) ==
        phylonetworks_table_snapshot(wrapper_asset.node_table)
    @test phylonetworks_table_snapshot(direct_asset.edge_table) ==
        phylonetworks_table_snapshot(wrapper_asset.edge_table)
    @test Tables.getcolumn(direct_asset.node_table, :label) ==
        ["Root", "Inner", "A", "", "C"]
    @test direct_asset.basenode.number == wrapper_asset.basenode.number
    @test phylonetworks_graph_contract(direct_asset.graph) ==
        phylonetworks_graph_contract(wrapper_asset.graph)
    @test all(!isempty, [node.name for node in direct_asset.graph.leaf])
    @test all(!isempty, [node.name for node in wrapper_asset.graph.leaf])
    @test PhyloNetworks.writenewick(direct_asset.graph) ==
        PhyloNetworks.writenewick(wrapper_asset.graph)
end

@testset "PhyloNetworks canonical owner parity — rooted-network supplied target" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    direct_target = PhyloNetworks.HybridNetwork()
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.BasenodeLoadRequest(
            direct_target,
            LineagesIO.construction_handle_type(direct_target),
        ),
    )
    wrapper_target = PhyloNetworks.HybridNetwork()
    wrapper_store = load(fixture_path, wrapper_target)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test direct_asset.graph === direct_target
    @test wrapper_asset.graph === wrapper_target
    @test phylonetworks_table_snapshot(direct_asset.node_table) ==
        phylonetworks_table_snapshot(wrapper_asset.node_table)
    @test phylonetworks_table_snapshot(direct_asset.edge_table) ==
        phylonetworks_table_snapshot(wrapper_asset.edge_table)
    @test direct_asset.basenode.number == wrapper_asset.basenode.number
    @test phylonetworks_graph_contract(direct_asset.graph) ==
        phylonetworks_graph_contract(wrapper_asset.graph)
    @test PhyloNetworks.writenewick(direct_asset.graph) ==
        PhyloNetworks.writenewick(wrapper_asset.graph)
end

@testset "PhyloNetworks canonical owner parity — tree-compatible supplied target" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    direct_target = PhyloNetworks.HybridNetwork()
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.BasenodeLoadRequest(
            direct_target,
            LineagesIO.construction_handle_type(direct_target),
        ),
    )
    wrapper_target = PhyloNetworks.HybridNetwork()
    wrapper_store = load(fixture_path, wrapper_target)

    direct_asset = first(direct_store.graphs)
    wrapper_asset = first(wrapper_store.graphs)

    @test direct_asset.graph === direct_target
    @test wrapper_asset.graph === wrapper_target
    @test phylonetworks_table_snapshot(direct_asset.node_table) ==
        phylonetworks_table_snapshot(wrapper_asset.node_table)
    @test phylonetworks_table_snapshot(direct_asset.edge_table) ==
        phylonetworks_table_snapshot(wrapper_asset.edge_table)
    @test Tables.getcolumn(direct_asset.node_table, :label) ==
        ["Root", "Inner", "A", "", "C"]
    @test direct_asset.basenode.number == wrapper_asset.basenode.number
    @test phylonetworks_graph_contract(direct_asset.graph) ==
        phylonetworks_graph_contract(wrapper_asset.graph)
    @test all(!isempty, [node.name for node in direct_asset.graph.leaf])
    @test all(!isempty, [node.name for node in wrapper_asset.graph.leaf])
    @test PhyloNetworks.writenewick(direct_asset.graph) ==
        PhyloNetworks.writenewick(wrapper_asset.graph)
end
