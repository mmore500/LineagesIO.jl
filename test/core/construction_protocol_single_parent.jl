const SINGLE_PARENT_PROTOCOL_EVENTS = Any[]

mutable struct SingleParentProtocolNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    posterior::Union{Nothing, String}
    incoming_edgekey::Union{Nothing, LineagesIO.StructureKeyType}
    incoming_edgeweight::Union{Nothing, Float64}
    incoming_bootstrap::Union{Nothing, String}
    child_collection::Vector{SingleParentProtocolNode}
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
    posterior = node_property(nodedata, :posterior)
    push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:root, nodekey, edgekey, String(label), posterior, nothing, edgeweight))
    return SingleParentProtocolNode(nodekey, String(label), posterior, nothing, nothing, nothing, SingleParentProtocolNode[], false)
end

function LineagesIO.add_child(
    parent::SingleParentProtocolNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    posterior = node_property(nodedata, :posterior)
    bootstrap = edge_property(edgedata, :bootstrap)
    push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:child, nodekey, edgekey, String(label), posterior, bootstrap, edgeweight))
    child = SingleParentProtocolNode(
        nodekey,
        String(label),
        posterior,
        edgekey,
        edgeweight,
        bootstrap,
        SingleParentProtocolNode[],
        false,
    )
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.finalize_graph!(rootnode::SingleParentProtocolNode)
    push!(SINGLE_PARENT_PROTOCOL_EVENTS, (:finalize, rootnode.nodekey, nothing, rootnode.label, rootnode.posterior, nothing, nothing))
    rootnode.finalized = true
    return rootnode
end

@testset "Single-parent construction protocol" begin
    empty!(SINGLE_PARENT_PROTOCOL_EVENTS)
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    store = load(fixture_path, SingleParentProtocolNode)
    asset = first(store.graphs)
    rootnode = asset.materialized

    @test rootnode isa SingleParentProtocolNode
    @test rootnode.finalized
    @test rootnode.nodekey == 1
    @test rootnode.label == "Root"
    @test rootnode.posterior == "0.99"
    @test length(rootnode.child_collection) == 2

    inner = rootnode.child_collection[1]
    right = rootnode.child_collection[2]
    @test inner.nodekey == 2
    @test inner.label == "Inner"
    @test inner.posterior == "0.81"
    @test inner.incoming_edgekey == 1
    @test inner.incoming_edgeweight == 2.0
    @test inner.incoming_bootstrap == "77"
    @test right.nodekey == 5
    @test right.label == "C"
    @test right.posterior == "0.73"
    @test right.incoming_edgekey == 4
    @test right.incoming_bootstrap === nothing

    left_leaf = inner.child_collection[1]
    unlabeled_leaf = inner.child_collection[2]
    @test left_leaf.nodekey == 3
    @test left_leaf.label == "A"
    @test left_leaf.posterior == "0.91"
    @test left_leaf.incoming_edgekey == 2
    @test left_leaf.incoming_edgeweight == 1.5
    @test left_leaf.incoming_bootstrap == "97"
    @test unlabeled_leaf.nodekey == 4
    @test unlabeled_leaf.label == ""
    @test unlabeled_leaf.posterior == "0.52"
    @test unlabeled_leaf.incoming_edgekey == 3
    @test unlabeled_leaf.incoming_edgeweight == 0.25
    @test unlabeled_leaf.incoming_bootstrap == "88"

    @test SINGLE_PARENT_PROTOCOL_EVENTS == Any[
        (:root, 1, nothing, "Root", "0.99", nothing, nothing),
        (:child, 2, 1, "Inner", "0.81", "77", 2.0),
        (:child, 3, 2, "A", "0.91", "97", 1.5),
        (:child, 4, 3, "", "0.52", "88", 0.25),
        (:child, 5, 4, "C", "0.73", nothing, nothing),
        (:finalize, 1, nothing, "Root", "0.99", nothing, nothing),
    ]
end
