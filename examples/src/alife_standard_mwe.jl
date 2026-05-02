using FileIO: File, load
using LineagesIO
using Tables

# Minimal example loading an alife data standard CSV phylogeny
# (https://alife-data-standards.github.io/alife-data-standards/phylogeny.html)
# through the FileIO entry point and inspecting the authoritative tables.
example_path = normpath(
    joinpath(
        @__DIR__,
        "..",
        "data",
        "alife_sexual_phylogeny.csv",
    ),
)

store = load(File{LineagesIO.AlifeStandardFormat}(example_path))
asset = first(store.graphs)
node_table = asset.node_table
edge_table = asset.edge_table

println("source: ", example_path)
println("graphs in store: ", length(store.graphs))
println("node count: ", length(Tables.getcolumn(node_table, :nodekey)))
println("edge count: ", length(Tables.getcolumn(edge_table, :edgekey)))
println("node columns: ", Tables.columnnames(node_table))
println("retained alife `id` values (as labels): ",
    Tables.getcolumn(node_table, :label))
println("origin_time annotations: ",
    Tables.getcolumn(node_table, :origin_time))
println("multi-parent source detected: ",
    LineagesIO.graph_requires_multi_parent(edge_table))

# Same source loaded directly from an in-memory Tables.jl object via
# `load_alife_table`. Cells may be `Integer`, `AbstractString`, or
# `AbstractVector` — `load_alife_table` coerces them uniformly.
in_memory_table = (
    id            = [0, 1, 2, 3, 4, 5],
    ancestor_list = [Int[], [0], [0], [1], [1, 2], [3, 4]],
    origin_time   = [0, 1, 1, 2, 3, 5],
    trait         = ["founder", "", "extinct-lineage", "", "hybrid", "hybrid"],
)
table_store = load_alife_table(in_memory_table; source_path = "in-memory")
table_asset = first(table_store.graphs)

println()
println("from in-memory Tables.jl input:")
println("  source_path: ", table_asset.source_path)
println("  edge endpoints (src→dst nodekeys): ",
    collect(zip(
        Tables.getcolumn(table_asset.edge_table, :src_nodekey),
        Tables.getcolumn(table_asset.edge_table, :dst_nodekey),
    )))
println("  retained `trait` annotations: ",
    Tables.getcolumn(table_asset.node_table, :trait))
