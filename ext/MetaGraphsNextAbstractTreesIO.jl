module MetaGraphsNextAbstractTreesIO

using AbstractTrees
using LineagesIO
using MetaGraphsNext

const MetaGraphsNextIOExt = Base.get_extension(LineagesIO, :MetaGraphsNextIO)

MetaGraphsNextIOExt === nothing && error(
    "`MetaGraphsNextIO` must be loaded before `MetaGraphsNextAbstractTreesIO`.",
)

const MetaGraphsNextNodeHandle = MetaGraphsNextIOExt.MetaGraphsNextNodeHandle
const MetaGraphsNextTreeView = MetaGraphsNextIOExt.MetaGraphsNextTreeView

function AbstractTrees.children(
    treeview::ViewT,
) where {ViewT <: MetaGraphsNextTreeView}
    nodehandle = getfield(treeview, :nodehandle)
    graph = getfield(nodehandle, :graph)
    nodekey = MetaGraphsNextIOExt.bound_nodekey(nodehandle)
    nodecode = MetaGraphsNext.code_for(graph, MetaGraphsNextIOExt.node_label(nodekey))

    child_views = ViewT[]
    for child_code in MetaGraphsNext.Graphs.outneighbors(graph, nodecode)
        child_label = MetaGraphsNext.label_for(graph, child_code)
        child_handle = MetaGraphsNextNodeHandle(
            graph,
            MetaGraphsNextIOExt.label_nodekey(child_label),
        )
        push!(
            child_views,
            ViewT(
                child_handle,
                getfield(treeview, :node_table),
                getfield(treeview, :edge_table),
            ),
        )
    end
    return child_views
end

AbstractTrees.NodeType(::Type{ViewT}) where {ViewT <: MetaGraphsNextTreeView} = AbstractTrees.HasNodeType()
AbstractTrees.nodetype(::Type{ViewT}) where {ViewT <: MetaGraphsNextTreeView} = ViewT
AbstractTrees.ChildIndexing(::Type{ViewT}) where {ViewT <: MetaGraphsNextTreeView} = AbstractTrees.IndexedChildren()
AbstractTrees.childtype(::Type{ViewT}) where {ViewT <: MetaGraphsNextTreeView} = ViewT
AbstractTrees.childrentype(::Type{ViewT}) where {ViewT <: MetaGraphsNextTreeView} = Vector{ViewT}

end
