@testset "Alife standard tables-only single-rooted load" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))
    store = load(File{LineagesIO.AlifeStandardFormat}(fixture_path))
    @test length(store.graphs) == 1

    asset = first(store.graphs)
    @test asset.graph === nothing
    @test asset.basenode === nothing
    @test asset.source_path == fixture_path
    @test asset.collection_label === nothing
    @test asset.graph_label === nothing

    @test Tables.columnnames(asset.node_table) == (:nodekey, :label, :origin_time, :destruction_time)
    @test Tables.columnnames(asset.edge_table) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight)

    @test Tables.getcolumn(asset.node_table, :nodekey) == [1, 2, 3, 4]
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.node_table, :origin_time) == Union{Nothing, String}["0", "1", "1", "2"]
    @test Tables.getcolumn(asset.node_table, :destruction_time) == Union{Nothing, String}[nothing, nothing, "3", nothing]

    @test Tables.getcolumn(asset.edge_table, :edgekey) == [1, 2, 3]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4]
    @test Tables.getcolumn(asset.edge_table, :edgeweight) == Union{Nothing, Float64}[nothing, nothing, nothing]

    @test node_property(asset.node_table, 3, :origin_time) == "1"
    @test node_property(asset.node_table, 3, :destruction_time) == "3"
    @test node_property(asset.node_table, 1, :destruction_time) === nothing
end

@testset "Alife standard sexual (multi-parent) load" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "sexual_alife.csv"))
    store = load(File{LineagesIO.AlifeStandardFormat}(fixture_path))
    asset = first(store.graphs)

    @test Tables.getcolumn(asset.node_table, :nodekey) == [1, 2, 3, 4]
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2, 3]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4, 4]
    @test LineagesIO.graph_requires_multi_parent(asset.edge_table)
end

@testset "Alife standard multi-component load" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_component_alife.csv"))
    store = load(File{LineagesIO.AlifeStandardFormat}(fixture_path))
    @test length(store.graphs) == 2

    assets = collect(store.graphs)
    @test Tables.getcolumn(assets[1].node_table, :label) == ["10", "11"]
    @test Tables.getcolumn(assets[2].node_table, :label) == ["20", "21"]
    @test Tables.getcolumn(assets[1].edge_table, :src_nodekey) == [1]
    @test Tables.getcolumn(assets[1].edge_table, :dst_nodekey) == [2]
    @test Tables.getcolumn(assets[2].edge_table, :src_nodekey) == [1]
    @test Tables.getcolumn(assets[2].edge_table, :dst_nodekey) == [2]

    @test Tables.getcolumn(store.graph_table, :node_count) == [2, 2]
    @test Tables.getcolumn(store.graph_table, :edge_count) == [1, 1]
end

@testset "Alife standard ambiguous .csv requires explicit override" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))
    ambiguous_error = capture_expected_load_error() do
        load(fixture_path)
    end
    @test ambiguous_error isa Exception
    @test occursin("resolve the ambiguity", sprint(showerror, ambiguous_error))
end

@testset "Alife standard stream load" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))
    open(fixture_path, "r") do io
        stream_store = load(Stream{LineagesIO.AlifeStandardFormat}(io, fixture_path))
        stream_asset = first(stream_store.graphs)
        @test stream_asset.source_path == fixture_path
        @test Tables.getcolumn(stream_asset.node_table, :label) == ["0", "1", "2", "3"]
    end
end

@testset "Alife standard construction protocol" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))

    captured_events = Tuple{Any, Int, String}[]
    builder = function(parent, nodekey, label, edgekey, edgeweight; edgedata, nodedata)
        push!(captured_events, (parent, Int(nodekey), String(label)))
        return (; nodekey = nodekey, label = label)
    end
    store = load(File{LineagesIO.AlifeStandardFormat}(fixture_path); builder = builder)
    asset = first(store.graphs)
    @test asset.basenode !== nothing
    @test asset.basenode.label == "0"
    @test length(captured_events) == 4
    @test captured_events[1][1] === nothing
    @test captured_events[1][3] == "0"
end

