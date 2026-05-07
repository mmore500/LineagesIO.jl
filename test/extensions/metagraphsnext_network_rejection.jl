using MetaGraphsNext

@testset "MetaGraphsNext read_lineages multi-parent rejection wording" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))

    node_type_error = capture_expected_load_error() do
        LineagesIO.read_lineages(fixture_path, MetaGraph)
    end
    @test node_type_error isa ArgumentError
    node_type_text = sprint(showerror, node_type_error)
    @test occursin("library-created `MetaGraph` target path", node_type_text)
    @test occursin("caller-supplied target path", node_type_text)
    @test !occursin("read_lineages(source, MetaGraph)", node_type_text)
    @test !occursin("load(source, MetaGraph)", node_type_text)
end

@testset "MetaGraphsNext multi-parent network loading" begin
    fixture_path = abspath(joinpath(@__DIR__, "..", "fixtures", "rooted_network_with_annotations.nwk"))

    node_type_error = capture_expected_load_error() do
        load(fixture_path, MetaGraph)
    end
    @test node_type_error isa Exception
    node_type_text = sprint(showerror, node_type_error)
    @test occursin("library-created `MetaGraph` target path", node_type_text)
    @test occursin("caller-supplied target path", node_type_text)
    @test !occursin("read_lineages(source, MetaGraph)", node_type_text)
    @test !occursin("load(source, MetaGraph)", node_type_text)

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
    @test MetaGraphsNext.Graphs.nv(graph) == 7
    @test MetaGraphsNext.Graphs.ne(graph) == 7
end
