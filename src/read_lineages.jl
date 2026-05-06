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

function BuilderDescriptor(
        builder::BuilderT,
        ::Type{HandleT},
    )::BuilderDescriptor{BuilderT, HandleT, Vector{HandleT}} where {
        BuilderT,
        HandleT,
    }
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

Read rooted lineage data through the package-owned public file or stream
surface. This surface accepts path-backed or stream-backed Newick and alife
sources, normalizes once into the canonical owner, and keeps `FileIO.load(...)`
as a compatibility wrapper only.
"""
function read_lineages(
        source_path::AbstractString,
        args...;
        format = nothing,
        builder = nothing,
        kwargs...,
    )::LineageGraphStore
    assert_supported_read_lineages_keywords(builder, kwargs, "path")
    source_descriptor = build_read_source_descriptor(
        source_path,
        normalize_package_owned_format(format),
    )
    request = normalize_read_lineages_request(args)
    return canonical_load(source_descriptor, request)
end

function read_lineages(
        io::IO,
        args...;
        source_path::Union{Nothing, AbstractString} = nothing,
        format = nothing,
        builder = nothing,
        kwargs...,
    )::LineageGraphStore
    assert_supported_read_lineages_keywords(builder, kwargs, "stream")
    source_descriptor = build_read_source_descriptor(
        io,
        normalize_source_path(source_path),
        normalize_package_owned_format(format),
    )
    request = normalize_read_lineages_request(args)
    return canonical_load(source_descriptor, request)
end

function normalize_read_lineages_request(
        args::Tuple{},
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
        args::Tuple{BasenodeT},
    )::AbstractLoadRequest where {BasenodeT}
    basenode = first(args)
    handle_type = construction_handle_type(basenode)
    handle_type === nothing && throw(
        ArgumentError(
            "The package-owned `read_lineages(source, basenode)` surface requires an explicit typed handle contract for `$(typeof(basenode))`. Implement `LineagesIO.construction_handle_type(basenode)` for this target, or keep using the retained compatibility wrapper `load(source, basenode)` if you need the legacy single-parent fallback surface.",
        ),
    )
    return BasenodeLoadRequest(basenode, handle_type)
end

function normalize_read_lineages_request(
        args::Tuple,
    )::AbstractLoadRequest
    throw(
        ArgumentError(
            "The package-owned `read_lineages` surface accepts `read_lineages(source)`, `read_lineages(source, NodeT)`, `read_lineages(source, basenode)`, and `read_lineages(source, BuilderDescriptor(...))`. Raw `builder = fn` remains compatibility-only via `load(...; builder = fn)`.",
        ),
    )
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

function assert_supported_read_lineages_keywords(
        builder,
        kwargs,
        surface_label::AbstractString,
    )::Nothing
    builder === nothing || throw(
        ArgumentError(
            "The package-owned `read_lineages` $(surface_label) surface does not accept raw `builder = fn`. Use `read_lineages(source, BuilderDescriptor(builder, HandleT[, ParentCollectionT]))`, or keep using the retained compatibility wrapper `load(...; builder = fn)`.",
        ),
    )
    keyword_names = join(
        sort!(String[string(key) for key in keys(kwargs)]),
        ", ",
    )
    isempty(kwargs) || throw(
        ArgumentError(
            "Unsupported keyword options for the package-owned `read_lineages` $(surface_label) surface: $(keyword_names).",
        ),
    )
    return nothing
end

function build_read_source_descriptor(
        source_path::AbstractString,
        format::Union{Nothing, Symbol},
    )::AbstractLoadSourceDescriptor
    resolved_format = format === nothing ?
        infer_package_owned_format_from_path(source_path, "path") :
        format
    return build_read_source_descriptor_for_format(
        String(source_path),
        resolved_format,
    )
end

function build_read_source_descriptor(
        io::IO,
        source_path::OptionalString,
        format::Union{Nothing, Symbol},
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
        io,
        source_path,
        resolved_format,
    )
end

function build_read_source_descriptor_for_format(
        source_path::String,
        format::Symbol,
    )::AbstractLoadSourceDescriptor
    format === :newick && return NewickFilePathSourceDescriptor(source_path)
    format === :alife && return AlifeFilePathSourceDescriptor(source_path)
    throw_impossible_package_owned_format(format)
end

function build_read_stream_source_descriptor_for_format(
        io::IO,
        source_path::OptionalString,
        format::Symbol,
    )::AbstractLoadSourceDescriptor
    format === :newick && return NewickStreamSourceDescriptor(io, source_path)
    format === :alife && return AlifeStreamSourceDescriptor(io, source_path)
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
