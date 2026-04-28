using MetaGraphsNext

function metagraph_child_nodekeys(graph, label_type, nodekey::Integer)
    nodecode = MetaGraphsNext.code_for(graph, label_type(nodekey))
    return [
        MetaGraphsNext.label_for(graph, child_code).nodekey for
        child_code in MetaGraphsNext.Graphs.outneighbors(graph, nodecode)
    ]
end

@testset "MetaGraphsNext simple rooted Newick materialization" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, extension.MetaGraphsNextNodeHandle)
    asset = first(store.graphs)
    rootnode = asset.graph_rootnode
    graph = rootnode.graph

    @test rootnode isa extension.MetaGraphsNextNodeHandle
    @test rootnode.nodekey == 1
    @test MetaGraphsNext.Graphs.nv(graph) == 5
    @test MetaGraphsNext.Graphs.ne(graph) == 4

    for nodekey in 1:5
        label = extension.MetaGraphsNextNodeLabel(nodekey)
        nodecode = MetaGraphsNext.code_for(graph, label)
        @test MetaGraphsNext.label_for(graph, nodecode) == label
    end

    @test metagraph_child_nodekeys(graph, extension.MetaGraphsNextNodeLabel, 1) == [2, 5]
    @test metagraph_child_nodekeys(graph, extension.MetaGraphsNextNodeLabel, 2) == [3, 4]
    @test metagraph_child_nodekeys(graph, extension.MetaGraphsNextNodeLabel, 3) == Int[]
    @test metagraph_child_nodekeys(graph, extension.MetaGraphsNextNodeLabel, 4) == Int[]
    @test metagraph_child_nodekeys(graph, extension.MetaGraphsNextNodeLabel, 5) == Int[]
end
