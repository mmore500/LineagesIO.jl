@testset "FileIO load surfaces" begin
    safe_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    ambiguous_path = abspath(joinpath(@__DIR__, "..", "fixtures", "ambiguous_simple_rooted.txt"))

    safe_store = load(safe_path)
    safe_asset = first(safe_store.graphs)
    @test safe_asset.graph_rootnode === nothing
    @test safe_asset.source_path == safe_path
    @test Tables.getcolumn(safe_asset.node_table, :label) == ["Root", "Inner", "A", "", "C"]

    override_store = load(File{LineagesIO.NewickFormat}(ambiguous_path))
    override_asset = first(override_store.graphs)
    @test override_asset.graph_rootnode === nothing
    @test override_asset.source_path == ambiguous_path
    @test Tables.getcolumn(override_asset.edge_table, :edgeweight) == Union{Nothing, Float64}[2.0, 1.5, 0.25, nothing]

    open(ambiguous_path, "r") do io
        stream_store = load(Stream{LineagesIO.NewickFormat}(io, ambiguous_path))
        stream_asset = first(stream_store.graphs)
        @test stream_asset.graph_rootnode === nothing
        @test stream_asset.source_path == ambiguous_path
        @test Tables.getcolumn(stream_asset.node_table, :label) == Tables.getcolumn(override_asset.node_table, :label)
        @test Tables.getcolumn(stream_asset.edge_table, :edgeweight) == Tables.getcolumn(override_asset.edge_table, :edgeweight)
    end

    ambiguous_error = try
        load(ambiguous_path)
        nothing
    catch err
        err
    end
    surfaced_error = ambiguous_error isa Base.CapturedException ? ambiguous_error.ex : ambiguous_error
    @test surfaced_error isa ArgumentError
    @test occursin("Ambiguous format", sprint(showerror, surfaced_error))
    @test occursin("File{format\"Newick\"}", sprint(showerror, surfaced_error))
end
