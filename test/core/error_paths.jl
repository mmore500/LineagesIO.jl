struct MissingConstructionProtocolNode end

mutable struct MissingBasenodeProtocolNode
    payload::Int
end

@testset "Construction error paths" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    missing_construction_error = capture_expected_load_error() do
        load(fixture_path, MissingConstructionProtocolNode)
    end
    @test missing_construction_error isa ArgumentError
    @test occursin("add_child(::Nothing", sprint(showerror, missing_construction_error))

    missing_basenode_error = capture_expected_load_error() do
        load(fixture_path, MissingBasenodeProtocolNode(0))
    end
    @test missing_basenode_error isa ArgumentError
    @test occursin("bind_basenode!", sprint(showerror, missing_basenode_error))

    invalid_combination_error = capture_expected_load_error() do
        load(fixture_path, MissingBasenodeProtocolNode(0); builder = (args...; kwargs...) -> nothing)
    end
    @test invalid_combination_error isa ArgumentError
    @test occursin("cannot be combined", sprint(showerror, invalid_combination_error))

    invalid_builder_error = capture_expected_load_error() do
        load(fixture_path; builder = (args...; kwargs...) -> nothing)
    end
    @test invalid_builder_error isa ArgumentError
    @test occursin("returned `nothing`", sprint(showerror, invalid_builder_error))
end
