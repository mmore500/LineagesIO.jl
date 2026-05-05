abstract type AbstractLoadSourceDescriptor end

"""
    NewickFilePathSourceDescriptor(source_path)

Package-owned Newick file or path source descriptor for the canonical load
owner.
"""
struct NewickFilePathSourceDescriptor <: AbstractLoadSourceDescriptor
    source_path::String
end

function NewickFilePathSourceDescriptor(
        source_path::AbstractString,
    )::NewickFilePathSourceDescriptor
    return NewickFilePathSourceDescriptor(String(source_path))
end

"""
    NewickStreamSourceDescriptor(io[, source_path])

Package-owned Newick stream source descriptor for the canonical load owner.
"""
struct NewickStreamSourceDescriptor{StreamT <: IO} <: AbstractLoadSourceDescriptor
    io::StreamT
    source_path::OptionalString
end

function NewickStreamSourceDescriptor(
        io::StreamT,
        source_path::Union{Nothing, AbstractString} = nothing,
    )::NewickStreamSourceDescriptor{StreamT} where {StreamT <: IO}
    return NewickStreamSourceDescriptor{StreamT}(io, normalize_source_path(source_path))
end

"""
    NewickTextSourceDescriptor(text[, source_path])

Package-owned Newick text source descriptor for the canonical load owner.
"""
struct NewickTextSourceDescriptor <: AbstractLoadSourceDescriptor
    text::String
    source_path::OptionalString
end

function NewickTextSourceDescriptor(
        text::AbstractString,
        source_path::OptionalString = nothing,
    )::NewickTextSourceDescriptor
    return NewickTextSourceDescriptor(String(text), source_path)
end

"""
    AlifeFilePathSourceDescriptor(source_path)

Package-owned alife file or path source descriptor for the canonical load
owner.
"""
struct AlifeFilePathSourceDescriptor <: AbstractLoadSourceDescriptor
    source_path::String
end

function AlifeFilePathSourceDescriptor(
        source_path::AbstractString,
    )::AlifeFilePathSourceDescriptor
    return AlifeFilePathSourceDescriptor(String(source_path))
end

"""
    AlifeStreamSourceDescriptor(io[, source_path])

Package-owned alife stream source descriptor for the canonical load owner.
"""
struct AlifeStreamSourceDescriptor{StreamT <: IO} <: AbstractLoadSourceDescriptor
    io::StreamT
    source_path::OptionalString
end

function AlifeStreamSourceDescriptor(
        io::StreamT,
        source_path::Union{Nothing, AbstractString} = nothing,
    )::AlifeStreamSourceDescriptor{StreamT} where {StreamT <: IO}
    return AlifeStreamSourceDescriptor{StreamT}(io, normalize_source_path(source_path))
end

"""
    AlifeTextSourceDescriptor(text[, source_path])

Package-owned alife text source descriptor for the canonical load owner.
"""
struct AlifeTextSourceDescriptor <: AbstractLoadSourceDescriptor
    text::String
    source_path::OptionalString
end

function AlifeTextSourceDescriptor(
        text::AbstractString,
        source_path::OptionalString = nothing,
    )::AlifeTextSourceDescriptor
    return AlifeTextSourceDescriptor(String(text), source_path)
end

"""
    AlifeTableSourceDescriptor(table[, source_path])

Package-owned in-memory alife Tables.jl source descriptor for the canonical
load owner.
"""
struct AlifeTableSourceDescriptor{TableT} <: AbstractLoadSourceDescriptor
    table::TableT
    source_path::OptionalString
end

function AlifeTableSourceDescriptor(
        table::TableT,
        source_path::Union{Nothing, AbstractString} = nothing,
    )::AlifeTableSourceDescriptor{TableT} where {TableT}
    return AlifeTableSourceDescriptor{TableT}(table, normalize_source_path(source_path))
end

abstract type AbstractLoadRequest end

struct TablesOnlyLoadRequest <: AbstractLoadRequest end

struct NodeTypeLoadRequest{NodeT} <: AbstractLoadRequest
    node_type::Type{NodeT}
end

struct BasenodeLoadRequest{BasenodeT, HandleT} <: AbstractLoadRequest
    basenode::BasenodeT
    handle_type::Type{HandleT}
end

function BasenodeLoadRequest(
        basenode::BasenodeT,
    )::BasenodeLoadRequest where {BasenodeT}
    return BasenodeLoadRequest(basenode, construction_handle_type(basenode))
end

"""
    BuilderLoadRequest(builder)

Compatibility-only builder request. This path may retain request-shape recovery
outside the typed canonical builder contract.
"""
struct BuilderLoadRequest{BuilderT} <: AbstractLoadRequest
    builder::BuilderT
end

struct ParentCollectionFactory{HandleT, ParentCollectionT <: AbstractVector{HandleT}} end

function build_parent_collection_from_factory(
        factory::ParentCollectionFactory{HandleT, ParentCollectionT},
        parent_handles::AbstractVector{HandleT},
    )::ParentCollectionT where {HandleT, ParentCollectionT <: AbstractVector{HandleT}}
    _ = factory
    return ParentCollectionT(parent_handles)
end

