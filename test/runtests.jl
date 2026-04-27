using Aqua: Aqua
using FileIO: File, Stream, load
using JET: JET
using LineagesIO
using Tables
using Test: @test, @test_throws, @testset

@testset "LineagesIO.jl" begin
    include("core/companion_tables.jl")
    include("core/newick_tables_only.jl")
    include("core/graph_store_coordinates.jl")
    include("core/fileio_load_surfaces.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(LineagesIO)
    end

    @testset "Code linting (JET.jl)" begin
        JET.test_package(LineagesIO; target_modules = (LineagesIO,))
    end
end
