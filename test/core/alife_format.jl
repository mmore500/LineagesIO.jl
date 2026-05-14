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
    @test Tables.getcolumn(asset.node_table, :destruction_time) == Union{Nothing, String}["", "", "3", ""]

    @test Tables.getcolumn(asset.edge_table, :edgekey) == [1, 2, 3]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4]
    @test Tables.getcolumn(asset.edge_table, :edgeweight) == Union{Nothing, Float64}[nothing, nothing, nothing]

    @test node_property(asset.node_table, 3, :origin_time) == "1"
    @test node_property(asset.node_table, 3, :destruction_time) == "3"
    @test node_property(asset.node_table, 1, :destruction_time) == ""
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
    store = load(File{LineagesIO.AlifeStandardFormat}(fixture_path); allow_forest = true)
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

function capture_alife_argument_error(f::Function)
    try
        f()
        return nothing
    catch err
        return unwrap_captured_error(err)
    end
end

@testset "Alife standard error paths" begin
    parse_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,\"[7]\"\n"
        LineagesIO.build_alife_store(text, "<missing-ancestor>")
    end
    @test parse_error isa ArgumentError
    @test occursin("unknown ancestor `id=7`", sprint(showerror, parse_error))

    cycle_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,\"[2]\"\n2,\"[1]\"\n"
        LineagesIO.build_alife_store(text, "<cycle>")
    end
    @test cycle_error isa ArgumentError
    @test occursin("unreachable from any basenode", sprint(showerror, cycle_error))
    @test occursin("ancestor cycle", sprint(showerror, cycle_error))

    multi_basenode_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,[NONE]\n2,\"[0,1]\"\n"
        LineagesIO.build_alife_store(text, "<multi-basenode>")
    end
    @test multi_basenode_error isa ArgumentError
    @test occursin("2 basenode entries", sprint(showerror, multi_basenode_error))
    @test occursin("allow_forest", sprint(showerror, multi_basenode_error))

    duplicate_id_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n0,[NONE]\n0,\"[0]\"\n"
        LineagesIO.build_alife_store(text, "<duplicate>")
    end
    @test duplicate_id_error isa ArgumentError
    @test occursin("duplicate `id=0`", sprint(showerror, duplicate_id_error))

    missing_id_header_error = capture_alife_argument_error() do
        text = "ancestor_list\n[NONE]\n"
        LineagesIO.build_alife_store(text, "<no-id>")
    end
    @test missing_id_header_error isa ArgumentError
    @test occursin("required `id` header column", sprint(showerror, missing_id_header_error))

    malformed_ancestor_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n0,NONE\n"
        LineagesIO.build_alife_store(text, "<malformed>")
    end
    @test malformed_ancestor_error isa ArgumentError
    @test occursin("malformed `ancestor_list`", sprint(showerror, malformed_ancestor_error))

    none_with_others_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n0,[NONE]\n1,\"[NONE,0]\"\n"
        LineagesIO.build_alife_store(text, "<none-mixed>")
    end
    @test none_with_others_error isa ArgumentError
    @test occursin("`NONE` must be the sole", sprint(showerror, none_with_others_error))

    negative_id_error = capture_alife_argument_error() do
        text = "id,ancestor_list\n-1,[NONE]\n"
        LineagesIO.build_alife_store(text, "<neg>")
    end
    @test negative_id_error isa ArgumentError
    @test occursin("negative `id`", sprint(showerror, negative_id_error))

    # When both ancestor_list and ancestor_id are present, ancestor_list wins
    # (ancestor_id is structurally excluded from annotations either way).
    both_columns_text = "id,ancestor_list,ancestor_id\n0,[NONE],99\n1,\"[0]\",99\n"
    both_columns_store = LineagesIO.build_alife_store(both_columns_text, "<both>")
    both_columns_asset = first(both_columns_store.graphs)
    @test Tables.getcolumn(both_columns_asset.node_table, :label) == ["0", "1"]
    @test :ancestor_id ∉ Tables.columnnames(both_columns_asset.node_table)
    @test Tables.getcolumn(both_columns_asset.edge_table, :src_nodekey) == [1]
    @test Tables.getcolumn(both_columns_asset.edge_table, :dst_nodekey) == [2]

    missing_ancestor_columns_error = capture_alife_argument_error() do
        text = "id,foo\n0,bar\n"
        LineagesIO.build_alife_store(text, "<no-ancestor>")
    end
    @test missing_ancestor_columns_error isa ArgumentError
    @test occursin("`ancestor_list` or `ancestor_id` header column", sprint(showerror, missing_ancestor_columns_error))
