using Aqua: Aqua
using JET: JET
using LineagesIO: LineagesIO
using Test: @testset

@testset "LineagesIO.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(LineagesIO)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(LineagesIO; target_modules = (LineagesIO,))
    end
    include("test_protocol.jl")
    include("test_types.jl")
end
