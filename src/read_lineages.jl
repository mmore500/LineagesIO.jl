const SAFE_NEWICK_EXTENSIONS = (
    ".nwk",
    ".newick",
    ".tree",
    ".tre",
    ".trees",
)
const AMBIGUOUS_TEXT_EXTENSIONS = (".txt",)
const AMBIGUOUS_CSV_EXTENSIONS = (".csv",)
const PACKAGE_OWNED_READ_FORMATS = (:newick, :alife)

"""
    BuilderDescriptor(builder, HandleT[, ParentCollectionT])

First-class typed builder descriptor for the package-owned `read_lineages`
surface. Use this descriptor to make the builder handle type explicit, and
optionally the parent-collection type explicit for multi-parent sources.
"""
struct BuilderDescriptor{
        BuilderT,
        HandleT,
        ParentCollectionT <: AbstractVector{HandleT},
    }
    builder::BuilderT
end

function assert_concrete_builder_handle_type(
        ::Type{HandleT},
    )::Nothing where {HandleT}
    isconcretetype(HandleT) || throw(
        ArgumentError(
            "The package-owned `BuilderDescriptor` surface requires a concrete `HandleT`, but received `$(HandleT)`.",
        ),
    )
    return nothing
end

function BuilderDescriptor(
        builder::BuilderT,
        ::Type{HandleT},
    )::BuilderDescriptor{BuilderT, HandleT, Vector{HandleT}} where {
        BuilderT,
        HandleT,
    }
    assert_concrete_builder_handle_type(HandleT)
    return BuilderDescriptor{BuilderT, HandleT, Vector{HandleT}}(builder)
end

function BuilderDescriptor(
        builder::BuilderT,
        ::Type{HandleT},
        ::Type{ParentCollectionT},
    )::BuilderDescriptor{BuilderT, HandleT, ParentCollectionT} where {
        BuilderT,
        HandleT,
        ParentCollectionT <: AbstractVector{HandleT},
    }
    assert_concrete_builder_handle_type(HandleT)
    isconcretetype(ParentCollectionT) || throw(
        ArgumentError(
            "The package-owned `BuilderDescriptor` surface requires a concrete `ParentCollectionT`, but received `$(ParentCollectionT)`.",
        ),
    )
    return BuilderDescriptor{BuilderT, HandleT, ParentCollectionT}(builder)
end

"""
    read_lineages(path[, target]; format = nothing) -> LineageGraphStore
    read_lineages(io[, target]; source_path = nothing, format = nothing) -> LineageGraphStore
    read_lineages!(path, basenode; format = nothing) -> LineageGraphStore
    read_lineages!(io, basenode; source_path = nothing, format = nothing) -> LineageGraphStore

Read rooted lineage data through the package-owned public file or stream surface.

**`read_lineages` — library-created path.** Every form accepts either no
construction target (tables-only), a type token (a `Type` value such as
`MetaGraph` or `HybridNetwork`), or a `BuilderDescriptor`. A type token is a
specification, not an object: passing `MetaGraph` says "construct a graph of this
kind and return it." No caller-owned object exists before the call, so `read_lineages`
carries no `!`.

**`read_lineages!` — supplied-instance path.** Accepts an existing caller-owned
graph instance as the construction destination and writes nodes and edges into it
in place. The argument is the destination, not a description of one. Because a
caller-owned object is modified, `read_lineages!` carries `!`.

**Contract (Branch Narrow):** `read_lineages!` provides first-edge atomicity — if
the first user-owned constructor fails before any node is written, the supplied
graph remains empty and the same instance is retryable. Later-edge failure may
leave partial state. Callers who need retry safety after any failure must discard
the instance and supply a fresh empty graph.

See `design/brief--read-lineages-public-surface.md` for the authoritative
surface-split rationale and `!`-boundary decision table.
"""
function read_lineages(
        source_path::AbstractString,
        args...;
        format = nothing,
        builder = nothing,
        kwargs...,
    )::LineageGraphStore
    builder === nothing || throw(
        ArgumentError(
            "The package-owned `read_lineages` path surface does not accept raw `builder = fn`. Use `read_lineages(source, BuilderDescriptor(builder, HandleT[, ParentCollectionT]))`, or use the retained compatibility wrapper `load(...; builder = fn)`.",
        ),
    )
    source_descriptor = build_read_source_descriptor(
        source_path, normalize_package_owned_format(format); kwargs...,
    )
    return canonical_load(source_descriptor, normalize_read_lineages_request(args))
