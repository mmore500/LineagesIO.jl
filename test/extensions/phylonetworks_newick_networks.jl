using PhyloNetworks

function phylonetworks_node(
    graph::PhyloNetworks.HybridNetwork,
    number::Integer,
)
    matches = [
        node for node in graph.node if node.number == number
    ]
    @test length(matches) == 1
    return only(matches)
end

function phylonetworks_edge(
    graph::PhyloNetworks.HybridNetwork,
    number::Integer,
)
    matches = [
        edge for edge in graph.edge if edge.number == number
    ]
    @test length(matches) == 1
    return only(matches)
end

function phylonetworks_child_numbers(node::PhyloNetworks.Node)
    return sort!(
        [
            PhyloNetworks.getchild(edge).number for
            edge in node.edge if PhyloNetworks.getparent(edge) === node
        ],
    )
end

@testset "PhyloNetworks rooted-network native materialization" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    store = load(fixture_path, PhyloNetworks.HybridNetwork)
    asset = first(store.graphs)
    graph = asset.materialized

    @test graph isa PhyloNetworks.HybridNetwork
    @test graph.numnodes == 7
    @test graph.numedges == 7
    @test graph.numhybrids == 1
    @test graph.numtaxa == 3
    @test graph.isrooted

    root = graph.node[graph.rooti]
    left = phylonetworks_node(graph, 2)
    hybrid = phylonetworks_node(graph, 4)
    right = phylonetworks_node(graph, 6)
    taxon_b = phylonetworks_node(graph, 5)

    @test root.number == 1
    @test root.name == "Root"
    @test !left.hybrid
    @test hybrid.hybrid
    @test !left.leaf
    @test taxon_b.leaf
    @test sort([node.number for node in graph.hybrid]) == [4]
    @test sort([node.number for node in graph.leaf]) == [3, 5, 7]

    @test phylonetworks_child_numbers(root) == [2, 6]
    @test phylonetworks_child_numbers(left) == [3, 4]
    @test phylonetworks_child_numbers(right) == [4, 7]
    @test phylonetworks_child_numbers(hybrid) == [5]
    @test sort([
        edge.number for edge in hybrid.edge
        if edge.hybrid && PhyloNetworks.getchild(edge) === hybrid
    ]) == [3, 6]
end
