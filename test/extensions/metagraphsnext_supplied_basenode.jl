using MetaGraphsNext

@testset "MetaGraphsNext supplied-basenode binding" begin
    extension = something(Base.get_extension(LineagesIO, :MetaGraphsNextIO))
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "annotated_simple_rooted.nwk"))

    graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        Symbol,
        Nothing,
        Nothing,
    )
    store = load(fixture_path, graph)
    asset = first(store.graphs)

    @test asset.graph === graph
    @test asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(graph) == 5
    @test MetaGraphsNext.Graphs.ne(graph) == 4
    @test LineagesIO.node_property(asset.node_table, 1, :posterior) == "0.99"

    multi_graph_path = abspath(joinpath(@__DIR__, "..", "fixtures", "multi_graph_basenode_binding_source.trees"))
    multi_graph_error = capture_expected_load_error() do
        load(multi_graph_path, extension.default_metagraph())
    end
    @test multi_graph_error isa ArgumentError
    @test occursin("exactly one graph", sprint(showerror, multi_graph_error))

    occupied_graph = extension.default_metagraph()
    MetaGraphsNext.Graphs.add_vertex!(occupied_graph, Symbol(999))
    occupied_error = capture_expected_load_error() do
        load(fixture_path, occupied_graph)
    end
    @test occupied_error isa ArgumentError
    @test occursin("must be empty", sprint(showerror, occupied_error))

    wrong_label_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{LineagesIO.StructureKeyType}(),
        String,
        Nothing,
        Nothing,
    )
    wrong_label_error = capture_expected_load_error() do
        load(fixture_path, wrong_label_graph)
    end
    @test wrong_label_error isa ArgumentError
    @test occursin("must use `Symbol`", sprint(showerror, wrong_label_error))
end

@testset "MetaGraphsNext supplied-instance EdgeData dispatch" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "single_rooted_tree.nwk"))

    float_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        Nothing,
        Float64,
        nothing,
        identity,
        0.0,
    )
    float_store = load(fixture_path, float_graph)
    float_asset = first(float_store.graphs)

    @test float_asset.graph === float_graph
    @test float_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(float_graph) == 5
    @test MetaGraphsNext.Graphs.ne(float_graph) == 4
    @test float_graph[Symbol(1), Symbol(2)] ≈ 2.0   # Root→Inner
    @test float_graph[Symbol(2), Symbol(3)] ≈ 1.5   # Inner→A
    @test float_graph[Symbol(2), Symbol(4)] ≈ 0.25  # Inner→(unnamed)

    rowref_graph = MetaGraphsNext.MetaGraph(
        MetaGraphsNext.Graphs.SimpleDiGraph{Int}(),
        Symbol,
        LineagesIO.NodeRowRef,
        LineagesIO.EdgeRowRef,
        nothing,
        ed -> begin
            w = LineagesIO.edge_property(ed, :edgeweight)
            w === nothing ? 1.0 : w
        end,
        1.0,
    )
    rowref_store = load(fixture_path, rowref_graph)
    rowref_asset = first(rowref_store.graphs)
    rowref_graph_out = rowref_asset.graph

    @test rowref_graph_out === rowref_graph
    @test rowref_asset.basenode === Symbol(1)
    @test MetaGraphsNext.Graphs.nv(rowref_graph_out) == 5
    @test LineagesIO.node_property(rowref_graph_out[Symbol(1)], :label) == "Root"
    @test LineagesIO.edge_property(rowref_graph_out[Symbol(1), Symbol(2)], :edgeweight) ≈ 2.0
end
