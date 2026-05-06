using MetaGraphsNext

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