end

function read_lineages(
        io::IO,
        args...;
        source_path::Union{Nothing, AbstractString} = nothing,
        format = nothing,
        builder = nothing,
        kwargs...,
    )::LineageGraphStore
    builder === nothing || throw(
        ArgumentError(
            "The package-owned `read_lineages` stream surface does not accept raw `builder = fn`. Use `read_lineages(source, BuilderDescriptor(builder, HandleT[, ParentCollectionT]))`, or use the retained compatibility wrapper `load(...; builder = fn)`.",
        ),
    )
    source_descriptor = build_read_source_descriptor(
        io, normalize_source_path(source_path), normalize_package_owned_format(format);
        kwargs...,
    )
    return canonical_load(source_descriptor, normalize_read_lineages_request(args))
end

function normalize_read_lineages_request(
        ::Tuple{},
    )::AbstractLoadRequest
    return TablesOnlyLoadRequest()
end

function normalize_read_lineages_request(
        args::Tuple{Type{NodeT}},
    )::AbstractLoadRequest where {NodeT}
    node_type = first(args)
    validate_extension_load_target(node_type)
    return NodeTypeLoadRequest(node_type)
end

function normalize_read_lineages_request(
        args::Tuple{BuilderDescriptorT},
    )::AbstractLoadRequest where {BuilderDescriptorT <: BuilderDescriptor}
    return typed_builder_request(first(args))
end

function normalize_read_lineages_request(
        ::Tuple,
    )::AbstractLoadRequest
    throw(
        ArgumentError(
            "The package-owned `read_lineages` surface accepts `read_lineages(source)`, `read_lineages(source, NodeT)`, and `read_lineages(source, BuilderDescriptor(...))`. For the supplied-instance path use `read_lineages!(source, basenode)`. Raw `builder = fn` remains compatibility-only via `load(...; builder = fn)`.",
        ),
    )
end

function read_lineages!(
        source_path::AbstractString,
        basenode;
        format = nothing,
        kwargs...,
    )::LineageGraphStore
    source_descriptor = build_read_source_descriptor(
        source_path, normalize_package_owned_format(format); kwargs...,
    )
    handle_type = construction_handle_type(basenode)
    handle_type === nothing && throw(
        ArgumentError(
            "The package-owned `read_lineages!(source, basenode)` surface requires an explicit typed handle contract for `$(typeof(basenode))`. Implement `LineagesIO.construction_handle_type(basenode)` for this target, or keep using the retained compatibility wrapper `load(source, basenode)` if you need the legacy single-parent fallback surface.",
        ),
    )
    return canonical_load(source_descriptor, BasenodeLoadRequest(basenode, handle_type))
end

function read_lineages!(
        io::IO,
        basenode;
        source_path::Union{Nothing, AbstractString} = nothing,
        format = nothing,
        kwargs...,
    )::LineageGraphStore
    source_descriptor = build_read_source_descriptor(
        io, normalize_source_path(source_path), normalize_package_owned_format(format);
        kwargs...,
    )
    handle_type = construction_handle_type(basenode)
    handle_type === nothing && throw(
        ArgumentError(
            "The package-owned `read_lineages!(source, basenode)` surface requires an explicit typed handle contract for `$(typeof(basenode))`. Implement `LineagesIO.construction_handle_type(basenode)` for this target, or keep using the retained compatibility wrapper `load(source, basenode)` if you need the legacy single-parent fallback surface.",
        ),
    )
    return canonical_load(source_descriptor, BasenodeLoadRequest(basenode, handle_type))
end

