module MetaGraphsNextAbstractTreesIO

using AbstractTrees
using LineagesIO
using MetaGraphsNext

const MetaGraphsNextIOExt = Base.get_extension(LineagesIO, :MetaGraphsNextIO)

MetaGraphsNextIOExt === nothing && error(
    "`MetaGraphsNextIO` must be loaded before `MetaGraphsNextAbstractTreesIO`.",
)

const ConcreteMetaGraphsNextTreeView = MetaGraphsNextIOExt.ConcreteMetaGraphsNextTreeView

function AbstractTrees.children(
    treeview::ViewT,
) where {ViewT <: ConcreteMetaGraphsNextTreeView}
    graph = getfield(treeview, :graph)
    nodekey = getfield(treeview, :nodekey)
    nodecode = MetaGraphsNext.code_for(graph, MetaGraphsNextIOExt.node_label(nodekey))

    child_views = ViewT[]
    for child_code in MetaGraphsNext.Graphs.outneighbors(graph, nodecode)
        child_label = MetaGraphsNext.label_for(graph, child_code)
        push!(
            child_views,
            ViewT(
                graph,
                MetaGraphsNextIOExt.label_nodekey(child_label),
                getfield(treeview, :node_table),
                getfield(treeview, :edge_table),
            ),
        )
    end
    return child_views
end

AbstractTrees.NodeType(::Type{ViewT}) where {ViewT <: ConcreteMetaGraphsNextTreeView} = AbstractTrees.HasNodeType()
AbstractTrees.nodetype(::Type{ViewT}) where {ViewT <: ConcreteMetaGraphsNextTreeView} = ViewT
AbstractTrees.ChildIndexing(::Type{ViewT}) where {ViewT <: ConcreteMetaGraphsNextTreeView} = AbstractTrees.IndexedChildren()
AbstractTrees.childtype(::Type{ViewT}) where {ViewT <: ConcreteMetaGraphsNextTreeView} = ViewT
AbstractTrees.childrentype(::Type{ViewT}) where {ViewT <: ConcreteMetaGraphsNextTreeView} = Vector{ViewT}

end
