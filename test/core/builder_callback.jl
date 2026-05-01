const BUILDER_CALLBACK_EVENTS = Any[]

mutable struct BuilderCallbackNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    posterior::Union{Nothing, String}
    incoming_phase::Union{Nothing, String}
    child_collection::Vector{BuilderCallbackNode}
    finalized::Bool
end

function LineagesIO.finalize_graph!(basenode::BuilderCallbackNode)
    push!(BUILDER_CALLBACK_EVENTS, (:finalize, basenode.nodekey, basenode.label))
    basenode.finalized = true
    return basenode
end

@testset "Builder callback construction" begin
    empty!(BUILDER_CALLBACK_EVENTS)
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    builder = function (parent, nodekey, label, edgekey, edgeweight; edgedata = nothing, nodedata)
        posterior = node_property(nodedata, :posterior)
        phase = edgedata === nothing ? nothing : edge_property(edgedata, :phase)
        push!(BUILDER_CALLBACK_EVENTS, (parent === nothing ? :root : :child, nodekey, edgekey, String(label), posterior, phase, edgeweight))
        node = BuilderCallbackNode(nodekey, String(label), posterior, phase, BuilderCallbackNode[], false)
        parent === nothing || push!(parent.child_collection, node)
        return node
    end

    store = load(fixture_path; builder = builder)
    asset = first(store.graphs)
    basenode = asset.materialized

    @test basenode isa BuilderCallbackNode
    @test basenode.finalized
    @test basenode.label == "Root"
    @test basenode.posterior == "0.99"
    @test basenode.incoming_phase === nothing
    @test basenode.child_collection[1].label == "Inner"
    @test basenode.child_collection[1].child_collection[1].incoming_phase == "left"
    @test basenode.child_collection[1].child_collection[2].incoming_phase === nothing

    @test BUILDER_CALLBACK_EVENTS == Any[
        (:root, 1, nothing, "Root", "0.99", nothing, nothing),
        (:child, 2, 1, "Inner", "0.81", nothing, 2.0),
        (:child, 3, 2, "A", "0.91", "left", 1.5),
        (:child, 4, 3, "", "0.52", nothing, 0.25),
        (:child, 5, 4, "C", "0.73", nothing, nothing),
        (:finalize, 1, "Root"),
    ]
end
