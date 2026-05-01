using FileIO: load
using LineagesIO
using PhyloNetworks: HybridNetwork
using Tables

# Minimal native PhyloNetworks materialization from a rooted-network-capable
# Newick source while keeping the authoritative LineagesIO tables available.
example_path = normpath(
    joinpath(
        @__DIR__,
        "..",
        "data",
        "phylonetworks_mwe01_rooted_network_with_annotations.nwk",
    ),
)

store = load(example_path, HybridNetwork)
asset = first(store.graphs)

net = asset.graph
node_table = asset.node_table
edge_table = asset.edge_table

println("source: ", example_path)
println("constructed graph type: ", typeof(net))
println("basenode number: ", asset.basenode.number)
println("node count: ", net.numnodes)
println("edge count: ", net.numedges)
println("hybrid count: ", net.numhybrids)
println("node columns: ", Tables.columnnames(node_table))
println("edge columns: ", Tables.columnnames(edge_table))
println(
    "hybrid node posterior from authoritative table: ",
    LineagesIO.node_property(node_table, 4, :posterior),
)
println(
    "retained hybrid-edge gamma values from authoritative table: ",
    Tables.getcolumn(edge_table, :gamma)[[3, 6]],
)

println("hybrid edges in the native HybridNetwork:")
for edge in sort(net.edge; by = edge -> edge.number)
    edge.hybrid || continue
    println(
        "  edge $(edge.number): gamma=$(edge.gamma), ismajor=$(edge.ismajor)",
    )
end
