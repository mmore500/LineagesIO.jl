@testset "Companion tables and lazy views" begin
    source_table = SourceTable(
        source_idx = [2],
        source_path = ["synthetic.nwk"],
        collection_count = [1],
        graph_count = [1],
    )
    collection_table = CollectionTable(
        collection_idx = [5],
        source_idx = [2],
        collection_label = ["posterior block"],
        graph_count = [1],
    )
    graph_table = GraphTable(
        index = [7],
        source_idx = [2],
        collection_idx = [5],
        collection_graph_idx = [3],
        collection_label = ["posterior block"],
        graph_label = ["graph 3"],
        node_count = [3],
        edge_count = [2],
    )
    node_table = NodeTable(
        nodekey = [1, 2, 3],
        label = ["root", "left", "right"],
        annotation_columns = (posterior = [nothing, "0.91", "0.82"],),
    )
    edge_table = EdgeTable(
        edgekey = [1, 2],
        src_nodekey = [1, 1],
        dst_nodekey = [2, 3],
        edgeweight = [0.4, nothing],
        annotation_columns = (bootstrap = [nothing, "97"],),
    )

    @test Tables.istable(typeof(source_table))
    @test Tables.istable(typeof(collection_table))
    @test Tables.istable(typeof(graph_table))
    @test Tables.istable(typeof(node_table))
    @test Tables.istable(typeof(edge_table))

    @test Tables.columnaccess(typeof(node_table))
    @test Tables.columns(node_table) === node_table
    @test Tables.materializer(typeof(node_table)) === Tables.columntable
    @test Tables.columnnames(node_table) == (:nodekey, :label, :posterior)
    @test Tables.columnnames(edge_table) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight, :bootstrap)
    @test Tables.getcolumn(node_table, :nodekey) == [1, 2, 3]
    @test Tables.getcolumn(edge_table, :edgekey) == [1, 2]
    @test Tables.getcolumn(node_table, :posterior) == Union{Nothing, String}[nothing, "0.91", "0.82"]
    @test Tables.schema(node_table) == Tables.Schema(
        (:nodekey, :label, :posterior),
        (LineagesIO.StructureKeyType, String, Union{Nothing, String}),
    )

    node_rows = collect(Tables.rows(node_table))
    edge_rows = collect(Tables.rows(edge_table))
    @test length(node_rows) == 3
    @test length(edge_rows) == 2
    @test Tables.getcolumn(node_rows[2], :label) == "left"
    @test Tables.getcolumn(edge_rows[2], :dst_nodekey) == 3

    @test node_property(node_table, 2, :posterior) == "0.91"
    @test node_property(node_table, 1, "label") == "root"
    @test edge_property(edge_table, 1, :edgeweight) == 0.4
    @test edge_property(edge_table, 2, "bootstrap") == "97"

    missing_property_error = try
        node_property(node_table, 1, :missing_field)
        nothing
    catch err
        err
    end
    @test missing_property_error isa ArgumentError
    @test occursin("Requested node property `:missing_field`", sprint(showerror, missing_property_error))

    missing_nodekey_error = try
        node_property(node_table, 4, :label)
        nothing
    catch err
        err
    end
    @test missing_nodekey_error isa ArgumentError
    @test occursin("nodekey 4", sprint(showerror, missing_nodekey_error))

    stored_graph = LineagesIO.StoredGraph(
        7,
        2,
        5,
        3,
        "posterior block",
        "graph 3",
        node_table,
        edge_table,
        "synthetic.nwk",
    )
    graphs = LineagesIO.GraphAssetIterator([stored_graph])
    store = LineagesIO.LineageGraphStore(source_table, collection_table, graph_table, graphs)

    @test Base.IteratorSize(typeof(store.graphs)) === Base.HasLength()
    @test !(store.graphs isa AbstractVector)

    asset = first(store.graphs)
    @test asset.index == 7
    @test asset.source_idx == 2
    @test asset.collection_idx == 5
    @test asset.collection_graph_idx == 3
    @test asset.collection_label == "posterior block"
    @test asset.graph_label == "graph 3"
    @test asset.graph_rootnode === nothing
    @test asset.source_path == "synthetic.nwk"
    @test asset.node_table === node_table
    @test asset.edge_table === edge_table
end
