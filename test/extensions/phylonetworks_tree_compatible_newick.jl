using PhyloNetworks

@testset "PhyloNetworks tree-compatible rooted Newick materialization" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, PhyloNetworks.HybridNetwork)
    asset = first(store.graphs)
    graph = asset.materialized

    @test graph isa PhyloNetworks.HybridNetwork
    @test graph.numhybrids == 0
    @test graph.numnodes == 5
    @test graph.numedges == 4
    @test graph.numtaxa == 3
    @test graph.isrooted

    root = graph.node[graph.rooti]
    inner = phylonetworks_node(graph, 2)

    @test root.number == 1
    @test root.name == "Root"
    @test phylonetworks_child_numbers(root) == [2, 5]
    @test phylonetworks_child_numbers(inner) == [3, 4]
    @test Tables.getcolumn(asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]
end

@testset "PhyloNetworks supplied-target binding" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    target = PhyloNetworks.HybridNetwork()
    store = load(fixture_path, target)
    asset = first(store.graphs)
    graph = asset.materialized

    @test graph === target
    @test graph.numnodes == 7
    @test graph.numedges == 7
    @test graph.numhybrids == 1
    @test graph.isrooted
    @test phylonetworks_child_numbers(graph.node[graph.rooti]) == [2, 6]
    @test sort([node.number for node in graph.hybrid]) == [4]
end
