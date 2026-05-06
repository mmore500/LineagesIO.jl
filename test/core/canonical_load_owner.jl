function assert_same_table(actual, expected)::Nothing
    @test Tables.columnnames(actual) == Tables.columnnames(expected)
    for column_name in Tables.columnnames(expected)
        @test Tables.getcolumn(actual, column_name) == Tables.getcolumn(expected, column_name)
    end
    return nothing
end

function assert_same_asset_tables(actual, expected)::Nothing
    @test actual.collection_label == expected.collection_label
    @test actual.graph_label == expected.graph_label
    @test actual.source_path == expected.source_path
    assert_same_table(actual.node_table, expected.node_table)
    assert_same_table(actual.edge_table, expected.edge_table)
    return nothing
end

function assert_same_store_tables(actual, expected)::Nothing
    assert_same_table(actual.graph_table, expected.graph_table)
    actual_assets = collect(actual.graphs)
    expected_assets = collect(expected.graphs)
    @test length(actual_assets) == length(expected_assets)
    for (actual_asset, expected_asset) in zip(actual_assets, expected_assets)
        assert_same_asset_tables(actual_asset, expected_asset)
    end
    return nothing
end

function assert_asset_destructuring(asset)::Nothing
    graph, basenode, node_table, edge_table = asset
    @test graph === asset.graph
    @test basenode === asset.basenode
    @test node_table === asset.node_table
    @test edge_table === asset.edge_table
    @test length(asset) == 4
    return nothing
end

mutable struct CanonicalOwnerProtocolNode
    nodekey::LineagesIO.StructureKeyType
    label::String
    child_collection::Vector{Any}
    finalized::Bool
end

function canonical_owner_protocol_shape(node::CanonicalOwnerProtocolNode)
    return (
        nodekey = node.nodekey,
        label = node.label,
        finalized = node.finalized,
        children = [canonical_owner_protocol_shape(child) for child in node.child_collection],
    )
end

function LineagesIO.add_child(
        ::Nothing,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = nothing,
        nodedata,
    )
    return CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
end

function LineagesIO.add_child(
        parent::CanonicalOwnerProtocolNode,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata,
        nodedata,
    )
    child = CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
    push!(parent.child_collection, child)
    return child
end

function LineagesIO.add_child(
        parent_collection::AbstractVector{CanonicalOwnerProtocolNode},
        nodekey,
        label,
        edgekeys::AbstractVector{LineagesIO.StructureKeyType},
        edgeweights::AbstractVector;
        edgedata,
        nodedata,
    )
    child = CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
    for parent in parent_collection
        push!(parent.child_collection, child)
    end
    return child
end

function LineagesIO.finalize_graph!(basenode::CanonicalOwnerProtocolNode)
    basenode.finalized = true
    return basenode
end

struct CanonicalOwnerParentCollection <: AbstractVector{CanonicalOwnerProtocolNode}
    nodes::Vector{CanonicalOwnerProtocolNode}
end

function CanonicalOwnerParentCollection(
        nodes::AbstractVector{CanonicalOwnerProtocolNode},
    )::CanonicalOwnerParentCollection
    return CanonicalOwnerParentCollection(collect(nodes))
end

Base.IndexStyle(::Type{CanonicalOwnerParentCollection}) = IndexLinear()
Base.size(parent_collection::CanonicalOwnerParentCollection) = size(parent_collection.nodes)
Base.getindex(parent_collection::CanonicalOwnerParentCollection, index::Int) = parent_collection.nodes[index]

mutable struct CanonicalOwnerBoundTarget
    nodekey::Union{Nothing, LineagesIO.StructureKeyType}
    label::String
    edges::Vector{Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}}
    finalized::Bool
end

struct CanonicalOwnerBoundCursor
    target::CanonicalOwnerBoundTarget
    nodekey::LineagesIO.StructureKeyType
end

function canonical_owner_bound_summary(target::CanonicalOwnerBoundTarget)
    return (
        nodekey = target.nodekey,
        label = target.label,
        edges = sort(copy(target.edges)),
        finalized = target.finalized,
    )
end

function LineagesIO.bind_basenode!(
        target::CanonicalOwnerBoundTarget,
        nodekey,
        label;
        nodedata,
    )
    target.nodekey = nodekey
    target.label = String(label)
    return CanonicalOwnerBoundCursor(target, nodekey)
