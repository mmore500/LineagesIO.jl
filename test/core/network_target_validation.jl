function synthetic_network_asset_for_validation()
    node_table = LineagesIO.NodeTable(
        nodekey = [1, 2, 3, 4, 5],
        label = ["Root", "Left", "Right", "Hybrid", "Leaf"],
        annotation_columns = (
            posterior = ["0.99", "0.81", "0.73", "0.44", "0.52"],
        ),
    )
    edge_table = LineagesIO.EdgeTable(
        edgekey = [1, 2, 3, 4, 5],
        src_nodekey = [1, 1, 2, 3, 4],
        dst_nodekey = [2, 3, 4, 4, 5],
        edgeweight = [2.0, 1.0, 0.8, 0.2, 0.5],
        annotation_columns = (
            kind = [nothing, nothing, "major", "minor", nothing],
            support = [nothing, nothing, "77", "55", nothing],
            gamma = [nothing, nothing, "0.8", "0.2", nothing],
        ),
    )
    return LineagesIO.LineageGraphAsset(
        1,
        1,
        1,
        1,
        nothing,
        nothing,
        node_table,
        edge_table,
        nothing,
        nothing,
    )
end

const VALIDATION_BOUND_EVENTS = Any[]
const VALIDATION_BUILDER_EVENTS = Any[]
const VALIDATION_MULTI_PARENT_EVENTS = Any[]

mutable struct ValidationSingleParentNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{ValidationSingleParentNode}
end

mutable struct ValidationBoundNode
    nodekey::Union{Nothing, LineagesIO.StructureKeyType}
    label::String
    child_collection::Vector{ValidationBoundNode}
end

function LineagesIO.bind_rootnode!(
    rootnode::ValidationBoundNode,
    nodekey,
    label;
    nodedata,
)
    rootnode.nodekey = nodekey
    rootnode.label = String(label)
    push!(VALIDATION_BOUND_EVENTS, (:bind_rootnode, nodekey, String(label)))
    return rootnode
end