@testset "Alife standard error paths" begin
    valid_csv = """
    id,ancestor_list
    0,[NONE]
    1,"[0]"
    """
    parse_error = capture_expected_load_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,\"[7]\"\n"
        LineagesIO.build_alife_store(text, "<missing-ancestor>")
    end
    @test parse_error isa ArgumentError
    @test occursin("unknown ancestor `id=7`", sprint(showerror, parse_error))

    cycle_error = capture_expected_load_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,\"[2]\"\n2,\"[1]\"\n"
        LineagesIO.build_alife_store(text, "<cycle>")
    end
    @test cycle_error isa ArgumentError
    @test occursin("unreachable from its root", sprint(showerror, cycle_error))

    multi_root_error = capture_expected_load_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,[NONE]\n2,\"[0,1]\"\n"
        LineagesIO.build_alife_store(text, "<multi-root>")
    end
    @test multi_root_error isa ArgumentError
    @test occursin("exactly one root entry", sprint(showerror, multi_root_error))

    duplicate_id_error = capture_expected_load_error() do
        text = "id,ancestor_list\n0,[NONE]\n0,\"[0]\"\n"
        LineagesIO.build_alife_store(text, "<duplicate>")
    end
    @test duplicate_id_error isa ArgumentError
    @test occursin("duplicate `id=0`", sprint(showerror, duplicate_id_error))

    missing_id_header_error = capture_expected_load_error() do
        text = "ancestor_list\n[NONE]\n"
        LineagesIO.build_alife_store(text, "<no-id>")
    end
    @test missing_id_header_error isa ArgumentError
    @test occursin("required `id` header column", sprint(showerror, missing_id_header_error))

    malformed_ancestor_error = capture_expected_load_error() do
        text = "id,ancestor_list\n0,NONE\n"
        LineagesIO.build_alife_store(text, "<malformed>")
    end
    @test malformed_ancestor_error isa ArgumentError
    @test occursin("malformed `ancestor_list`", sprint(showerror, malformed_ancestor_error))

    none_with_others_error = capture_expected_load_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,\"[NONE,0]\"\n"
        LineagesIO.build_alife_store(text, "<none-mixed>")
    end
    @test none_with_others_error isa ArgumentError
    @test occursin("`NONE` must be the sole", sprint(showerror, none_with_others_error))

    negative_id_error = capture_expected_load_error() do
        text = "id,ancestor_list\n-1,[NONE]\n"
        LineagesIO.build_alife_store(text, "<neg>")
    end
    @test negative_id_error isa ArgumentError
    @test occursin("negative `id`", sprint(showerror, negative_id_error))

    both_ancestor_columns_error = capture_expected_load_error() do
        text = "id,ancestor_list,ancestor_id\n0,[NONE],0\n"
        LineagesIO.build_alife_store(text, "<both>")
    end
    @test both_ancestor_columns_error isa ArgumentError
    @test occursin("either `ancestor_list` or `ancestor_id`", sprint(showerror, both_ancestor_columns_error))

    missing_ancestor_columns_error = capture_expected_load_error() do
        text = "id,foo\n0,bar\n"
        LineagesIO.build_alife_store(text, "<no-ancestor>")
    end
    @test missing_ancestor_columns_error isa ArgumentError
    @test occursin("`ancestor_list` or `ancestor_id` header column", sprint(showerror, missing_ancestor_columns_error))
end

@testset "Alife standard ancestor_id column" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "asexual_alife_ancestor_id.csv"))
    store = load(File{LineagesIO.AlifeStandardFormat}(fixture_path))
    @test length(store.graphs) == 1

    asset = first(store.graphs)
    @test Tables.columnnames(asset.node_table) == (:nodekey, :label, :origin_time)
    @test Tables.getcolumn(asset.node_table, :nodekey) == [1, 2, 3, 4]
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4]
    @test !LineagesIO.graph_requires_multi_parent(asset.edge_table)
end

@testset "Alife standard load_alife_table — NamedTuple of vectors" begin
    table = (
        id = [0, 1, 2, 3],
        ancestor_list = ["[NONE]", "[0]", "[0]", "[1,2]"],
        origin_time = ["0", "1", "1", "2"],
    )
    store = load_alife_table(table; source_path = "synthetic-table")
    asset = first(store.graphs)
    @test asset.source_path == "synthetic-table"
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.node_table, :origin_time) == Union{Nothing, String}["0", "1", "1", "2"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2, 3]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4, 4]
end

@testset "Alife standard load_alife_table — typed columns" begin
    table = (
        id = [0, 1, 2, 3],
        ancestor_list = [Int[], [0], [0], [1, 2]],
        origin_time = [0.0, 1.0, 1.0, 2.0],
    )
    store = load_alife_table(table)
    asset = first(store.graphs)
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.node_table, :origin_time) == Union{Nothing, String}["0.0", "1.0", "1.0", "2.0"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2, 3]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4, 4]
end

@testset "Alife standard load_alife_table — ancestor_id with self-id roots" begin
    table = (
        id = [0, 1, 2, 3],
        ancestor_id = [0, 0, 0, 1],
    )
    store = load_alife_table(table)
    asset = first(store.graphs)
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4]
end

@testset "Alife standard load_alife_table — non-table input rejected" begin
    table_input_error = capture_expected_load_error() do
        load_alife_table([1, 2, 3])
    end
    @test table_input_error isa ArgumentError
    @test occursin("Tables.jl-compatible input", sprint(showerror, table_input_error))
end