end

function LineagesIO.add_child(
        parent::CanonicalOwnerBoundCursor,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata,
        nodedata,
    )
    push!(parent.target.edges, (parent.nodekey, nodekey))
    return CanonicalOwnerBoundCursor(parent.target, nodekey)
end

function LineagesIO.add_child(
        parent_collection::AbstractVector{CanonicalOwnerBoundCursor},
        nodekey,
        label,
        edgekeys::AbstractVector{LineagesIO.StructureKeyType},
        edgeweights::AbstractVector;
        edgedata,
        nodedata,
    )
    target = first(parent_collection).target
    for parent in parent_collection
        push!(target.edges, (parent.nodekey, nodekey))
    end
    return CanonicalOwnerBoundCursor(target, nodekey)
end

function LineagesIO.finalize_graph!(cursor::CanonicalOwnerBoundCursor)
    cursor.target.finalized = true
    return cursor
end

function LineagesIO.basenode_from_finalized(
        cursor::CanonicalOwnerBoundCursor,
    )::CanonicalOwnerBoundTarget
    return cursor.target
end

mutable struct CanonicalOwnerDriftNode
    child_collection::Vector{Any}
end

function LineagesIO.add_child(
        parent::CanonicalOwnerDriftNode,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata,
        nodedata,
    )
    child = CanonicalOwnerDriftNode(Any[])
    push!(parent.child_collection, child)
    return child
end

mutable struct CanonicalOwnerDriftBoundTarget
    labels::Vector{String}
end

struct CanonicalOwnerDriftBoundCursor
    target::CanonicalOwnerDriftBoundTarget
end

struct CanonicalOwnerWrongBoundCursor
    target::CanonicalOwnerDriftBoundTarget
end

function LineagesIO.bind_basenode!(
        target::CanonicalOwnerDriftBoundTarget,
        nodekey,
        label;
        nodedata,
    )
    push!(target.labels, String(label))
    return CanonicalOwnerDriftBoundCursor(target)
end

function LineagesIO.add_child(
        parent::CanonicalOwnerDriftBoundCursor,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata,
        nodedata,
    )
    push!(parent.target.labels, String(label))
    return CanonicalOwnerWrongBoundCursor(parent.target)
end

function LineagesIO.finalize_graph!(
        cursor::Union{
            CanonicalOwnerDriftBoundCursor,
            CanonicalOwnerWrongBoundCursor,
        },
    )
    return cursor
end

const CANONICAL_OWNER_TYPED_BUILDER_EVENTS = Any[]

function canonical_owner_typed_builder(
        ::Nothing,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = nothing,
        nodedata,
    )::CanonicalOwnerProtocolNode
    push!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS, (:root, nodekey, String(label)))
    return CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
end

function canonical_owner_typed_builder(
        parent::CanonicalOwnerProtocolNode,
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata,
        nodedata,
    )::CanonicalOwnerProtocolNode
    push!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS, (:single, nodekey, parent.nodekey, edgekey))
    child = CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
    push!(parent.child_collection, child)
    return child
end

function canonical_owner_typed_builder(
        parent_collection::CanonicalOwnerParentCollection,
        nodekey,
        label,
        edgekeys,
        edgeweights;
        edgedata,
        nodedata,
    )::CanonicalOwnerProtocolNode
    push!(
        CANONICAL_OWNER_TYPED_BUILDER_EVENTS,
        (
            :multi,
            nodekey,
            [parent.nodekey for parent in parent_collection],
            collect(edgekeys),
            typeof(parent_collection),
        ),
    )
    child = CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
    for parent in parent_collection
        push!(parent.child_collection, child)
    end
    return child
end

function canonical_owner_single_parent_builder(
        parent::Union{Nothing, CanonicalOwnerProtocolNode},
        nodekey,
        label,
        edgekey,
        edgeweight;
        edgedata = nothing,
        nodedata,
    )::CanonicalOwnerProtocolNode
    child = CanonicalOwnerProtocolNode(
        nodekey,
        String(label),
        Any[],
        false,
    )
    parent === nothing || push!(parent.child_collection, child)
    return child
end