end

@testset "Alife standard empty input rejection" begin
    blank_input_error = capture_alife_argument_error() do
        LineagesIO.build_alife_store("", "<blank>")
    end
    @test blank_input_error isa ArgumentError
    @test occursin("at least one header row", sprint(showerror, blank_input_error))

    whitespace_only_error = capture_alife_argument_error() do
        LineagesIO.build_alife_store("   \n\n  \n", "<whitespace>")
    end
    @test whitespace_only_error isa ArgumentError
    @test occursin("at least one header row", sprint(showerror, whitespace_only_error))

    header_only_error = capture_alife_argument_error() do
        LineagesIO.build_alife_store("id,ancestor_list\n", "<header-only>")
    end
    @test header_only_error isa ArgumentError
    @test occursin("at least one data row", sprint(showerror, header_only_error))

    empty_table_error = capture_alife_argument_error() do
        load_alife_table((id = Int[], ancestor_list = Vector{Int}[]))
    end
    @test empty_table_error isa ArgumentError
    @test occursin("at least one data row", sprint(showerror, empty_table_error))
end

@testset "Alife standard basenode-only graph" begin
    text = "id,ancestor_list\n7,[NONE]\n"
    store = LineagesIO.build_alife_store(text, "<basenode-only>")
    @test length(store.graphs) == 1

    asset = first(store.graphs)
    @test Tables.getcolumn(asset.node_table, :nodekey) == [1]
    @test Tables.getcolumn(asset.node_table, :label) == ["7"]
    @test isempty(Tables.getcolumn(asset.edge_table, :edgekey))
    @test isempty(Tables.getcolumn(asset.edge_table, :src_nodekey))
    @test isempty(Tables.getcolumn(asset.edge_table, :dst_nodekey))
    @test Tables.getcolumn(store.graph_table, :node_count) == [1]
    @test Tables.getcolumn(store.graph_table, :edge_count) == [0]

    table_store = load_alife_table((id = [7], ancestor_id = [7]))
    table_asset = first(table_store.graphs)
    @test Tables.getcolumn(table_asset.node_table, :label) == ["7"]
    @test isempty(Tables.getcolumn(table_asset.edge_table, :edgekey))
end

@testset "Alife standard multi-tree forest" begin
    text = """
    id,ancestor_list
    0,[NONE]
    1,"[0]"
    2,"[0]"
    10,[NONE]
    20,[NONE]
    21,"[20]"
    22,"[21]"
    """
    store = LineagesIO.build_alife_store(text, "<forest>"; allow_forest = true)
    @test length(store.graphs) == 3

    assets = collect(store.graphs)
    @test Tables.getcolumn(assets[1].node_table, :label) == ["0", "1", "2"]
    @test Tables.getcolumn(assets[2].node_table, :label) == ["10"]
    @test Tables.getcolumn(assets[3].node_table, :label) == ["20", "21", "22"]
    @test Tables.getcolumn(store.graph_table, :node_count) == [3, 1, 3]
    @test Tables.getcolumn(store.graph_table, :edge_count) == [2, 0, 2]
    @test Tables.getcolumn(store.graph_table, :collection_graph_idx) == [1, 2, 3]
end

@testset "Alife standard ancestor_list basenode-marker variants" begin
    for basenode_token in ("[NONE]", "[none]", "[None]", "[]")
        text = "id,ancestor_list\n0,$(basenode_token)\n1,\"[0]\"\n"
        store = LineagesIO.build_alife_store(text, "<basenode-$(basenode_token)>")
        asset = first(store.graphs)
        @test Tables.getcolumn(asset.node_table, :nodekey) == [1, 2]
        @test Tables.getcolumn(asset.node_table, :label) == ["0", "1"]
        @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1]
        @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2]
    end
end

@testset "Alife standard ancestor_id column with self-id basenode" begin
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

