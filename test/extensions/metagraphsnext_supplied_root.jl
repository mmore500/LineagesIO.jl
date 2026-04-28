using MetaGraphsNext

@testset "MetaGraphsNext supplied-root binding" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    rootnode = extension.MetaGraphsNextNodeHandle()
    store = load(fixture_path, rootnode)
    asset = first(store.graphs)

    @test asset.graph_rootnode === rootnode
    @test rootnode.nodekey == 1
    @test MetaGraphsNext.Graphs.nv(rootnode.graph) == 5
    @test MetaGraphsNext.Graphs.ne(rootnode.graph) == 4
    @test LineagesIO.node_property(asset.node_table, rootnode.nodekey, :posterior) == "0.99"

    multi_graph_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_root_binding_source.trees"))
    multi_graph_error = capture_expected_load_error() do
        load(multi_graph_path, extension.MetaGraphsNextNodeHandle())
    end
    @test multi_graph_error isa ArgumentError
    @test occursin("exactly one graph", sprint(showerror, multi_graph_error))

    prebound_rootnode = extension.MetaGraphsNextNodeHandle()
    prebound_rootnode.nodekey = 99
    prebound_error = capture_expected_load_error() do
        load(fixture_path, prebound_rootnode)
    end
    @test prebound_error isa ArgumentError
    @test occursin("must be unbound", sprint(showerror, prebound_error))

    occupied_rootnode = extension.MetaGraphsNextNodeHandle()
    MetaGraphsNext.Graphs.add_vertex!(
        occupied_rootnode.graph,
        extension.MetaGraphsNextNodeLabel(999),
    )
    occupied_error = capture_expected_load_error() do
        load(fixture_path, occupied_rootnode)
    end
    @test occupied_error isa ArgumentError
    @test occursin("empty `MetaGraph`", sprint(showerror, occupied_error))
end
