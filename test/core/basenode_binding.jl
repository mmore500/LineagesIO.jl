const BASENODE_PROTOCOL_EVENTS = Any[]

mutable struct BasenodeProtocolNode
    nodekey::Union{Nothing, LineagesIO.StructureKeyType}
    label::String
    posterior::Union{Nothing, String}
    child_collection::Vector{BasenodeProtocolNode}
    finalized::Bool
end

function LineagesIO.bind_basenode!(
    basenode::BasenodeProtocolNode,
    nodekey,
    label;
    nodedata,
)
    basenode.nodekey = nodekey
    basenode.label = String(label)
    basenode.posterior = node_property(nodedata, :posterior)
    push!(BASENODE_PROTOCOL_EVENTS, (:bind_basenode, nodekey, String(label), basenode.posterior))
    return basenode
end

function LineagesIO.add_child(
    parent::BasenodeProtocolNode,
    nodekey,
    label,
    edgekey,
    edgeweight;
    edgedata,
    nodedata,
)
    posterior = node_property(nodedata, :posterior)
    bootstrap = edge_property(edgedata, :bootstrap)
    push!(BASENODE_PROTOCOL_EVENTS, (:child, nodekey, edgekey, String(label), posterior, bootstrap, edgeweight))
    child = BasenodeProtocolNode(nodekey, String(label), posterior, BasenodeProtocolNode[], false)
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.finalize_graph!(basenode::BasenodeProtocolNode)
    push!(BASENODE_PROTOCOL_EVENTS, (:finalize, basenode.nodekey, basenode.label))
    basenode.finalized = true
    return basenode
end

@testset "Supplied-basenode binding" begin
    empty!(BASENODE_PROTOCOL_EVENTS)
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    basenode = BasenodeProtocolNode(nothing, "", nothing, BasenodeProtocolNode[], false)
    store = load(fixture_path, basenode)
    asset = first(store.graphs)

    @test asset.materialized === basenode
    @test basenode.finalized
    @test basenode.nodekey == 1
    @test basenode.label == "Root"
    @test basenode.posterior == "0.99"
    @test length(basenode.child_collection) == 2
    @test basenode.child_collection[1].label == "Inner"
    @test basenode.child_collection[2].label == "C"
    @test basenode.child_collection[1].child_collection[1].label == "A"
    @test basenode.child_collection[1].child_collection[2].label == ""

    @test BASENODE_PROTOCOL_EVENTS == Any[
        (:bind_basenode, 1, "Root", "0.99"),
        (:child, 2, 1, "Inner", "0.81", "77", 2.0),
        (:child, 3, 2, "A", "0.91", "97", 1.5),
        (:child, 4, 3, "", "0.52", "88", 0.25),
        (:child, 5, 4, "C", "0.73", nothing, nothing),
        (:finalize, 1, "Root"),
    ]

    multi_graph_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_basenode_binding_source.trees"))
    multi_graph_error = capture_expected_load_error() do
        load(multi_graph_path, BasenodeProtocolNode(nothing, "", nothing, BasenodeProtocolNode[], false))
    end
    @test multi_graph_error isa ArgumentError
    @test occursin("exactly one graph", sprint(showerror, multi_graph_error))
end