function typed_builder_request(
        descriptor::BuilderDescriptor{
            BuilderT,
            HandleT,
            ParentCollectionT,
        },
    )::TypedBuilderLoadRequest where {
        BuilderT,
        HandleT,
        ParentCollectionT <: AbstractVector{HandleT},
    }
    return TypedBuilderLoadRequest(
        getfield(descriptor, :builder),
        HandleT,
        ParentCollectionT,
    )
end

function normalize_package_owned_format(
        format::Nothing,
    )::Nothing
    return format
end

function normalize_package_owned_format(
        format::Symbol,
    )::Symbol
    format in PACKAGE_OWNED_READ_FORMATS && return format
    throw(
        ArgumentError(
            "Unsupported `format = $(repr(format))` for the package-owned `read_lineages` surface. Supported values are `:newick` and `:alife`.",
        ),
    )
end

function normalize_package_owned_format(format)
    throw(
        ArgumentError(
            "The package-owned `read_lineages` surface accepts only `format = :newick` or `format = :alife`, but received `$(repr(format))`.",
        ),
    )
end

function build_read_source_descriptor(
        source_path::AbstractString,
        format::Union{Nothing, Symbol};
        kwargs...,
    )::AbstractLoadSourceDescriptor
    resolved_format = format === nothing ?
        infer_package_owned_format_from_path(source_path, "path") :
        format
    return build_read_source_descriptor_for_format(
        String(source_path), resolved_format; kwargs...,
    )
end

function build_read_source_descriptor(
        io::IO,
        source_path::OptionalString,
        format::Union{Nothing, Symbol};
        kwargs...,
    )::AbstractLoadSourceDescriptor
    resolved_format = if format !== nothing
        format
    elseif source_path !== nothing
        infer_package_owned_format_from_path(source_path, "stream")
    else
        throw(
            ArgumentError(
                "The package-owned `read_lineages(io)` surface requires either `format = :newick` / `:alife` or a `source_path` with a non-ambiguous supported extension. It does not guess from a bare stream without that contract.",
            ),
        )
    end
    return build_read_stream_source_descriptor_for_format(
        io, source_path, resolved_format; kwargs...,
    )
end

function build_read_source_descriptor_for_format(
        source_path::String,
        format::Symbol;
        kwargs...,
    )::AbstractLoadSourceDescriptor
    format === :newick && return NewickFilePathSourceDescriptor(source_path; kwargs...)
    format === :alife && return AlifeFilePathSourceDescriptor(source_path; kwargs...)
    throw_impossible_package_owned_format(format)
end

function build_read_stream_source_descriptor_for_format(
        io::IO,
        source_path::OptionalString,
        format::Symbol;
        kwargs...,
    )::AbstractLoadSourceDescriptor
    format === :newick && return NewickStreamSourceDescriptor(io, source_path; kwargs...)
    format === :alife && return AlifeStreamSourceDescriptor(io, source_path; kwargs...)
    throw_impossible_package_owned_format(format)
end

function infer_package_owned_format_from_path(
        source_path::AbstractString,
        surface_label::AbstractString,
    )::Symbol
    extension = lowercase(splitext(source_path)[2])
    newick_extensions = join(SAFE_NEWICK_EXTENSIONS, ", ")
    extension in SAFE_NEWICK_EXTENSIONS && return :newick
    extension in AMBIGUOUS_CSV_EXTENSIONS && return :alife
    extension in AMBIGUOUS_TEXT_EXTENSIONS && throw(
        ArgumentError(
            "The package-owned `read_lineages` $(surface_label) surface does not infer format from the ambiguous `.txt` extension. Pass `format = :newick` explicitly, or use the retained `FileIO.load(File{format\"Newick\"}(path))` compatibility wrapper.",
        ),
    )
    throw(
        ArgumentError(
            "The package-owned `read_lineages` $(surface_label) surface could not infer a supported format from `$(source_path)`. Supported automatic path extensions are $(newick_extensions) for Newick and `.csv` for alife. Otherwise, pass `format = :newick` or `format = :alife` explicitly.",
        ),
    )
end

function throw_impossible_package_owned_format(format)::Union{}
    throw(
        ArgumentError(
            "Unsupported internal package-owned read format `$(repr(format))`.",
        ),
    )
end