"""
    TypedBuilderLoadRequest(builder, HandleT[, ParentCollectionT])

Canonical typed builder request carrying explicit handle typing and explicit
parent-collection typing.
"""
struct TypedBuilderLoadRequest{
        BuilderT,
        HandleT,
        ParentCollectionT <: AbstractVector{HandleT},
        ParentCollectionFactoryT,
    } <: AbstractLoadRequest
    builder::BuilderT
    parent_collection_factory::ParentCollectionFactoryT
end

function TypedBuilderLoadRequest(
        builder::BuilderT,
        ::Type{HandleT},
    )::TypedBuilderLoadRequest where {BuilderT, HandleT}
    return TypedBuilderLoadRequest(builder, HandleT, Vector{HandleT})
end

function TypedBuilderLoadRequest(
        builder::BuilderT,
        ::Type{HandleT},
        ::Type{ParentCollectionT},
    )::TypedBuilderLoadRequest where {
        BuilderT,
        HandleT,
        ParentCollectionT <: AbstractVector{HandleT},
    }
    factory = ParentCollectionFactory{HandleT, ParentCollectionT}()
    return TypedBuilderLoadRequest{
        BuilderT,
        HandleT,
        ParentCollectionT,
        typeof(factory),
    }(builder, factory)
end

function normalize_source_path(source_path::Nothing)::OptionalString
    return source_path
end

function normalize_source_path(
        source_path::AbstractString,
    )::OptionalString
    return String(source_path)
end

function construction_handle_type(
        node_type::Type{NodeT},
    )::Type{NodeT} where {NodeT}
    return node_type
end

function construction_handle_type(target)::Type
    return typeof(target)
end

function canonical_load(
        source_descriptor::AbstractLoadSourceDescriptor,
        args...;
        builder = nothing,
    )::LineageGraphStore
    request = normalize_load_request(args, builder)
    return canonical_load(source_descriptor, request)
end

function canonical_load(
        source_descriptor::NewickFilePathSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    text = read(getfield(source_descriptor, :source_path), String)
    return canonical_load(
        NewickTextSourceDescriptor(
            text,
            getfield(source_descriptor, :source_path),
        ),
        request,
    )
end

function canonical_load(
        source_descriptor::NewickStreamSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    text = read(getfield(source_descriptor, :io), String)
    return canonical_load(
        NewickTextSourceDescriptor(
            text,
            getfield(source_descriptor, :source_path),
        ),
        request,
    )
end

function canonical_load(
        source_descriptor::NewickTextSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    return build_newick_store(
        getfield(source_descriptor, :text),
        getfield(source_descriptor, :source_path),
        request,
    )
end

function canonical_load(
        source_descriptor::AlifeFilePathSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    text = read(getfield(source_descriptor, :source_path), String)
    return canonical_load(
        AlifeTextSourceDescriptor(
            text,
            getfield(source_descriptor, :source_path),
        ),
        request,
    )
end

function canonical_load(
        source_descriptor::AlifeStreamSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    text = read(getfield(source_descriptor, :io), String)
    return canonical_load(
        AlifeTextSourceDescriptor(
            text,
            getfield(source_descriptor, :source_path),
        ),
        request,
    )
end

function canonical_load(
        source_descriptor::AlifeTextSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    return build_alife_store(
        getfield(source_descriptor, :text),
        getfield(source_descriptor, :source_path),
        request,
    )
end

function canonical_load(
        source_descriptor::AlifeTableSourceDescriptor,
        request::AbstractLoadRequest,
    )::LineageGraphStore
    table = getfield(source_descriptor, :table)
    Tables.istable(table) || throw(
        ArgumentError(
            "`load_alife_table` requires a Tables.jl-compatible input, but received `$(typeof(table))`. Pass a `NamedTuple` of vectors, a `DataFrame`, or any other value satisfying the Tables.jl interface."
        )
    )
    return build_alife_store_from_table(
        table,
        getfield(source_descriptor, :source_path),
        request,
    )
end

function normalize_load_request(
        args::Tuple{},
        builder,
    )::AbstractLoadRequest
    builder === nothing && return TablesOnlyLoadRequest()
    return BuilderLoadRequest(builder)
end

function normalize_load_request(
        args::Tuple{Type},
        builder,
    )::AbstractLoadRequest
    builder === nothing || throw(
        ArgumentError(
            "Choose either `load(src, NodeT)` or `load(src; builder = fn)`, not both at once."
        )
    )
    node_type = first(args)
    validate_extension_load_target(node_type)
    return NodeTypeLoadRequest(node_type)
end

function normalize_load_request(
        args::Tuple{BasenodeT},
        builder,
    )::AbstractLoadRequest where {BasenodeT}
    builder === nothing || throw(
        ArgumentError(
            "An explicit `builder` callback cannot be combined with a supplied `basenode`; choose one construction ownership model."
        )
    )
    return BasenodeLoadRequest(first(args))
end

function normalize_load_request(
        args::Tuple,
        builder,
    )::AbstractLoadRequest
    throw(
        ArgumentError(
            "Loads accept at most one positional construction target. Supported surfaces are `load(src)`, `load(src, NodeT)`, `load(src, basenode)`, and `load(src; builder = fn)`."
        )
    )
end

function validate_extension_load_target(::Type)::Nothing
    return nothing
end

function validate_extension_load_target(
        target,
        graph_asset::LineageGraphAsset,
    )::Nothing
    return nothing
end