function LineagesIO.add_child(
    parent::ValidationBoundNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    push!(VALIDATION_BOUND_EVENTS, (:child, nodekey, edgekey, parent.nodekey))
    child = ValidationBoundNode(nodekey, String(label), ValidationBoundNode[])
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.add_child(
    parent_collection::AbstractVector{ValidationBoundNode},
    nodekey,
    label,
    edgekeys::AbstractVector{LineagesIO.StructureKeyType},
    edgeweights::AbstractVector{LineagesIO.EdgeWeightType},
)
    push!(VALIDATION_BOUND_EVENTS, (:bad_multi, nodekey, collect(edgekeys), collect(edgeweights), length(parent_collection)))
    return ValidationBoundNode(nodekey, String(label), ValidationBoundNode[])
end

mutable struct ValidationMultiParentNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{ValidationMultiParentNode}
    finalized::Bool
end

function LineagesIO.add_child(
    ::Nothing,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata = nothing,
    nodedata,
)
    push!(VALIDATION_MULTI_PARENT_EVENTS, (:root, nodekey, String(label)))
    return ValidationMultiParentNode(nodekey, String(label), ValidationMultiParentNode[], false)
end

function LineagesIO.add_child(
    parent::ValidationMultiParentNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    push!(VALIDATION_MULTI_PARENT_EVENTS, (:single, nodekey, edgekey, parent.nodekey))
    child = ValidationMultiParentNode(nodekey, String(label), ValidationMultiParentNode[], false)
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.add_child(
    parent_collection::AbstractVector{ValidationMultiParentNode},
    nodekey,
    label,
    edgekeys::AbstractVector{LineagesIO.StructureKeyType},
    edgeweights::AbstractVector;
    edgedata,
    nodedata,
)
    push!(
        VALIDATION_MULTI_PARENT_EVENTS,
        (
            :multi,
            nodekey,
            [parent.nodekey for parent in parent_collection],
            collect(edgekeys),
            collect(edgeweights),
            [LineagesIO.edge_property(rowref, :kind) for rowref in edgedata],
            LineagesIO.node_property(nodedata, :posterior),
        ),
    )
    child = ValidationMultiParentNode(nodekey, String(label), ValidationMultiParentNode[], false)
    for parent in parent_collection
        push!(parent.child_collection, child)
    end
    return child
end

function LineagesIO.finalize_graph!(rootnode::ValidationMultiParentNode)
    push!(VALIDATION_MULTI_PARENT_EVENTS, (:finalize, rootnode.nodekey))
    rootnode.finalized = true
    return rootnode
end

@testset "Network target validation" begin
    asset = synthetic_network_asset_for_validation()

    @test LineagesIO.graph_requires_multi_parent(asset)

    single_parent_error = capture_expected_load_error() do
        LineagesIO.materialize_graphs(
            [asset],
            LineagesIO.NodeTypeLoadRequest(ValidationSingleParentNode),
        )
    end
    @test single_parent_error isa ArgumentError
    @test occursin("multi-parent `LineagesIO.add_child(parent_collection", sprint(showerror, single_parent_error))

    validation_sample = LineagesIO.build_multi_parent_protocol_sample(asset)
    @test !LineagesIO.has_custom_multi_parent_add_child(
        ValidationBoundNode[],
        validation_sample.child_nodekey,
        validation_sample.label,
        validation_sample.edgekeys,
        validation_sample.edgeweights;
        edgedata = validation_sample.edgedata,
        nodedata = validation_sample.nodedata,
    )

    empty!(VALIDATION_BOUND_EVENTS)
    bound_root = ValidationBoundNode(nothing, "", ValidationBoundNode[])
    bound_error = capture_expected_load_error() do
        LineagesIO.materialize_graphs(
            [asset],
            LineagesIO.RootBindingLoadRequest(bound_root),
        )
    end
    @test bound_error isa ArgumentError
    @test occursin("supplied `rootnode` load surface", sprint(showerror, bound_error))
    @test VALIDATION_BOUND_EVENTS == Any[]

    empty!(VALIDATION_BUILDER_EVENTS)
    single_parent_builder = function (parent, nodekey, label, edgekey, edgeweight; edgedata = nothing, nodedata)
        if parent === nothing
            push!(VALIDATION_BUILDER_EVENTS, (:root, nodekey, String(label)))
            return ValidationSingleParentNode(nodekey, String(label), ValidationSingleParentNode[])
        end
        push!(VALIDATION_BUILDER_EVENTS, (:child, nodekey, edgekey, parent.nodekey))
        child = ValidationSingleParentNode(nodekey, String(label), ValidationSingleParentNode[])
        push!(parent.child_collection, child)
        return child
    end
    single_parent_builder_typed = (parent::Union{Nothing, ValidationSingleParentNode}, nodekey, label, edgekey, edgeweight; edgedata = nothing, nodedata) -> single_parent_builder(parent, nodekey, label, edgekey, edgeweight; edgedata = edgedata, nodedata = nodedata)
    builder_error = capture_expected_load_error() do
        LineagesIO.materialize_graphs(
            [asset],
            LineagesIO.BuilderLoadRequest(single_parent_builder_typed),
        )
    end
    @test builder_error isa ArgumentError
    @test occursin("supplied `builder` callback", sprint(showerror, builder_error))
    @test VALIDATION_BUILDER_EVENTS == Any[]

    empty!(VALIDATION_MULTI_PARENT_EVENTS)
    graph_assets = LineagesIO.materialize_graphs(
        [asset],
        LineagesIO.NodeTypeLoadRequest(ValidationMultiParentNode),
    )
    materialized_root = only(graph_assets).materialized
    @test materialized_root.finalized
    @test (:multi, 4, [2, 3], [3, 4], [0.8, 0.2], ["major", "minor"], "0.44") in VALIDATION_MULTI_PARENT_EVENTS
end
