using PhyloNetworks

@testset "PhyloNetworks hybrid-edge annotation interpretation" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    store = load(fixture_path, PhyloNetworks.HybridNetwork)
    asset = first(store.graphs)
    graph = asset.materialized

    hybrid = phylonetworks_node(graph, 4)
    major_edge = phylonetworks_edge(graph, 3)
    minor_edge = phylonetworks_edge(graph, 6)

    @test major_edge.hybrid
    @test minor_edge.hybrid
    @test PhyloNetworks.getchild(major_edge) === hybrid
    @test PhyloNetworks.getchild(minor_edge) === hybrid
    @test major_edge.ismajor
    @test !minor_edge.ismajor
    @test isapprox(major_edge.gamma, 0.8; atol = 1.0e-8)
    @test isapprox(minor_edge.gamma, 0.2; atol = 1.0e-8)
    @test isapprox(major_edge.length, 1.0; atol = 1.0e-8)
    @test isapprox(minor_edge.length, 0.0; atol = 1.0e-8)
    @test Tables.getcolumn(asset.edge_table, :gamma)[3] == "0.8"
    @test Tables.getcolumn(asset.edge_table, :gamma)[6] == "0.2"
    @test Tables.getcolumn(asset.edge_table, :branch)[3] == "major"
    @test Tables.getcolumn(asset.edge_table, :branch)[6] == "minor"
end
