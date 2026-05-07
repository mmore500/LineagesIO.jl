@testset "FileIO load surfaces" begin
    safe_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    ambiguous_path = abspath(joinpath(@__DIR__, "..", "fixtures", "ambiguous_simple_rooted.txt"))
    network_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )

    safe_store = load(safe_path)
    safe_asset = first(safe_store.graphs)
    @test safe_asset.graph === nothing
    @test safe_asset.basenode === nothing
    @test safe_asset.source_path == safe_path
    @test Tables.getcolumn(safe_asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]

    override_store = load(File{LineagesIO.NewickFormat}(ambiguous_path))
    override_asset = first(override_store.graphs)
    @test override_asset.graph === nothing
    @test override_asset.basenode === nothing
    @test override_asset.source_path == ambiguous_path
    @test Tables.getcolumn(override_asset.edge_table, :edgeweight) == Union{Nothing, Float64}[2.0, 1.5, 0.25, nothing]

    open(ambiguous_path, "r") do io
        stream_store = load(Stream{LineagesIO.NewickFormat}(io, ambiguous_path))
        stream_asset = first(stream_store.graphs)
        @test stream_asset.graph === nothing
        @test stream_asset.basenode === nothing
        @test stream_asset.source_path == ambiguous_path
        @test Tables.getcolumn(stream_asset.node_table, :label) == Tables.getcolumn(override_asset.node_table, :label)
        @test Tables.getcolumn(stream_asset.edge_table, :edgeweight) == Tables.getcolumn(override_asset.edge_table, :edgeweight)
    end

    tree_target_error = capture_expected_load_error() do
        load(safe_path, Int)
    end
    tree_target_text = sprint(showerror, tree_target_error)
    @test tree_target_error isa Exception
    @test (
        occursin("BuilderDescriptor", tree_target_text) ||
        occursin("node-type construction path", tree_target_text)
    )
    @test !occursin("package-owned", tree_target_text)
    @test !occursin("read_lineages(", tree_target_text)
    @test !occursin("load(...; builder = fn)", tree_target_text)

    network_target_error = capture_expected_load_error() do
        load(network_path, Int)
    end
    network_target_text = sprint(showerror, network_target_error)
    @test network_target_error isa Exception
    @test occursin("node-type construction path", network_target_text)
    @test !occursin("package-owned", network_target_text)
    @test !occursin("read_lineages(", network_target_text)
    @test !occursin("load(src, Int64)", network_target_text)

    ambiguous_error = try
        load(ambiguous_path)
        nothing
    catch err
        err
    end
    surfaced_error = ambiguous_error isa Base.CapturedException ? ambiguous_error.ex : ambiguous_error
    @test surfaced_error isa Exception
    @test occursin("resolve the ambiguity", sprint(showerror, surfaced_error))
    @test occursin("File{format\"FMT\"}", sprint(showerror, surfaced_error))
end
