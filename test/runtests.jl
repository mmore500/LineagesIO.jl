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
    include("core/row_references.jl")
    include("core/annotation_retention.jl")
    include("core/construction_protocol_single_parent.jl")
    include("core/root_binding.jl")
    include("core/builder_callback.jl")
    include("core/error_paths.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(LineagesIO)
    end

    @testset "Code linting (JET.jl)" begin
        JET.test_package(LineagesIO; target_modules = (LineagesIO,))
    end
end
