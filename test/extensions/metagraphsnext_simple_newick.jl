using MetaGraphsNext

function metagraph_child_nodekeys(graph, nodekey::Integer)
    nodecode = MetaGraphsNext.code_for(graph, Symbol(nodekey))
    return [
        parse(Int, String(MetaGraphsNext.label_for(graph, child_code))) for
        child_code in MetaGraphsNext.Graphs.outneighbors(graph, nodecode)
    ]
end

@testset "MetaGraphsNext simple rooted Newick materialization" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, MetaGraphsNext.MetaGraph)
    asset = first(store.graphs)
    graph = asset.graph

    @test graph isa MetaGraphsNext.MetaGraph
    @test asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(graph) == 5
    @test MetaGraphsNext.Graphs.ne(graph) == 4

    for nodekey in 1:5
        label = Symbol(nodekey)
        nodecode = MetaGraphsNext.code_for(graph, label)
        @test MetaGraphsNext.label_for(graph, nodecode) == label
    end

    @test metagraph_child_nodekeys(graph, 1) == [2, 5]
    @test metagraph_child_nodekeys(graph, 2) == [3, 4]
    @test metagraph_child_nodekeys(graph, 3) == Int[]
    @test metagraph_child_nodekeys(graph, 4) == Int[]
    @test metagraph_child_nodekeys(graph, 5) == Int[]

    # Default materialization stores source edge weights; absent weights default to 1.0.
    @test MetaGraphsNext.Graphs.weights(graph)[1, 2] ≈ 2.0   # Root→Inner
    @test MetaGraphsNext.Graphs.weights(graph)[2, 3] ≈ 1.5   # Inner→A
    @test MetaGraphsNext.Graphs.weights(graph)[2, 4] ≈ 0.25  # Inner→(unnamed)
    @test MetaGraphsNext.Graphs.weights(graph)[1, 5] ≈ 1.0   # Root→C, no weight → default
end
