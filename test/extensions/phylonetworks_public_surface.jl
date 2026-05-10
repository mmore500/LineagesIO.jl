using PhyloNetworks

@testset "PhyloNetworks read_lineages public surface parity — rooted-network" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    direct_store = LineagesIO.read_lineages(fixture_path, PhyloNetworks.HybridNetwork)
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

@testset "PhyloNetworks read_lineages public surface parity — tree-compatible" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"),
    )
    direct_store = LineagesIO.read_lineages(fixture_path, PhyloNetworks.HybridNetwork)
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
end

@testset "PhyloNetworks read_lineages public surface parity — supplied target" begin
    fixture_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    direct_target = PhyloNetworks.HybridNetwork()
    direct_store = LineagesIO.read_lineages!(fixture_path, direct_target)
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
end