@testset "Alife standard load_alife_table — builder compatibility wrapper" begin
    table = (
        id = [0, 1, 2, 3],
        ancestor_list = ["[NONE]", "[0]", "[0]", "[1,2]"],
        origin_time = ["0", "1", "1", "2"],
    )
    source_path = "inline-builder-table"

    captured_events = Any[]
    builder = function (parent, nodekey, label, edgekey_or_keys, edgeweight_or_weights; edgedata = nothing, nodedata)
        if parent === nothing
            push!(
                captured_events,
                (
                    :root,
                    Int(nodekey),
                    String(label),
                    node_property(nodedata, :origin_time),
                ),
            )
        elseif parent isa AbstractVector
            push!(
                captured_events,
                (
                    :multi,
                    Int(nodekey),
                    [Int(parent_node.nodekey) for parent_node in parent],
                    Int[Int(edgekey) for edgekey in edgekey_or_keys],
                    node_property(nodedata, :origin_time),
                ),
            )
        else
            push!(
                captured_events,
                (
                    :single,
                    Int(nodekey),
                    Int(parent.nodekey),
                    Int(edgekey_or_keys),
                    node_property(nodedata, :origin_time),
                ),
            )
        end
        return (; nodekey = Int(nodekey), label = String(label))
    end

    store = load_alife_table(
        table;
        builder = builder,
        source_path = source_path,
    )
    asset = first(store.graphs)

    @test asset.source_path == source_path
    @test asset.graph === nothing
    @test asset.basenode == (; nodekey = 1, label = "0")
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2, 3]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4, 4]
    @test captured_events == Any[
        (:root, 1, "0", "0"),
        (:single, 2, 1, 1, "1"),
        (:single, 3, 1, 2, "1"),
        (:multi, 4, [2, 3], [3, 4], "2"),
    ]
end

@testset "Alife standard load_alife_table — ancestor_id with self-id basenodes" begin
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
    table_input_error = capture_alife_argument_error() do
        load_alife_table([1, 2, 3])
    end
    @test table_input_error isa ArgumentError
    @test occursin("Tables.jl-compatible input", sprint(showerror, table_input_error))
end

@testset "Alife standard allow_forest defaults to false" begin
    forest_text = "id,ancestor_list\n0,[NONE]\n1,[NONE]\n"
    rejection_error = capture_alife_argument_error() do
        LineagesIO.build_alife_store(forest_text, "<default-forest>")
    end
    @test rejection_error isa ArgumentError
    @test occursin("2 basenode entries", sprint(showerror, rejection_error))
    @test occursin("allow_forest", sprint(showerror, rejection_error))

    table_rejection_error = capture_alife_argument_error() do
        load_alife_table((id = [0, 1], ancestor_list = [Int[], Int[]]))
    end
    @test table_rejection_error isa ArgumentError
    @test occursin("allow_forest", sprint(showerror, table_rejection_error))

    accepted_store = load_alife_table(
        (id = [0, 1], ancestor_list = [Int[], Int[]]);
        allow_forest = true,
    )
    @test length(accepted_store.graphs) == 2
end

@testset "Alife standard allow_forest threaded through FileIO load" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_component_alife.csv"))
    rejection_error = capture_expected_load_error() do
        load(File{LineagesIO.AlifeStandardFormat}(fixture_path))
    end
    @test rejection_error isa ArgumentError
    @test occursin("allow_forest", sprint(showerror, rejection_error))

    accepted_store = load(
        File{LineagesIO.AlifeStandardFormat}(fixture_path);
        allow_forest = true,
    )
    @test length(accepted_store.graphs) == 2
end

@testset "Alife standard allow_forest threaded through read_lineages" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_component_alife.csv"))
    rejection_error = capture_alife_argument_error() do
        read_lineages(fixture_path)
    end
    @test rejection_error isa ArgumentError
    @test occursin("allow_forest", sprint(showerror, rejection_error))

    accepted_store = read_lineages(fixture_path; allow_forest = true)
    @test length(accepted_store.graphs) == 2
end

@testset "Alife standard unordered input is BFS-reordered" begin
    unordered_table = (
        id = [1, 0, 2],
        ancestor_list = [[0], Int[], [0]],
    )
    store = load_alife_table(unordered_table)
    asset = first(store.graphs)
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3]
end

@testset "Alife standard assume_topological_ordering=true uses input-order fast path" begin
    ordered_table = (
        id = [0, 1, 2, 3],
        ancestor_list = [Int[], [0], [0], [1]],
        origin_time = ["0", "1", "1", "2"],
    )
    store = load_alife_table(ordered_table; assume_topological_ordering = true)
    asset = first(store.graphs)
    @test Tables.getcolumn(asset.node_table, :label) == ["0", "1", "2", "3"]
    @test Tables.getcolumn(asset.node_table, :origin_time) ==
        Union{Nothing, String}["0", "1", "1", "2"]
    @test Tables.getcolumn(asset.edge_table, :src_nodekey) == [1, 1, 2]
    @test Tables.getcolumn(asset.edge_table, :dst_nodekey) == [2, 3, 4]
