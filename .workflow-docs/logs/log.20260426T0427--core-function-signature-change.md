Full Project File Inventory
All Files — Impact Classification
File	Impact Level	Protocol Hits
src/LineagesIO.jl	None (stub, empty)	0
test/runtests.jl	None (stub, empty)	0
README.md	None	0
docs/src/index.md	None	0
docs/make.jl	None	0
Project.toml	None	0
AUTHORS.md	None	0
CONTRIBUTING.md	None	0
LICENSE.md	None	0
STYLE-julia.md	None	0
STYLE-architecture.md	None	0
STYLE-vocabulary.md	None	0
STYLE-docs.md	None	0
STYLE-git.md	None	0
STYLE-makie.md	None	0
STYLE-upstream-contracts.md	None	0
STYLE-verification.md	None	0
STYLE-workflow-docs.md	None	0
STYLE-writing.md	None	0
docs/build/ (all build artifacts)	None	0
examples/Project.toml	None	0
.vscode/settings.json	None	0
.codex	None	0
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-02--tasking.md	None	0
design/brief.md	High — canonical definitions	40+
design/brief--community-support-objectives.md	High — concrete implementations	20+
.workflow-docs/runs/20260425T2251--phase-01/01_prd.md	High — signature block + user stories	60+
.workflow-docs/runs/20260425T2251--phase-01/02_tranches.md	High — signature block	30+
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-01--tasking.md	High — prescriptive task constraints	12
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-03--tasking.md	Medium — orchestration contract	20+
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-04--tasking.md	Medium — Newick parser task	12
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-05--tasking.md	Low — only builder kwarg references	4
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-06--tasking.md	Medium — LineageNetwork parser task	12
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-07--tasking.md	Low-Medium — ExtNewick parser task	6
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-08--tasking.md	High — PhyloNetworks extension implementations	20+
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-09--tasking.md	High — PhyloExt extension implementations	15+
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-10--tasking.md	Low — documentation task	4
.workflow-docs/logs/log.20260424--superceded-brief.md	Low (superseded, historical)	unknown
Impacted Files — Line-by-Line
design/brief.md
This is the primary canonical source of the signature. All other files derive from it.

