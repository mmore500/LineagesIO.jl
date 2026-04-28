using AbstractTrees
using MetaGraphsNext

@testset "MetaGraphsNext AbstractTrees wrapper" begin
    @test Base.get_extension(LineagesIO, :MetaGraphsNextAbstractTreesIO) !== nothing

    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    store = load(fixture_path, MetaGraphsNext.MetaGraph)
    asset = first(store.graphs)

    tree_view = LineagesIO.MetaGraphsNextTreeView(asset)

    child_views = AbstractTrees.children(tree_view)
    @test length(child_views) == 2
    @test [child_view.nodekey for child_view in child_views] == [2, 5]

    preorder = collect(AbstractTrees.PreOrderDFS(tree_view))
    @test all(node -> node isa typeof(tree_view), preorder)
    @test [node.nodekey for node in preorder] == [1, 2, 3, 4, 5]

    @test AbstractTrees.NodeType(typeof(tree_view)) isa AbstractTrees.HasNodeType
    @test AbstractTrees.ChildIndexing(typeof(tree_view)) isa AbstractTrees.IndexedChildren
    @test AbstractTrees.nodetype(typeof(tree_view)) == typeof(tree_view)
    @test AbstractTrees.childtype(typeof(tree_view)) == typeof(tree_view)
end