end

@testset "Alife standard assume_topological_ordering=true asserts on bad input" begin
    unordered_table = (
        id = [1, 0, 2],
        ancestor_list = [[0], Int[], [0]],
    )
    assertion_error = capture_alife_argument_error() do
        load_alife_table(unordered_table; assume_topological_ordering = true)
    end
    @test assertion_error isa AssertionError
    @test occursin("not in topological row order", sprint(showerror, assertion_error))
end

@testset "Alife standard allow_forest preserves per-component basenode invariant" begin
    text = """
    id,ancestor_list
    5,"[10]"
    10,[NONE]
    20,[NONE]
    21,"[20]"
    """
    store = LineagesIO.build_alife_store(text, "<forest-out-of-order>"; allow_forest = true)
    assets = collect(store.graphs)
    @test length(assets) == 2
    @test Tables.getcolumn(assets[1].node_table, :label) == ["10", "5"]
    @test Tables.getcolumn(assets[2].node_table, :label) == ["20", "21"]
    @test Tables.getcolumn(assets[1].edge_table, :src_nodekey) == [1]
    @test Tables.getcolumn(assets[1].edge_table, :dst_nodekey) == [2]
end

@testset "Alife origin_time annotation emits a warning" begin
    table = (
        id            = [0, 1, 2],
        ancestor_list = [Int[], [0], [0]],
        origin_time   = ["0", "1", "1"],
    )
    @test_logs (:warn, r"origin_time") match_mode = :any load_alife_table(table)
end

@testset "Alife annotation defaults preserve whitespace and empty strings (CSV)" begin
    text = "id,ancestor_list,trait\n0,[NONE],  founder  \n1,\"[0]\",\n"
    default_store = LineagesIO.build_alife_store(text, "<default-csv>")
    default_asset = first(default_store.graphs)
    @test Tables.getcolumn(default_asset.node_table, :trait) ==
        Union{Nothing, String}["  founder  ", ""]

    normalized_store = LineagesIO.build_alife_store(
        text, "<normalize-csv>"; normalize_annotation_values = true,
    )
    normalized_asset = first(normalized_store.graphs)
    @test Tables.getcolumn(normalized_asset.node_table, :trait) ==
        Union{Nothing, String}["founder", nothing]
end

@testset "Alife annotation defaults pass Tables.jl string cells through verbatim" begin
    table = (
        id            = [0, 1],
        ancestor_list = [Int[], [0]],
        trait         = ["  raw  ", ""],
    )
    default_store = load_alife_table(table)
    default_asset = first(default_store.graphs)
    @test Tables.getcolumn(default_asset.node_table, :trait) ==
        Union{Nothing, String}["  raw  ", ""]

    normalized_store = load_alife_table(table; normalize_annotation_values = true)
    normalized_asset = first(normalized_store.graphs)
    @test Tables.getcolumn(normalized_asset.node_table, :trait) ==
        Union{Nothing, String}["raw", nothing]
end

@testset "Alife annotation defaults stringify non-string Tables.jl cells" begin
    table = (
        id            = [0, 1],
        ancestor_list = [Int[], [0]],
        weight        = [0.0, 1.5],
    )
    default_store = load_alife_table(table)
    default_asset = first(default_store.graphs)
    @test Tables.getcolumn(default_asset.node_table, :weight) ==
        Union{Nothing, String}["0.0", "1.5"]
end

function alife_columns_fixture(
    ids::Vector{Int},
    ancestor_lists::Vector{Vector{Int}};
    annotation_names::Vector{Symbol} = Symbol[],
    annotation_columns::Vector{Vector{Union{Nothing, String}}} = Vector{Union{Nothing, String}}[],
)
    return LineagesIO.AlifeColumns(
        length(ids), ids, ancestor_lists, annotation_names, annotation_columns,
    )
end

function alife_tree_columns_fixture(
    ids::Vector{Int},
    parent_ids::Vector{Int};
    annotation_names::Vector{Symbol} = Symbol[],
    annotation_columns::Vector{Vector{Union{Nothing, String}}} = Vector{Union{Nothing, String}}[],
)
    return LineagesIO.AlifeColumns(
        length(ids), ids, parent_ids, annotation_names, annotation_columns,
    )
