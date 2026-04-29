using PhyloNetworks

@testset "PhyloNetworks target-validation rejection paths" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))

    occupied_target = PhyloNetworks.HybridNetwork()
    PhyloNetworks.pushNode!(occupied_target, PhyloNetworks.Node(999, true, false))

    occupied_error = capture_expected_load_error() do
        load(fixture_path, occupied_target)
    end
    @test occupied_error isa ArgumentError
    @test occursin("must be empty", sprint(showerror, occupied_error))
    @test occupied_target.numnodes == 1
    @test occupied_target.numedges == 0
end

@testset "PhyloNetworks retained gamma validation" begin
    invalid_newick = "((A[&posterior=0.91]:1[&phase=left],(B:1)#H1[&posterior=0.44]:1:77:0.8[&branch=major])Left:5,(#H1:0:55:0.4[&branch=minor],C:1)Right:1)Root[&posterior=0.99];"

    mktempdir() do dir
        path = joinpath(dir, "invalid_gamma_sum.nwk")
        open(path, "w") do io
            write(io, invalid_newick)
        end

        node_type_error = capture_expected_load_error() do
            load(path, PhyloNetworks.HybridNetwork)
        end
        @test node_type_error isa ArgumentError
        @test occursin("sum to 1.0", sprint(showerror, node_type_error))

        target = PhyloNetworks.HybridNetwork()
        target_error = capture_expected_load_error() do
            load(path, target)
        end
        @test target_error isa ArgumentError
        @test occursin("sum to 1.0", sprint(showerror, target_error))
        @test target.numnodes == 0
        @test target.numedges == 0
    end
end
