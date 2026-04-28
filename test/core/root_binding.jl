const ROOT_BINDING_PROTOCOL_EVENTS = Any[]

mutable struct RootBindingProtocolNode
    nodekey::Union{Nothing, LineagesIO.StructureKeyType}
    label::String
    posterior::Union{Nothing, String}
    child_collection::Vector{RootBindingProtocolNode}
    finalized::Bool
end

function LineagesIO.bind_rootnode!(
    rootnode::RootBindingProtocolNode,
    nodekey,
    label;
    nodedata,
)
    rootnode.nodekey = nodekey
    rootnode.label = String(label)
    rootnode.posterior = node_property(nodedata, :posterior)
    push!(ROOT_BINDING_PROTOCOL_EVENTS, (:bind_rootnode, nodekey, String(label), rootnode.posterior))
    return rootnode
end

function LineagesIO.add_child(
    parent::RootBindingProtocolNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    posterior = node_property(nodedata, :posterior)
    bootstrap = edge_property(edgedata, :bootstrap)
    push!(ROOT_BINDING_PROTOCOL_EVENTS, (:child, nodekey, edgekey, String(label), posterior, bootstrap, edgeweight))
    child = RootBindingProtocolNode(nodekey, String(label), posterior, RootBindingProtocolNode[], false)
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.finalize_graph!(rootnode::RootBindingProtocolNode)
    push!(ROOT_BINDING_PROTOCOL_EVENTS, (:finalize, rootnode.nodekey, rootnode.label))
    rootnode.finalized = true
    return rootnode
end

@testset "Supplied-root binding" begin
    empty!(ROOT_BINDING_PROTOCOL_EVENTS)
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    rootnode = RootBindingProtocolNode(nothing, "", nothing, RootBindingProtocolNode[], false)
    store = load(fixture_path, rootnode)
    asset = first(store.graphs)

    @test asset.materialized === rootnode
    @test rootnode.finalized
    @test rootnode.nodekey == 1
    @test rootnode.label == "Root"
    @test rootnode.posterior == "0.99"
    @test length(rootnode.child_collection) == 2
    @test rootnode.child_collection[1].label == "Inner"
    @test rootnode.child_collection[2].label == "C"
    @test rootnode.child_collection[1].child_collection[1].label == "A"
    @test rootnode.child_collection[1].child_collection[2].label == ""

    @test ROOT_BINDING_PROTOCOL_EVENTS == Any[
        (:bind_rootnode, 1, "Root", "0.99"),
        (:child, 2, 1, "Inner", "0.81", "77", 2.0),
        (:child, 3, 2, "A", "0.91", "97", 1.5),
        (:child, 4, 3, "", "0.52", "88", 0.25),
        (:child, 5, 4, "C", "0.73", nothing, nothing),
        (:finalize, 1, "Root"),
    ]

    multi_graph_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_root_binding_source.trees"))
    multi_graph_error = capture_expected_load_error() do
        load(multi_graph_path, RootBindingProtocolNode(nothing, "", nothing, RootBindingProtocolNode[], false))
    end
    @test multi_graph_error isa ArgumentError
    @test occursin("exactly one graph", sprint(showerror, multi_graph_error))
end