end

@testset "Alife private helper — build_row_index_by_id" begin
    columns = alife_columns_fixture([10, 20, 30], [Int[], [10], [20]])
    row_index_by_id = LineagesIO.build_row_index_by_id(columns)
    @test row_index_by_id == Dict(10 => 1, 20 => 2, 30 => 3)
end

@testset "Alife private helper — find_basenode_row_indices" begin
    @test LineagesIO.find_basenode_row_indices(
        alife_columns_fixture([10, 11, 20], [Int[], [10], Int[]]),
    ) == [1, 3]
    @test LineagesIO.find_basenode_row_indices(
        alife_columns_fixture([0, 1, 2], [Int[], [0], [1]]),
    ) == [1]
end

@testset "Alife private helper — assert_basenode_count" begin
    @test LineagesIO.assert_basenode_count(1, false, nothing) === nothing
    @test LineagesIO.assert_basenode_count(2, true, nothing) === nothing
    @test LineagesIO.assert_basenode_count(0, true, nothing) === nothing

    rejection_error = capture_alife_argument_error() do
        LineagesIO.assert_basenode_count(2, false, "<inline>")
    end
    @test rejection_error isa ArgumentError
    @test occursin("2 basenode entries", sprint(showerror, rejection_error))
    @test occursin("allow_forest", sprint(showerror, rejection_error))
end


@testset "Alife private helper — input_is_topologically_ordered" begin
    ordered = alife_columns_fixture([0, 1, 2], [Int[], [0], [1]])
    @test LineagesIO.input_is_topologically_ordered(
        ordered, LineagesIO.build_row_index_by_id(ordered),
    )

    unordered = alife_columns_fixture([1, 0, 2], [[0], Int[], [0]])
    @test !LineagesIO.input_is_topologically_ordered(
        unordered, LineagesIO.build_row_index_by_id(unordered),
    )
end

@testset "Alife private helper — partition_components_input_order" begin
    columns = alife_columns_fixture(
        [0, 1, 10, 11], [Int[], [0], Int[], [10]],
    )
    @test LineagesIO.partition_components_input_order(
        columns, LineagesIO.build_row_index_by_id(columns),
    ) == [[1, 2], [3, 4]]
end

@testset "Alife private helper — first_parent_id" begin
    network = alife_columns_fixture([0, 1, 2, 3], [Int[], [0], [0], [1, 2]])
    @test LineagesIO.first_parent_id(network, 4) == 1

    tree = alife_tree_columns_fixture(
        [0, 1, 2, 3], [LineagesIO.ALIFE_NO_PARENT_ID, 0, 0, 1],
    )
    @test LineagesIO.first_parent_id(tree, 4) == 1
end

@testset "Alife private helper — partition_components_bfs" begin
    columns = alife_columns_fixture(
        [5, 10, 20, 21], [[10], Int[], Int[], [20]],
    )
    row_index_by_id = LineagesIO.build_row_index_by_id(columns)
    basenode_row_indices = LineagesIO.find_basenode_row_indices(columns)
    components = LineagesIO.partition_components_bfs(
        columns, row_index_by_id, basenode_row_indices, nothing,
    )
    @test components == [[2, 1], [3, 4]]

    cycle_columns = alife_columns_fixture([0, 1, 2], [Int[], [2], [1]])
    cycle_error = capture_alife_argument_error() do
        LineagesIO.partition_components_bfs(
            cycle_columns,
            LineagesIO.build_row_index_by_id(cycle_columns),
            LineagesIO.find_basenode_row_indices(cycle_columns),
            "<cycle-helper>",
        )
    end
    @test cycle_error isa ArgumentError
    @test occursin("unreachable from any basenode", sprint(showerror, cycle_error))
end

@testset "Alife private helper — assign_alife_nodekeys / count_alife_edges / is_identity_slice" begin
    @test LineagesIO.assign_alife_nodekeys([2, 4, 6]) == Dict(2 => 1, 4 => 2, 6 => 3)

    columns = alife_columns_fixture(
        [0, 1, 2, 3], [Int[], [0], [0], [1, 2]],
    )
    @test LineagesIO.count_alife_edges(columns, [1, 2, 3, 4]) == 4
    @test LineagesIO.count_alife_edges(columns, [1]) == 0

    @test LineagesIO.is_identity_slice([1, 2, 3], 3)
    @test !LineagesIO.is_identity_slice([1, 3, 2], 3)
    @test !LineagesIO.is_identity_slice([1, 2], 3)
