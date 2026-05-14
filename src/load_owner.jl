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
        source_path::AbstractString;
        kwargs...,
    )::NewickFilePathSourceDescriptor
    assert_no_extra_descriptor_kwargs(:NewickFilePathSourceDescriptor, kwargs)
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
        source_path::Union{Nothing, AbstractString} = nothing;
        kwargs...,
    )::NewickStreamSourceDescriptor{StreamT} where {StreamT <: IO}
    assert_no_extra_descriptor_kwargs(:NewickStreamSourceDescriptor, kwargs)
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
        source_path::OptionalString = nothing;
        kwargs...,
    )::NewickTextSourceDescriptor
    assert_no_extra_descriptor_kwargs(:NewickTextSourceDescriptor, kwargs)
    return NewickTextSourceDescriptor(String(text), source_path)
end

function assert_no_extra_descriptor_kwargs(descriptor_name::Symbol, kwargs)::Nothing
    isempty(kwargs) && return nothing
    keyword_list = join(sort!(String[string(k) for k in keys(kwargs)]), ", ")
    throw(ArgumentError(string(descriptor_name) * " does not accept extra keyword options; received: " * keyword_list * "."))
end

"""
    AlifeFilePathSourceDescriptor(source_path; allow_forest = false, assume_topological_ordering = false)

Package-owned alife file or path source descriptor for the canonical load
owner.
"""
struct AlifeFilePathSourceDescriptor <: AbstractLoadSourceDescriptor
    source_path::String
    allow_forest::Bool
    assume_topological_ordering::Bool
    normalize_annotation_values::Bool
end

function AlifeFilePathSourceDescriptor(
        source_path::AbstractString;
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::AlifeFilePathSourceDescriptor
    return AlifeFilePathSourceDescriptor(
        String(source_path), allow_forest, assume_topological_ordering, normalize_annotation_values,
    )
end

"""
    AlifeStreamSourceDescriptor(io[, source_path]; allow_forest = false, assume_topological_ordering = false)

Package-owned alife stream source descriptor for the canonical load owner.
"""
struct AlifeStreamSourceDescriptor{StreamT <: IO} <: AbstractLoadSourceDescriptor
    io::StreamT
    source_path::OptionalString
    allow_forest::Bool
    assume_topological_ordering::Bool
    normalize_annotation_values::Bool
end

function AlifeStreamSourceDescriptor(
        io::StreamT,
        source_path::Union{Nothing, AbstractString} = nothing;
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::AlifeStreamSourceDescriptor{StreamT} where {StreamT <: IO}
    return AlifeStreamSourceDescriptor{StreamT}(
        io, normalize_source_path(source_path), allow_forest, assume_topological_ordering, normalize_annotation_values,
    )
end

"""
    AlifeTextSourceDescriptor(text[, source_path]; allow_forest = false, assume_topological_ordering = false)

Package-owned alife text source descriptor for the canonical load owner.
"""
struct AlifeTextSourceDescriptor <: AbstractLoadSourceDescriptor
    text::String
    source_path::OptionalString
    allow_forest::Bool
    assume_topological_ordering::Bool
    normalize_annotation_values::Bool
end

function AlifeTextSourceDescriptor(
        text::AbstractString,
        source_path::OptionalString = nothing;
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::AlifeTextSourceDescriptor
    return AlifeTextSourceDescriptor(
        String(text), source_path, allow_forest, assume_topological_ordering, normalize_annotation_values,
    )
end

"""
    AlifeTableSourceDescriptor(table[, source_path]; allow_forest = false, assume_topological_ordering = false)

Package-owned in-memory alife Tables.jl source descriptor for the canonical
load owner.
"""
struct AlifeTableSourceDescriptor{TableT} <: AbstractLoadSourceDescriptor
    table::TableT
    source_path::OptionalString
    allow_forest::Bool
    assume_topological_ordering::Bool
    normalize_annotation_values::Bool
end

function AlifeTableSourceDescriptor(
        table::TableT,
        source_path::Union{Nothing, AbstractString} = nothing;
        allow_forest::Bool = false,
        assume_topological_ordering::Bool = false,
        normalize_annotation_values::Bool = false,
    )::AlifeTableSourceDescriptor{TableT} where {TableT}
    return AlifeTableSourceDescriptor{TableT}(
        table, normalize_source_path(source_path), allow_forest, assume_topological_ordering, normalize_annotation_values,
    )
end

abstract type AbstractLoadRequest end

struct TablesOnlyLoadRequest <: AbstractLoadRequest end

struct NodeTypeLoadRequest{NodeT, HandleT} <: AbstractLoadRequest
    node_type::Type{NodeT}
    handle_type::Type{HandleT}
end

function NodeTypeLoadRequest(
        node_type::Type{NodeT},
    )::NodeTypeLoadRequest where {NodeT}
    return NodeTypeLoadRequest(node_type, construction_handle_type(node_type))
end

struct BasenodeLoadRequest{BasenodeT, HandleT} <: AbstractLoadRequest
    basenode::BasenodeT
    handle_type::Type{HandleT}
end

function BasenodeLoadRequest(
        basenode::BasenodeT,
    )::BasenodeLoadRequest where {BasenodeT}
    handle_type = construction_handle_type(basenode)
    handle_type === nothing && throw(
        ArgumentError(
            "An explicit supplied-basenode handle type is required for the canonical typed request. Use `BasenodeLoadRequest(basenode, HandleT)` or the compatibility wrapper surface instead."
        )
    )
    return BasenodeLoadRequest(basenode, handle_type)
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

function construction_handle_type(target)
    return nothing
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
            getfield(source_descriptor, :source_path);
            allow_forest = getfield(source_descriptor, :allow_forest),
            assume_topological_ordering = getfield(source_descriptor, :assume_topological_ordering),
        normalize_annotation_values = getfield(source_descriptor, :normalize_annotation_values),
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
            getfield(source_descriptor, :source_path);
            allow_forest = getfield(source_descriptor, :allow_forest),
            assume_topological_ordering = getfield(source_descriptor, :assume_topological_ordering),
        normalize_annotation_values = getfield(source_descriptor, :normalize_annotation_values),
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
        request;
        allow_forest = getfield(source_descriptor, :allow_forest),
        assume_topological_ordering = getfield(source_descriptor, :assume_topological_ordering),
        normalize_annotation_values = getfield(source_descriptor, :normalize_annotation_values),
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
        request;
        allow_forest = getfield(source_descriptor, :allow_forest),
        assume_topological_ordering = getfield(source_descriptor, :assume_topological_ordering),
        normalize_annotation_values = getfield(source_descriptor, :normalize_annotation_values),
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