@testset "Canonical load owner tables-only sources" begin
    newick_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    alife_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_alife.csv"))

    direct_newick_file_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(newick_path),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    direct_newick_file_asset = only(collect(direct_newick_file_store.graphs))
    @test direct_newick_file_asset.source_path == newick_path
    assert_asset_destructuring(direct_newick_file_asset)

    wrapper_newick_file_store = load(File{LineagesIO.NewickFormat}(newick_path))
    assert_same_store_tables(wrapper_newick_file_store, direct_newick_file_store)

    open(newick_path, "r") do io
        direct_newick_stream_store = LineagesIO.canonical_load(
            LineagesIO.NewickStreamSourceDescriptor(io, newick_path),
            LineagesIO.TablesOnlyLoadRequest(),
        )
        wrapper_newick_stream_store = open(newick_path, "r") do wrapper_io
            return load(Stream{LineagesIO.NewickFormat}(wrapper_io, newick_path))
        end
        assert_same_store_tables(wrapper_newick_stream_store, direct_newick_stream_store)
        assert_same_table(
            only(collect(direct_newick_stream_store.graphs)).node_table,
            direct_newick_file_asset.node_table,
        )
        assert_same_table(
            only(collect(direct_newick_stream_store.graphs)).edge_table,
            direct_newick_file_asset.edge_table,
        )
    end

    direct_newick_text_store = LineagesIO.canonical_load(
        LineagesIO.NewickTextSourceDescriptor(
            read(newick_path, String),
            "<canonical-newick-text>",
        ),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    direct_newick_text_asset = only(collect(direct_newick_text_store.graphs))
    @test direct_newick_text_asset.source_path == "<canonical-newick-text>"
    assert_same_table(direct_newick_text_asset.node_table, direct_newick_file_asset.node_table)
    assert_same_table(direct_newick_text_asset.edge_table, direct_newick_file_asset.edge_table)

    direct_alife_file_store = LineagesIO.canonical_load(
        LineagesIO.AlifeFilePathSourceDescriptor(alife_path),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    direct_alife_file_asset = only(collect(direct_alife_file_store.graphs))
    @test direct_alife_file_asset.source_path == alife_path
    assert_asset_destructuring(direct_alife_file_asset)

    wrapper_alife_file_store = load(File{LineagesIO.AlifeStandardFormat}(alife_path))
    assert_same_store_tables(wrapper_alife_file_store, direct_alife_file_store)

    open(alife_path, "r") do io
        direct_alife_stream_store = LineagesIO.canonical_load(
            LineagesIO.AlifeStreamSourceDescriptor(io, alife_path),
            LineagesIO.TablesOnlyLoadRequest(),
        )
        wrapper_alife_stream_store = open(alife_path, "r") do wrapper_io
            return load(Stream{LineagesIO.AlifeStandardFormat}(wrapper_io, alife_path))
        end
        assert_same_store_tables(wrapper_alife_stream_store, direct_alife_stream_store)
        assert_same_table(
            only(collect(direct_alife_stream_store.graphs)).node_table,
            direct_alife_file_asset.node_table,
        )
        assert_same_table(
            only(collect(direct_alife_stream_store.graphs)).edge_table,
            direct_alife_file_asset.edge_table,
        )
    end

    direct_alife_text_store = LineagesIO.canonical_load(
        LineagesIO.AlifeTextSourceDescriptor(
            read(alife_path, String),
            "<canonical-alife-text>",
        ),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    direct_alife_text_asset = only(collect(direct_alife_text_store.graphs))
    @test direct_alife_text_asset.source_path == "<canonical-alife-text>"
    assert_same_table(direct_alife_text_asset.node_table, direct_alife_file_asset.node_table)
    assert_same_table(direct_alife_text_asset.edge_table, direct_alife_file_asset.edge_table)
end

@testset "Canonical load owner alife-table requests and wrapper parity" begin
    multi_parent_source_path = "<canonical-inline-alife>"
    inline_multi_parent_alife_table = (
        id = [0, 1, 2, 3],
        ancestor_list = ["[NONE]", "[0]", "[0]", "[1,2]"],
        origin_time = ["0", "1", "1", "2"],
    )
    single_parent_source_path = "<canonical-inline-single-parent-alife>"
    inline_single_parent_alife_table = (
        id = [0, 1, 2, 3],
        ancestor_list = ["[NONE]", "[0]", "[0]", "[1]"],
        origin_time = ["0", "1", "1", "2"],
    )

    direct_tables_store = LineagesIO.canonical_load(
        LineagesIO.AlifeTableSourceDescriptor(
            inline_multi_parent_alife_table,
            multi_parent_source_path,
        ),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    wrapper_tables_store = load_alife_table(
        inline_multi_parent_alife_table;
        source_path = multi_parent_source_path,
    )
    assert_same_store_tables(wrapper_tables_store, direct_tables_store)

    direct_node_store = LineagesIO.canonical_load(
        LineagesIO.AlifeTableSourceDescriptor(
            inline_multi_parent_alife_table,
            multi_parent_source_path,
        ),
        LineagesIO.NodeTypeLoadRequest(CanonicalOwnerProtocolNode),
    )
    wrapper_node_store = load_alife_table(
        inline_multi_parent_alife_table,
        CanonicalOwnerProtocolNode;
        source_path = multi_parent_source_path,
    )
    assert_same_store_tables(wrapper_node_store, direct_node_store)

    direct_node_asset = only(collect(direct_node_store.graphs))
    wrapper_node_asset = only(collect(wrapper_node_store.graphs))
    assert_asset_destructuring(direct_node_asset)
    @test canonical_owner_protocol_shape(direct_node_asset.basenode) ==
        canonical_owner_protocol_shape(wrapper_node_asset.basenode)
    @test direct_node_asset.basenode.child_collection[1].child_collection[1] ===
        direct_node_asset.basenode.child_collection[2].child_collection[1]
    assert_same_table(
        direct_node_asset.node_table,
        only(collect(direct_tables_store.graphs)).node_table,
    )
    assert_same_table(
        direct_node_asset.edge_table,
        only(collect(direct_tables_store.graphs)).edge_table,
    )

    direct_bound_target = CanonicalOwnerBoundTarget(
        nothing,
        "",
        Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}[],
        false,
    )
    direct_bound_store = LineagesIO.canonical_load(
        LineagesIO.AlifeTableSourceDescriptor(
            inline_multi_parent_alife_table,
            multi_parent_source_path,
        ),
        LineagesIO.BasenodeLoadRequest(
            direct_bound_target,
            CanonicalOwnerBoundCursor,
        ),
    )
    direct_bound_asset = only(collect(direct_bound_store.graphs))
    assert_asset_destructuring(direct_bound_asset)
    @test direct_bound_asset.basenode === direct_bound_target
    @test canonical_owner_bound_summary(direct_bound_target) == (
        nodekey = 1,
        label = "0",
        edges = [(1, 2), (1, 3), (2, 4), (3, 4)],
        finalized = true,
    )
    assert_same_table(
        direct_bound_asset.node_table,
        only(collect(direct_tables_store.graphs)).node_table,
    )
    assert_same_table(
        direct_bound_asset.edge_table,
        only(collect(direct_tables_store.graphs)).edge_table,
    )

    wrapper_bound_target = CanonicalOwnerBoundTarget(
        nothing,
        "",
        Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}[],
        false,
    )
    wrapper_bound_store = load_alife_table(
        inline_single_parent_alife_table,
        wrapper_bound_target;
        source_path = single_parent_source_path,
    )
    direct_single_parent_tables_store = LineagesIO.canonical_load(
        LineagesIO.AlifeTableSourceDescriptor(
            inline_single_parent_alife_table,
            single_parent_source_path,
        ),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    wrapper_bound_asset = only(collect(wrapper_bound_store.graphs))
    @test wrapper_bound_asset.basenode === wrapper_bound_target
    @test canonical_owner_bound_summary(wrapper_bound_target) == (
        nodekey = 1,
        label = "0",
        edges = [(1, 2), (1, 3), (2, 4)],
        finalized = true,
    )
    @test wrapper_bound_asset.source_path == single_parent_source_path
    assert_same_table(
        wrapper_bound_asset.node_table,
        only(collect(direct_single_parent_tables_store.graphs)).node_table,
    )
    assert_same_table(
        wrapper_bound_asset.edge_table,
        only(collect(direct_single_parent_tables_store.graphs)).edge_table,
    )
end

@testset "Canonical load owner supplied-basenode compatibility boundaries" begin
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    network_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    single_parent_target = CanonicalOwnerBoundTarget(
        nothing,
        "",
        Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}[],
        false,
    )
    single_parent_store = load(
        File{LineagesIO.NewickFormat}(tree_path),
        single_parent_target,
    )
    single_parent_asset = only(collect(single_parent_store.graphs))
    direct_tables_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(tree_path),
        LineagesIO.TablesOnlyLoadRequest(),
    )
    @test single_parent_asset.basenode === single_parent_target
    @test canonical_owner_bound_summary(single_parent_target) == (
        nodekey = 1,
        label = "Root",
        edges = [(1, 2), (1, 5), (2, 3), (2, 4)],
        finalized = true,
    )
    assert_same_table(
        single_parent_asset.node_table,
        only(collect(direct_tables_store.graphs)).node_table,
    )
    assert_same_table(
        single_parent_asset.edge_table,
        only(collect(direct_tables_store.graphs)).edge_table,
    )

    legacy_network_error = capture_expected_load_error() do
        load(
            File{LineagesIO.NewickFormat}(network_path),
            CanonicalOwnerBoundTarget(
                nothing,
                "",
                Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}[],
                false,
            ),
        )
    end
    @test legacy_network_error isa ArgumentError
    @test occursin(
        "explicit handle-type contract",
        sprint(showerror, legacy_network_error),
    )

    legacy_alife_error = capture_expected_load_error() do
        load_alife_table(
            (
                id = [0, 1, 2, 3],
                ancestor_list = ["[NONE]", "[0]", "[0]", "[1,2]"],
                origin_time = ["0", "1", "1", "2"],
            ),
            CanonicalOwnerBoundTarget(
                nothing,
                "",
                Tuple{LineagesIO.StructureKeyType, LineagesIO.StructureKeyType}[],
                false,
            );
            source_path = "<legacy-multi-parent-alife>",
        )
    end
    @test legacy_alife_error isa ArgumentError
    @test occursin(
        "explicit handle-type contract",
        sprint(showerror, legacy_alife_error),
    )
