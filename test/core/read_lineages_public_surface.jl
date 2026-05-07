mutable struct PublicSurfaceUntypedTarget
    label::String
end

function LineagesIO.construction_handle_type(
        ::CanonicalOwnerBoundTarget,
    )::Type{CanonicalOwnerBoundCursor}
    return CanonicalOwnerBoundCursor
end

@testset "read_lineages public surface — tables-only path and stream loads" begin
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    ambiguous_tree_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "ambiguous_simple_rooted.txt"),
    )
    alife_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))

    tree_store = LineagesIO.read_lineages(tree_path)
    tree_wrapper_store = load(tree_path)
    assert_same_store_tables(tree_store, tree_wrapper_store)
    tree_asset = only(collect(tree_store.graphs))
    assert_asset_destructuring(tree_asset)
    @test tree_asset.graph === nothing
    @test tree_asset.basenode === nothing

    override_store = LineagesIO.read_lineages(
        ambiguous_tree_path;
        format = :newick,
    )
    override_wrapper_store = load(File{LineagesIO.NewickFormat}(ambiguous_tree_path))
    assert_same_store_tables(override_store, override_wrapper_store)

    alife_store = LineagesIO.read_lineages(alife_path)
    alife_wrapper_store = load(File{LineagesIO.AlifeStandardFormat}(alife_path))
    assert_same_store_tables(alife_store, alife_wrapper_store)

    open(tree_path, "r") do io
        stream_store = LineagesIO.read_lineages(io; source_path = tree_path)
        assert_same_store_tables(stream_store, tree_store)
    end

    open(ambiguous_tree_path, "r") do io
        stream_store = LineagesIO.read_lineages(io; format = :newick)
        stream_asset = only(collect(stream_store.graphs))
        @test Tables.getcolumn(stream_asset.node_table, :label) ==
            Tables.getcolumn(
                only(collect(override_store.graphs)).node_table,
                :label,
            )
    end

    open(alife_path, "r") do io
        stream_store = LineagesIO.read_lineages(io; format = :alife)
        stream_asset = only(collect(stream_store.graphs))
        alife_asset = only(collect(alife_store.graphs))
        @test Tables.getcolumn(stream_asset.node_table, :label) ==
            Tables.getcolumn(alife_asset.node_table, :label)
        @test Tables.getcolumn(stream_asset.edge_table, :src_nodekey) ==
            Tables.getcolumn(alife_asset.edge_table, :src_nodekey)
        @test Tables.getcolumn(stream_asset.edge_table, :dst_nodekey) ==
            Tables.getcolumn(alife_asset.edge_table, :dst_nodekey)
    end
end

@testset "read_lineages public surface — typed targets and typed builder" begin
    tree_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"),
    )
    network_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )
    inline_alife_table = (
        id = [0, 1, 2, 3],
        ancestor_list = ["[NONE]", "[0]", "[0]", "[1,2]"],
        origin_time = ["0", "1", "1", "2"],
    )

    node_store = LineagesIO.read_lineages(tree_path, CanonicalOwnerProtocolNode)
    node_wrapper_store = load(
        File{LineagesIO.NewickFormat}(tree_path),
        CanonicalOwnerProtocolNode,
    )
    assert_same_store_tables(node_store, node_wrapper_store)
    node_asset = only(collect(node_store.graphs))
    wrapper_node_asset = only(collect(node_wrapper_store.graphs))
    @test canonical_owner_protocol_shape(node_asset.basenode) ==
        canonical_owner_protocol_shape(wrapper_node_asset.basenode)

    bound_target = CanonicalOwnerBoundTarget(
        nothing,
        "",
        Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}[],
        false,
    )
    bound_store = LineagesIO.read_lineages(network_path, bound_target)
    bound_asset = only(collect(bound_store.graphs))
    @test bound_asset.basenode === bound_target
    @test canonical_owner_bound_summary(bound_target) == (
        nodekey = 1,
        label = "Root",
        edges = [(1, 2), (1, 6), (2, 3), (2, 4), (4, 5), (6, 4), (6, 7)],
        finalized = true,
    )

    empty!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS)
    builder_store = LineagesIO.read_lineages(
        network_path,
        LineagesIO.BuilderDescriptor(
            canonical_owner_typed_builder,
            CanonicalOwnerProtocolNode,
            CanonicalOwnerParentCollection,
        ),
    )
    builder_asset = only(collect(builder_store.graphs))
    @test builder_asset.basenode.finalized
    @test (:multi, 4, [2, 6], [3, 6], CanonicalOwnerParentCollection) in
        CANONICAL_OWNER_TYPED_BUILDER_EVENTS

    empty!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS)
    alife_builder_store = load_alife_table(
        inline_alife_table,
        LineagesIO.BuilderDescriptor(
            canonical_owner_typed_builder,
            CanonicalOwnerProtocolNode,
            CanonicalOwnerParentCollection,
        );
        source_path = "<public-alife-builder>",
    )
    alife_builder_asset = only(collect(alife_builder_store.graphs))
    @test alife_builder_asset.basenode.finalized
    @test (:multi, 4, [2, 3], [3, 4], CanonicalOwnerParentCollection) in
        CANONICAL_OWNER_TYPED_BUILDER_EVENTS
end

@testset "read_lineages public surface — failure boundaries" begin
    ambiguous_tree_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "ambiguous_simple_rooted.txt"),
    )
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))
    network_path = abspath(
        joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"),
    )

    ambiguous_error = capture_expected_load_error() do
        LineagesIO.read_lineages(ambiguous_tree_path)
    end
    @test ambiguous_error isa ArgumentError
    @test occursin(".txt", sprint(showerror, ambiguous_error))
    @test occursin("format = :newick", sprint(showerror, ambiguous_error))

    open(tree_path, "r") do io
        stream_error = capture_expected_load_error() do
            LineagesIO.read_lineages(io)
        end
        @test stream_error isa ArgumentError
        @test occursin("source_path", sprint(showerror, stream_error))
        @test occursin("format = :newick", sprint(showerror, stream_error))
    end

    builder_error = capture_expected_load_error() do
        LineagesIO.read_lineages(tree_path; builder = canonical_owner_typed_builder)
    end
    @test builder_error isa ArgumentError
    @test occursin("BuilderDescriptor", sprint(showerror, builder_error))

    node_type_tree_error = capture_expected_load_error() do
        LineagesIO.read_lineages(tree_path, Int)
    end
    @test node_type_tree_error isa ArgumentError
    @test occursin(
        "package-owned node-type load surface",
        sprint(showerror, node_type_tree_error),
    )
    @test !occursin(
        "load(src, Int64)",
        sprint(showerror, node_type_tree_error),
    )

    node_type_network_error = capture_expected_load_error() do
        LineagesIO.read_lineages(network_path, Int)
    end
    @test node_type_network_error isa ArgumentError
    @test occursin(
        "package-owned node-type load surface",
        sprint(showerror, node_type_network_error),
    )
    @test !occursin(
        "load(src, Int64)",
        sprint(showerror, node_type_network_error),
    )

    basenode_error = capture_expected_load_error() do
        LineagesIO.read_lineages(
            network_path,
            PublicSurfaceUntypedTarget("not-typed"),
        )
    end
    @test basenode_error isa ArgumentError
    @test occursin("construction_handle_type", sprint(showerror, basenode_error))
    @test occursin("compatibility wrapper", sprint(showerror, basenode_error))
end
