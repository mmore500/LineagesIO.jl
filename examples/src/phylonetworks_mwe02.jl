using FileIO
using LineagesIO
using PhyloNetworks: HybridNetwork, writenewick
using Tables

# Explicit format override for a tree-compatible rooted source, followed by
# supplied-target binding for the rooted-network path.
tree_path = normpath(
    joinpath(
        @__DIR__,
        "..",
        "data",
        "phylonetworks_mwe02_tree_compatible_rooted.txt",
    ),
)
tree_store = load(File{format"Newick"}(tree_path), HybridNetwork)
tree_asset = first(tree_store.graphs)
tree = tree_asset.materialized

println("explicit override path: ", tree_path)
println("tree-compatible materialized type: ", typeof(tree))
println("tree root node number: ", tree.node[tree.rooti].number)
println("tree node labels from authoritative table: ", Tables.getcolumn(tree_asset.node_table, :label))
println("round-trip tree newick: ", writenewick(tree))

network_path = normpath(
    joinpath(
        @__DIR__,
        "..",
        "data",
        "phylonetworks_mwe01_rooted_network_with_annotations.nwk",
    ),
)
target = HybridNetwork()
network_store = load(network_path, target)
network_asset = first(network_store.graphs)

println("supplied-target rooted-network path: ", network_path)
println("supplied target reused: ", network_asset.materialized === target)
println(
    "graph coordinates: ",
    (
        network_asset.index,
        network_asset.source_idx,
        network_asset.collection_idx,
        network_asset.collection_graph_idx,
    ),
)
println("network hybrid count: ", target.numhybrids)
println(
    "retained hybrid-edge gamma values: ",
    Tables.getcolumn(network_asset.edge_table, :gamma)[[3, 6]],
)
