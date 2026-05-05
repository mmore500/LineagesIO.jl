using Aqua: Aqua
using FileIO: File, Stream, load
using JET: JET
using LineagesIO
using Tables
using Test: @test, @test_throws, @testset

function unwrap_captured_error(err)
    return err isa Base.CapturedException ? err.ex : err
end

function capture_expected_load_error(f::Function)
    return redirect_stderr(devnull) do
        try
            f()
            return nothing
        catch err
            return unwrap_captured_error(err)
        end
    end
end

@testset "LineagesIO.jl" begin
    include("core/companion_tables.jl")
    include("core/newick_tables_only.jl")
    include("core/graph_store_coordinates.jl")
    include("core/fileio_load_surfaces.jl")
    include("core/row_references.jl")
    include("core/annotation_retention.jl")
    include("core/construction_protocol_single_parent.jl")
    include("core/basenode_binding.jl")
    include("core/builder_callback.jl")
    include("core/error_paths.jl")
    include("core/network_target_validation.jl")
    include("core/network_protocol_multi_parent.jl")
    include("core/network_newick_format.jl")
    include("core/network_annotation_retention.jl")
    include("core/alife_format.jl")
    include("extensions/metagraphsnext_activation.jl")
    include("extensions/metagraphsnext_simple_newick.jl")
    include("extensions/metagraphsnext_tables_after_load.jl")
    include("extensions/metagraphsnext_supplied_basenode.jl")
    include("extensions/metagraphsnext_abstracttrees.jl")
    include("extensions/metagraphsnext_network_rejection.jl")
    include("extensions/phylonetworks_activation.jl")
    include("extensions/phylonetworks_newick_networks.jl")
    include("extensions/phylonetworks_annotation_paths.jl")
    include("extensions/phylonetworks_tables_after_load.jl")
    include("extensions/phylonetworks_tree_compatible_newick.jl")
    include("extensions/phylonetworks_rejection_paths.jl")
    include("integration/phylonetworks_soft_release.jl")
    include("core/canonical_load_owner.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(LineagesIO)
    end

    @testset "Code linting (JET.jl)" begin
        JET.test_package(LineagesIO; target_modules = (LineagesIO,))
    end
end
