using LineagesIO
using Test
using Aqua
using JET

@testset "LineagesIO.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(LineagesIO)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(LineagesIO; target_defined_modules = true)
    end
    # Write your tests here.
end
