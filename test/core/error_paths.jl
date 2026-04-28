struct MissingConstructionProtocolNode end

mutable struct MissingRootBindingProtocolNode
    payload::Int
end

@testset "Construction error paths" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    missing_construction_error = try
        load(fixture_path, MissingConstructionProtocolNode)
        nothing
    catch err
        err
    end
    surfaced_construction_error = missing_construction_error isa Base.CapturedException ? missing_construction_error.ex : missing_construction_error
    @test surfaced_construction_error isa ArgumentError
    @test occursin("add_child(::Nothing", sprint(showerror, surfaced_construction_error))

    missing_root_binding_error = try
        load(fixture_path, MissingRootBindingProtocolNode(0))
        nothing
    catch err
        err
    end
    surfaced_root_binding_error = missing_root_binding_error isa Base.CapturedException ? missing_root_binding_error.ex : missing_root_binding_error
    @test surfaced_root_binding_error isa ArgumentError
    @test occursin("bind_rootnode!", sprint(showerror, surfaced_root_binding_error))

    invalid_combination_error = try
        load(fixture_path, MissingRootBindingProtocolNode(0); builder = (args...; kwargs...) -> nothing)
        nothing
    catch err
        err
    end
    surfaced_invalid_combination_error = invalid_combination_error isa Base.CapturedException ? invalid_combination_error.ex : invalid_combination_error
    @test surfaced_invalid_combination_error isa ArgumentError
    @test occursin("cannot be combined", sprint(showerror, surfaced_invalid_combination_error))

    invalid_builder_error = try
        load(fixture_path; builder = (args...; kwargs...) -> nothing)
        nothing
    catch err
        err
    end
    surfaced_invalid_builder_error = invalid_builder_error isa Base.CapturedException ? invalid_builder_error.ex : invalid_builder_error
    @test surfaced_invalid_builder_error isa ArgumentError
    @test occursin("returned `nothing`", sprint(showerror, surfaced_invalid_builder_error))
end
