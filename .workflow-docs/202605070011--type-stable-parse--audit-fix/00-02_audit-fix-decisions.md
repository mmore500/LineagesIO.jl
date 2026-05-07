## Global audit finding 1 fix 

Narrow the library-created path to only the one concrete type that default_metagraph() produces, reject everything else at validate_extension_load_target, and redirect users wanting custom VertexData/EdgeData to the supplied-instance path — which is exactly the path that exists for that purpose. The user constructs the empty MetaGraph with their desired parametrization and passes it in. No factory, no protocol, no core surgery. The two paths become coherent: library creates it means you get the default, you supply it means you control the type.


## Global audit finding 2 fix — Parameterized protocol 

The key insight is that the MetaGraph type parameter VertexDataT is already available in the dispatch — add_node_to_metagraph! could be written as:


function add_node_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, VertexDataT},
    nodekey::StructureKeyType,
    nodedata::NodeRowRef,
)::Nothing where {VertexDataT}
    vertex_data = node_row_to_vertex_data(VertexDataT, nodedata)
    add_vertex!(graph, node_label(nodekey), vertex_data) || throw(...)
    return nothing
end
And analogously for edges:


function add_edge_to_metagraph!(
    graph::MetaGraph{<:Any, <:Any, Symbol, <:Any, EdgeDataT},
    src_nodekey, dst_nodekey,
    edgeweight::EdgeWeightType,
    edgedata::EdgeRowRef,
)::Nothing where {EdgeDataT}
    edge_data = edge_row_to_edge_data(EdgeDataT, edgeweight, edgedata)
    add_edge!(graph, node_label(src_nodekey), node_label(dst_nodekey), edge_data) || throw(...)
    return nothing
end
With defaults covering all currently supported shapes:


node_row_to_vertex_data(::Type{Nothing}, ::NodeRowRef) = nothing
node_row_to_vertex_data(::Type{<:NodeRowRef}, nodedata::NodeRowRef) = nodedata

edge_row_to_edge_data(::Type{Nothing}, ::EdgeWeightType, ::EdgeRowRef) = nothing
edge_row_to_edge_data(::Type{<:Real}, weight::EdgeWeightType, ::EdgeRowRef) = something(weight, 1.0)
edge_row_to_edge_data(::Type{<:EdgeRowRef}, ::EdgeWeightType, edgedata::EdgeRowRef) = edgedata
Users extend by implementing the protocol for their own types:


MetaGraphsNextIO.node_row_to_vertex_data(::Type{MyVertex}, nodedata::NodeRowRef) =
    MyVertex(Tables.getcolumn(nodedata, :name), Tables.getcolumn(nodedata, :age))


## Global audit finding 3 fix

The fix is one guard: isconcretetype(HandleT) || throw(ArgumentError(...)) in the BuilderDescriptor constructor at read_lineages.jl:27-35, mirroring the existing ParentCollectionT guard. One line of code plus a test. This one is the most straightforward of the three.