using LineagesIO: add_child, finalize_graph!
using Test: @test, @testset

@testset "protocol" begin
    struct MyTestNode
        node_idx::Int
        label::String
    end

    node = MyTestNode(1, "root")

    @test finalize_graph!(node) === node
    @test :add_child in names(LineagesIO)
    @test add_child isa Function
end
