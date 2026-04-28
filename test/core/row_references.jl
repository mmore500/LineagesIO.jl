@testset "Row references and lookup helpers" begin
    node_table = NodeTable(
        nodekey = [1, 2, 3],
        label = ["root", "left", "right"],
        annotation_columns = (
            posterior = ["0.99", "0.91", nothing],
            species = [nothing, "human", "mouse"],
        ),
    )
    edge_table = EdgeTable(
        edgekey = [1, 2],
        src_nodekey = [1, 1],
        dst_nodekey = [2, 3],
        edgeweight = [0.4, nothing],
        annotation_columns = (bootstrap = [nothing, "97"],),
    )

    nodedata = LineagesIO.NodeRowRef(node_table, 2)
    edgedata = LineagesIO.EdgeRowRef(edge_table, 2)

    @test nodedata.nodekey == 2
    @test edgedata.edgekey == 2
    @test Tables.schema(nodedata) == Tables.schema(node_table)
    @test Tables.schema(edgedata) == Tables.schema(edge_table)
    @test Tables.columnnames(nodedata) == (:nodekey, :label, :posterior, :species)
    @test Tables.columnnames(edgedata) == (:edgekey, :src_nodekey, :dst_nodekey, :edgeweight, :bootstrap)
    @test Tables.getcolumn(nodedata, :label) == "left"
    @test Tables.getcolumn(edgedata, :dst_nodekey) == 3
    @test Tables.getcolumn(nodedata, 3) == "0.91"
    @test Tables.getcolumn(edgedata, 5) == "97"

    @test node_property(nodedata, :posterior) == node_property(node_table, 2, :posterior)
    @test node_property(nodedata, "species") == "human"
    @test edge_property(edgedata, :bootstrap) == edge_property(edge_table, 2, :bootstrap)
    @test edge_property(edgedata, "edgeweight") === nothing

    missing_property_error = try
        node_property(nodedata, :missing_field)
        nothing
    catch err
        err
    end
    @test missing_property_error isa ArgumentError
    @test occursin("Requested node property `:missing_field`", sprint(showerror, missing_property_error))

    missing_nodekey_error = try
        LineagesIO.NodeRowRef(node_table, 4)
        nothing
    catch err
        err
    end
    @test missing_nodekey_error isa ArgumentError
    @test occursin("nodekey 4", sprint(showerror, missing_nodekey_error))

    missing_edgekey_error = try
        LineagesIO.EdgeRowRef(edge_table, 3)
        nothing
    catch err
        err
    end
    @test missing_edgekey_error isa ArgumentError
    @test occursin("edgekey 3", sprint(showerror, missing_edgekey_error))
end