Style 1 extension example (entry-point overload)
Line	Verbatim
164	function LineagesIO.add_child(
165	:: Nothing, # parent — dispatch-only; entry-point has no parent
166	node_idx :: Int,
167	label :: AbstractString,
168	:: Union{EdgeUnitT, Nothing}, # edgeweight — no incoming edge for entry-point
169	:: Nothing, # edgedata — no parent edge for entry-point
170	nodedata :: NodeRowT,
171	) where {EdgeUnitT, NodeRowT}
Style 1 extension example (non-entry-point overload)
Line	Verbatim
175	function LineagesIO.add_child(
176	parent :: MyNode,
177	node_idx :: Int,
178	label :: AbstractString,
179	edgeweight :: Union{EdgeUnitT, Nothing},
180	:: EdgeRowT, # edgedata row — use fields as needed, e.g. edgedata.gamma
181	nodedata :: NodeRowT,
182	) where {EdgeUnitT, NodeRowT, EdgeRowT}
Style 2 callback lambda example
Line	Verbatim
207	result = load("file.nwk"; builder = (parent, node_idx, label, edgeweight, edgedata, nodedata) -> ...)
Canonical protocol — network level
Line	Verbatim
226	function add_child(
227	:: AbstractVector{NodeT}, # parents
228	:: Int, # node_idx
229	:: AbstractString, # label
230	:: AbstractVector{Union{EdgeUnitT, Nothing}}, # edgeweights
231	:: AbstractVector{EdgeRowT}, # edgedata
232	:: NodeRowT, # nodedata
233	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT, EdgeRowT} end
Canonical protocol — single-parent entry-point
Line	Verbatim
250	function add_child(
251	:: Nothing, # parent — entry-point; no parent edge
252	:: Int, # node_idx
253	:: AbstractString, # label
254	:: Union{EdgeUnitT, Nothing}, # edgeweight — no incoming edge for entry-point
255	:: Nothing, # edgedata — no parent edge for entry-point
256	:: NodeRowT, # nodedata
257	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT} end # entry-point; called exactly once per graph
Canonical protocol — single-parent non-entry-point
Line	Verbatim
259	function add_child(
260	:: NodeT, # parent
261	:: Int, # node_idx
262	:: AbstractString, # label
263	:: Union{EdgeUnitT, Nothing}, # edgeweight
264	:: EdgeRowT, # edgedata — one row for the single parent edge
265	:: NodeRowT, # nodedata
266	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT, EdgeRowT} end # subsequent node
design/brief--community-support-objectives.md
PhyloNetworksExt — entry-point overload (concrete implementation)
Line	Verbatim
426	function LineagesIO.add_child(
427	parents :: AbstractVector{PhyloNetworksNodeHandle},
428	node_idx :: Int,
429	label :: AbstractString,
430	:: AbstractVector{Union{EdgeUnitT, Nothing}}, # edgeweights — empty for entry-point
431	:: AbstractVector, # edgedata — empty for entry-point
432	:: NodeRowT, # nodedata — no metadata store on HybridNetwork/Node
433	) where {EdgeUnitT, NodeRowT}
PhyloNetworksExt — non-entry-point overload (concrete implementation)
Line	Verbatim
445	function LineagesIO.add_child(
446	parents :: AbstractVector{PhyloNetworksNodeHandle},
447	node_idx :: Int,
448	label :: AbstractString,
449	edgeweights :: AbstractVector{Union{EdgeUnitT, Nothing}},
450	edgedata :: AbstractVector{EdgeRowT},
451	nodedata :: NodeRowT,
452	) where {EdgeUnitT, NodeRowT, EdgeRowT}
PhyloNetworksExt — finalize_graph!
Line	Verbatim
474	function LineagesIO.finalize_graph!(handle :: PhyloNetworksNodeHandle)
PhyloExt — entry-point overload (concrete implementation)
Line	Verbatim
498	function LineagesIO.add_child(
499	:: Nothing, # parent — dispatch-only; entry-point has no parent
500	node_idx :: Int,
501	label :: AbstractString,
502	:: Union{EdgeUnitT, Nothing}, # edgeweight — no incoming edge for entry-point
503	:: Nothing, # edgedata — no parent edge for entry-point
504	nodedata :: NodeRowT,
505	) where {EdgeUnitT, NodeRowT}
PhyloExt — non-entry-point overload (concrete implementation)
Line	Verbatim
518	function LineagesIO.add_child(
519	parent :: PhyloNodeRef,
520	node_idx :: Int,
521	label :: AbstractString,
522	edgeweight :: Union{EdgeUnitT, Nothing},
523	:: EdgeRowT, # edgedata — Phylo RecursiveBranch has no generic metadata dict
524	nodedata :: NodeRowT,
525	) where {EdgeUnitT, NodeRowT, EdgeRowT}
.workflow-docs/runs/20260425T2251--phase-01/01_prd.md
User story — callback style
Line	Verbatim
85	4. A user can pass \builder = (parent, node_idx, label, edgeweight, edgedata,`
86	nodedata) -> ...\ as a keyword argument to `load` and receive a`
Canonical signature block (§add_child protocol module)
Line	Verbatim
544	function add_child(
545	:: AbstractVector{NodeT}, # parents
546	:: Int, # node_idx
547	:: AbstractString, # label
548	:: AbstractVector{Union{EdgeUnitT, Nothing}}, # edgeweights
549	:: AbstractVector{EdgeRowT}, # edgedata
550	:: NodeRowT, # nodedata
551	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT, EdgeRowT} end
554	function add_child(
555	:: Nothing, # parent
556	:: Int, # node_idx
557	:: AbstractString, # label
558	:: Union{EdgeUnitT, Nothing}, # edgeweight
559	:: Nothing, # edgedata
560	:: NodeRowT, # nodedata
561	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT} end
564	function add_child(
565	:: NodeT, # parent
566	:: Int, # node_idx
567	:: AbstractString, # label
568	:: Union{EdgeUnitT, Nothing}, # edgeweight
569	:: EdgeRowT, # edgedata
570	:: NodeRowT, # nodedata
571	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT, EdgeRowT} end
574	function finalize_graph!(:: NodeT) :: NodeT where {NodeT} end # no-op default
Acceptance criteria and constraint text (selected)
Line	Verbatim
322	- **Internal redesign forbidden**: Changes to the \add_child` protocol`
323	signature, \LineageGraphStore` or `LineageGraphAsset` struct fields, or the `finalize_graph!``
876	- If the \add_child` protocol signature, `LineageGraphStore` or `LineageGraphAsset` struct`
882	Any proposed deviation from the \add_child` protocol signature, `LineageGraphStore` or`
.workflow-docs/runs/20260425T2251--phase-01/02_tranches.md
Canonical signature block (§Tranche 1)
Line	Verbatim
156	function add_child(
157	:: AbstractVector{NodeT}, # parents
158	:: Int, # node_idx
159	:: AbstractString, # label
160	:: AbstractVector{Union{EdgeUnitT, Nothing}}, # edgeweights
161	:: AbstractVector{EdgeRowT}, # edgedata
162	:: NodeRowT, # nodedata
163	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT, EdgeRowT} end
166	function add_child(
167	:: Nothing, # parent
168	:: Int, # node_idx
169	:: AbstractString, # label
170	:: Union{EdgeUnitT, Nothing}, # edgeweight
171	:: Nothing, # edgedata
172	:: NodeRowT, # nodedata
173	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT} end
176	function add_child(
177	:: NodeT, # parent
178	:: Int, # node_idx
179	:: AbstractString, # label
180	:: Union{EdgeUnitT, Nothing}, # edgeweight
181	:: EdgeRowT, # edgedata
182	:: NodeRowT, # nodedata
183	) :: NodeT where {NodeT, EdgeUnitT, NodeRowT, EdgeRowT} end
195	finalize_graph!(handle :: NodeT) :: NodeT where {NodeT} = handle
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-01--tasking.md
Line	Verbatim
146	In \src/protocol.jl`, define `add_child` as a generic function with exactly`
147	three overload stubs, matching the signatures in \design/brief.md §Builder`
148	protocol\ and `01_prd.md §add_child protocol module` character-for-character.`
150	The three signatures are: (1) network level with
151	\parents :: AbstractVector{NodeT}`, (2) single-parent entry-point with`
152	\parent :: Nothing`, and (3) single-parent non-entry-point with`
153	\parent :: NodeT`.`
172	In \src/protocol.jl`, define and export `finalize_graph!(handle :: NodeT) ::`
173	NodeT where {NodeT}\ with a no-op default body that returns `handle` unchanged.`
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-03--tasking.md
Line	Verbatim
101	not implement it. Implement the builder validation gate: before the first
102	\add_child` call, inspect whether the user's builder (either extended methods`
103	or the \builder` callback) is compatible with the declared tier. For `:network``
107	keyword argument is present, route all \add_child` calls to it directly and do`
108	not dispatch to extended \LineagesIO.add_child` methods — per `01_prd.md`
120	passed through to \add_child` unchanged; parsers supply `""` for absent labels`
124	1 for each new graph and increments by 1 for each \add_child` call.`
145	\add_child` for a graph has been made, call `finalize_graph!(entry_point_handle)``
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-08--tasking.md
(Task descriptions specify the parameter list in prose — these are the lines that would need rewriting if signatures change.)

Line	Verbatim
152	Implement \LineagesIO.add_child(parent :: Nothing, node_idx, label, nodedata,`
153	edgedata) :: PhyloNetworksNodeHandle\ — this is the entry-point overload`
173	Implement \LineagesIO.add_child(parent :: PhyloNetworksNodeHandle, node_idx,`
174	label, nodedata, edgedata) :: PhyloNetworksNodeHandle\ — the single-parent`
178	Implement \LineagesIO.add_child(parents :: AbstractVector{PhyloNetworksNodeHandle},`
179	node_idx, label, nodedata, edgedata) :: PhyloNetworksNodeHandle\ — the network`
204	Implement \LineagesIO.finalize_graph!(handle :: PhyloNetworksNodeHandle) ::`
.workflow-docs/runs/20260425T2251--phase-01/03_tranche-09--tasking.md
Line	Verbatim
134	\add_child(parent :: Nothing, ...) :: PhyloNodeRef` creates a new`
146	\LineagesIO.add_child(parent :: Nothing, node_idx, label, nodedata, edgedata)`
165	Implement \LineagesIO.add_child(parent :: PhyloNodeRef, node_idx, label,`
Summary
No source code files yet exist — src/LineagesIO.jl and test/runtests.jl are empty stubs. The entire impact surface is documentation. The signature appears in full verbatim blocks in 4 files (design/brief.md, design/brief--community-support-objectives.md, 01_prd.md, 02_tranches.md) and is referenced prescriptively in all 8 tranche tasking files except tranche-02.

The callback lambda form (parent, node_idx, label, edgeweight, edgedata, nodedata) appears explicitly at design/brief.md:207 and 01_prd.md:85–86. Those are the two lines that would expose the positional order most directly to users.