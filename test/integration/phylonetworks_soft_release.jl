using FileIO
using PhyloNetworks

function soft_release_child_numbers(
    node::PhyloNetworks.Node,
)::Vector{Int}
    return sort!(
        [
            PhyloNetworks.getchild(edge).number for
            edge in node.edge if PhyloNetworks.getparent(edge) === node
        ],
    )
end

@testset "PhyloNetworks soft-release rooted-network workflow" begin
    network_path = abspath(
        joinpath(
            @__DIR__,
            "..",
            "fixtures",
            "rooted_network_with_annotations.nwk",
        ),
    )
    store = load(network_path, PhyloNetworks.HybridNetwork)
    asset = first(store.graphs)
    graph = asset.materialized

    @test graph isa PhyloNetworks.HybridNetwork
    @test asset.index == 1
    @test asset.source_idx == 1
    @test asset.collection_idx == 1
    @test asset.collection_graph_idx == 1
    @test asset.source_path == network_path
    @test Tables.columnnames(asset.node_table) == (:nodekey, :label, :posterior)
    @test Tables.columnnames(asset.edge_table) == (
        :edgekey,
        :src_nodekey,
        :dst_nodekey,
        :edgeweight,
        :phase,
        :branch,
        :gamma,
        :support,
    )
    @test graph.isrooted
    @test graph.numnodes == 7
    @test graph.numedges == 7
    @test graph.numhybrids == 1
    @test soft_release_child_numbers(graph.node[graph.rooti]) == [2, 6]
    @test LineagesIO.node_property(asset.node_table, 4, :posterior) == "0.44"
    @test LineagesIO.edge_property(asset.edge_table, 3, :gamma) == "0.8"
    @test LineagesIO.edge_property(asset.edge_table, 6, :branch) == "minor"

    roundtrip_text = PhyloNetworks.writenewick(graph)
    roundtrip_graph = PhyloNetworks.readnewick(roundtrip_text)
    @test roundtrip_graph isa PhyloNetworks.HybridNetwork
    @test roundtrip_graph.numhybrids == graph.numhybrids
    @test roundtrip_graph.numtaxa == graph.numtaxa

    new_leaf = PhyloNetworks.addChild!(graph, only(graph.hybrid))
    @test new_leaf.number > Tables.getcolumn(asset.node_table, :nodekey)[end]
end

@testset "PhyloNetworks soft-release tree-compatible rooted workflow" begin
    ambiguous_tree_path = abspath(
        joinpath(
            @__DIR__,
            "..",
            "..",
            "examples",
            "data",
            "phylonetworks_mwe02_tree_compatible_rooted.txt",
        ),
    )
    ambiguous_error = capture_expected_load_error() do
        load(ambiguous_tree_path, PhyloNetworks.HybridNetwork)
    end
    @test ambiguous_error isa ErrorException
    @test occursin("resolve the ambiguity", sprint(showerror, ambiguous_error))
    @test occursin("File{format\"FMT\"}", sprint(showerror, ambiguous_error))

    store = load(
        File{format"Newick"}(ambiguous_tree_path),
        PhyloNetworks.HybridNetwork,
    )
    asset = first(store.graphs)
    graph = asset.materialized

    @test graph isa PhyloNetworks.HybridNetwork
    @test asset.source_path == ambiguous_tree_path
    @test graph.isrooted
    @test graph.numnodes == 5
    @test graph.numedges == 4
    @test graph.numhybrids == 0
    @test soft_release_child_numbers(graph.node[graph.rooti]) == [2, 5]
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
    @test [node.name for node in graph.leaf] == ["A", "LineagesIO__unnamed_leaf__4", "C"]

    roundtrip_text = PhyloNetworks.writenewick(graph)
    roundtrip_graph = PhyloNetworks.readnewick(roundtrip_text)
    @test roundtrip_graph isa PhyloNetworks.HybridNetwork
    @test roundtrip_graph.numhybrids == 0
    @test roundtrip_graph.numtaxa == graph.numtaxa
    @test occursin("LineagesIO__unnamed_leaf__4", roundtrip_text)
end

@testset "PhyloNetworks soft-release supplied-target boundary" begin
    network_path = abspath(
        joinpath(
            @__DIR__,
            "..",
            "fixtures",
            "rooted_network_with_annotations.nwk",
        ),
    )
    target = PhyloNetworks.HybridNetwork()
    store = load(network_path, target)
    asset = first(store.graphs)

    @test asset.materialized === target
    @test target.isrooted
    @test target.numnodes == 7
    @test target.numedges == 7
    @test target.numhybrids == 1

    occupied_target = PhyloNetworks.HybridNetwork()
    PhyloNetworks.pushNode!(
        occupied_target,
        PhyloNetworks.Node(999, true, false),
    )
    occupied_error = capture_expected_load_error() do
        load(network_path, occupied_target)
    end
    @test occupied_error isa ArgumentError
    @test occursin("must be empty", sprint(showerror, occupied_error))
end