end

@testset "Canonical load owner typed builder and wrapper compatibility" begin
    empty!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS)
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    direct_tree_store = LineagesIO.canonical_load(
        LineagesIO.NewickTextSourceDescriptor(
            read(tree_path, String),
            "<canonical-typed-builder-tree>",
        ),
        LineagesIO.TypedBuilderLoadRequest(
            canonical_owner_typed_builder,
            CanonicalOwnerProtocolNode,
            CanonicalOwnerParentCollection,
        ),
    )
    direct_tree_asset = only(collect(direct_tree_store.graphs))
    assert_asset_destructuring(direct_tree_asset)
    @test direct_tree_asset.basenode.finalized
    @test direct_tree_asset.basenode.label == "Root"

    canonical_builder_boundary_error = try
        LineagesIO.canonical_load(
            LineagesIO.NewickTextSourceDescriptor(
                read(tree_path, String),
                "<canonical-builder-compat-boundary>",
            );
            builder = canonical_owner_typed_builder,
        )
        nothing
    catch err
        err
    end
    @test canonical_builder_boundary_error isa MethodError

    empty!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS)
    wrapper_tree_store = load(
        File{LineagesIO.NewickFormat}(tree_path);
        builder = canonical_owner_typed_builder,
    )
    wrapper_tree_asset = only(collect(wrapper_tree_store.graphs))
    assert_same_table(direct_tree_asset.node_table, wrapper_tree_asset.node_table)
    assert_same_table(direct_tree_asset.edge_table, wrapper_tree_asset.edge_table)
    @test canonical_owner_protocol_shape(direct_tree_asset.basenode) ==
        canonical_owner_protocol_shape(wrapper_tree_asset.basenode)

    empty!(CANONICAL_OWNER_TYPED_BUILDER_EVENTS)
    network_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))
    direct_network_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(network_path),
        LineagesIO.TypedBuilderLoadRequest(
            canonical_owner_typed_builder,
            CanonicalOwnerProtocolNode,
            CanonicalOwnerParentCollection,
        ),
    )
    direct_network_asset = only(collect(direct_network_store.graphs))
    @test direct_network_asset.basenode.finalized
    @test (:multi, 4, [2, 6], [3, 6], CanonicalOwnerParentCollection) in
        CANONICAL_OWNER_TYPED_BUILDER_EVENTS

    typed_builder_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(network_path),
            LineagesIO.TypedBuilderLoadRequest(
                canonical_owner_single_parent_builder,
                CanonicalOwnerProtocolNode,
                CanonicalOwnerParentCollection,
            ),
        )
    end
    @test typed_builder_error isa ArgumentError
    @test occursin(
        "supplied typed builder request",
        sprint(showerror, typed_builder_error),
    )

    wrapper_builder_error = capture_expected_load_error() do
        load(
            File{LineagesIO.NewickFormat}(network_path);
            builder = canonical_owner_single_parent_builder,
        )
    end
    @test wrapper_builder_error isa ArgumentError
    @test occursin(
        "supplied `builder` callback",
        sprint(showerror, wrapper_builder_error),
    )