end

@testset "Alife parametric columns — tree vs network types" begin
    network_columns = alife_columns_fixture([0, 1, 2], [Int[], [0], [0]])
    tree_columns = alife_tree_columns_fixture(
        [0, 1, 2], [LineagesIO.ALIFE_NO_PARENT_ID, 0, 0],
    )
    @test network_columns isa LineagesIO.AlifeNetworkColumns
    @test tree_columns isa LineagesIO.AlifeTreeColumns
    @test !(network_columns isa LineagesIO.AlifeTreeColumns)
    @test !(tree_columns isa LineagesIO.AlifeNetworkColumns)
end

@testset "Alife private helper — accessor dispatch (network vs tree)" begin
    network_columns = alife_columns_fixture(
        [0, 1, 2, 3], [Int[], [0], [0], [1, 2]],
    )
    @test LineagesIO.is_basenode_row(network_columns, 1)
    @test !LineagesIO.is_basenode_row(network_columns, 2)
    @test LineagesIO.n_parents_at_row(network_columns, 1) == 0
    @test LineagesIO.n_parents_at_row(network_columns, 4) == 2
    @test collect(LineagesIO.parent_ids_at_row(network_columns, 4)) == [1, 2]

    tree_columns = alife_tree_columns_fixture(
        [0, 1, 2, 3], [LineagesIO.ALIFE_NO_PARENT_ID, 0, 0, 1],
    )
    @test LineagesIO.is_basenode_row(tree_columns, 1)
    @test !LineagesIO.is_basenode_row(tree_columns, 2)
    @test LineagesIO.n_parents_at_row(tree_columns, 1) == 0
    @test LineagesIO.n_parents_at_row(tree_columns, 4) == 1
    @test collect(LineagesIO.parent_ids_at_row(tree_columns, 1)) == Int[]
    @test collect(LineagesIO.parent_ids_at_row(tree_columns, 4)) == [1]
end

@testset "Alife private helper — partition / count on tree columns" begin
    tree_columns = alife_tree_columns_fixture(
        [0, 1, 2, 3], [LineagesIO.ALIFE_NO_PARENT_ID, 0, 0, 1],
    )
    row_index_by_id = LineagesIO.build_row_index_by_id(tree_columns)
    basenode_row_indices = LineagesIO.find_basenode_row_indices(tree_columns)

    @test basenode_row_indices == [1]
    @test LineagesIO.partition_components_bfs(
        tree_columns, row_index_by_id, basenode_row_indices, nothing,
    ) == [[1, 2, 3, 4]]
    @test LineagesIO.count_alife_edges(tree_columns, [1, 2, 3, 4]) == 3

    forest_tree = alife_tree_columns_fixture(
        [10, 11, 20, 21],
        [LineagesIO.ALIFE_NO_PARENT_ID, 10, LineagesIO.ALIFE_NO_PARENT_ID, 20],
    )
    forest_basenodes = LineagesIO.find_basenode_row_indices(forest_tree)
    @test forest_basenodes == [1, 3]
    @test LineagesIO.partition_components_bfs(
        forest_tree,
        LineagesIO.build_row_index_by_id(forest_tree),
        forest_basenodes,
        nothing,
    ) == [[1, 2], [3, 4]]
end

@testset "Alife ancestor_id source produces AlifeTreeColumns" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "asexual_alife_ancestor_id.csv"))
    text = read(fixture_path, String)
    columns = LineagesIO.parse_alife_text_source(text, fixture_path)
    @test columns isa LineagesIO.AlifeTreeColumns
    @test columns.parents == [LineagesIO.ALIFE_NO_PARENT_ID, 0, 0, 1]

    table_columns = LineagesIO.parse_alife_columnar_table(
        (id = [0, 1, 2, 3], ancestor_id = [0, 0, 0, 1]),
        nothing,
    )
    @test table_columns isa LineagesIO.AlifeTreeColumns
end

@testset "Alife ancestor_list source produces AlifeNetworkColumns" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "sexual_alife.csv"))
    text = read(fixture_path, String)
    columns = LineagesIO.parse_alife_text_source(text, fixture_path)
    @test columns isa LineagesIO.AlifeNetworkColumns
    @test columns.parents == [Int[], [0], [0], [1, 2]]
end