end

@testset "Canonical load owner Newick node-type wrapper parity" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    direct_store = LineagesIO.canonical_load(
        LineagesIO.NewickFilePathSourceDescriptor(fixture_path),
        LineagesIO.NodeTypeLoadRequest(CanonicalOwnerProtocolNode),
    )
    wrapper_store = load(
        File{LineagesIO.NewickFormat}(fixture_path),
        CanonicalOwnerProtocolNode,
    )
    assert_same_store_tables(wrapper_store, direct_store)

    direct_asset = only(collect(direct_store.graphs))
    wrapper_asset = only(collect(wrapper_store.graphs))
    assert_asset_destructuring(direct_asset)
    @test canonical_owner_protocol_shape(direct_asset.basenode) ==
        canonical_owner_protocol_shape(wrapper_asset.basenode)
end

@testset "Canonical load owner descendant handle enforcement" begin
    tree_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))
    network_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))

    function LineagesIO.add_child(
            parent::CanonicalOwnerProtocolNode,
            nodekey,
            label,
            edgekey,
            edgeweight;
            edgedata,
            nodedata,
        )
        child = CanonicalOwnerDriftNode(Any[])
        push!(parent.child_collection, child)
        return child
    end

    single_parent_node_drift_error = capture_expected_load_error() do
        load(File{LineagesIO.NewickFormat}(tree_path), CanonicalOwnerProtocolNode)
    end
    @test single_parent_node_drift_error isa ArgumentError
    @test occursin(
        "requires a value compatible",
        sprint(showerror, single_parent_node_drift_error),
    )

    function LineagesIO.add_child(
            parent::CanonicalOwnerProtocolNode,
            nodekey,
            label,
            edgekey,
            edgeweight;
            edgedata,
            nodedata,
        )
        child = CanonicalOwnerProtocolNode(
            nodekey,
            String(label),
            Any[],
            false,
        )
        push!(parent.child_collection, child)
        return child
    end

    function LineagesIO.add_child(
            parent_collection::AbstractVector{CanonicalOwnerProtocolNode},
            nodekey,
            label,
            edgekeys::AbstractVector{LineagesIO.StructureKeyType},
            edgeweights::AbstractVector;
            edgedata,
            nodedata,
        )
        child = CanonicalOwnerDriftNode(Any[])
        for parent in parent_collection
            push!(parent.child_collection, child)
        end
        return child
    end

    multi_parent_node_drift_error = capture_expected_load_error() do
        load(File{LineagesIO.NewickFormat}(network_path), CanonicalOwnerProtocolNode)
    end
    @test multi_parent_node_drift_error isa ArgumentError
    @test occursin(
        "multi-parent child-construction",
        sprint(showerror, multi_parent_node_drift_error),
    )
    @test occursin(
        "requires a value compatible",
        sprint(showerror, multi_parent_node_drift_error),
    )

    supplied_basenode_drift_error = capture_expected_load_error() do
        LineagesIO.canonical_load(
            LineagesIO.NewickFilePathSourceDescriptor(tree_path),
            LineagesIO.BasenodeLoadRequest(
                CanonicalOwnerDriftBoundTarget(String[]),
                CanonicalOwnerDriftBoundCursor,
            ),
        )
    end
    @test supplied_basenode_drift_error isa ArgumentError
    @test occursin(
        "CanonicalOwnerDriftBoundCursor",
        sprint(showerror, supplied_basenode_drift_error),
    )
    @test occursin(
        "child-construction",
        sprint(showerror, supplied_basenode_drift_error),
    )
end
