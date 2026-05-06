struct LegacyBasenodeLoadRequest{BasenodeT} <: AbstractLoadRequest
    basenode::BasenodeT
end

function compat_load(
        source_descriptor::AbstractLoadSourceDescriptor,
        args...;
        builder = nothing,
    )::LineageGraphStore
    if builder !== nothing && isempty(args)
        return compat_builder_load(source_descriptor, builder)
    end
    request = normalize_compat_load_request(args, builder)
    return canonical_load(source_descriptor, request)
end

function normalize_compat_load_request(
        args::Tuple{},
        builder,
    )::AbstractLoadRequest
    builder === nothing || throw(
        ArgumentError(
            "Builder compatibility normalization must be routed through `compat_builder_load`."
        )
    )
    return TablesOnlyLoadRequest()
end

function normalize_compat_load_request(
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

function normalize_compat_load_request(
        args::Tuple{BasenodeT},
        builder,
    )::AbstractLoadRequest where {BasenodeT}
    builder === nothing || throw(
        ArgumentError(
            "An explicit `builder` callback cannot be combined with a supplied `basenode`; choose one construction ownership model."
        )
    )
    return LegacyBasenodeLoadRequest(first(args))
end

function normalize_compat_load_request(
        args::Tuple,
        builder,
    )::AbstractLoadRequest
    throw(
        ArgumentError(
            "Loads accept at most one positional construction target. Supported surfaces are `load(src)`, `load(src, NodeT)`, `load(src, basenode)`, and `load(src; builder = fn)`."
        )
    )
end

function normalize_compat_builder_request(
        builder,
    )::TypedBuilderLoadRequest
    handle_type, parent_collection_type = infer_compat_builder_types(builder)
    return TypedBuilderLoadRequest(builder, handle_type, parent_collection_type)
end

function compat_builder_load(
        source_descriptor::AbstractLoadSourceDescriptor,
        builder,
    )::LineageGraphStore
    request = normalize_compat_builder_request(builder)
    try
        return canonical_load(source_descriptor, request)
    catch err
        throw(rewrite_compat_builder_error(err))
    end
end

function infer_compat_builder_types(
        builder,
    )::Tuple{Type, Type}
    handle_types = Type[]
    parent_collection_types = Type[]
    for method in methods(builder)
        collect_compat_builder_parent_shapes!(
            handle_types,
            parent_collection_types,
            compat_builder_parent_argument_type(method),
        )
    end
    HandleT = isempty(handle_types) ? Any : reduce(typejoin, handle_types)
    ParentCollectionT = compat_parent_collection_type(
        parent_collection_types,
        HandleT,
    )
    return HandleT, ParentCollectionT
end

function compat_builder_parent_argument_type(method::Method)
    signature_parameters = Base.unwrap_unionall(method.sig).parameters
    length(signature_parameters) >= 2 || return Any
    return signature_parameters[2]
end

function collect_compat_builder_parent_shapes!(
        handle_types::Vector{Type},
        parent_collection_types::Vector{Type},
        parent_argument_type,
    )::Nothing
    for candidate_type in compat_builder_parent_argument_types(parent_argument_type)
        candidate_type === Nothing && continue
        candidate_type === Any && begin
            push!(handle_types, Any)
            continue
        end
        candidate_type isa UnionAll && begin
            push!(handle_types, Any)
            continue
        end
        if candidate_type <: AbstractVector
            push!(handle_types, eltype(candidate_type))
            isconcretetype(candidate_type) && push!(
                parent_collection_types,
                candidate_type,
            )
        else
            push!(handle_types, candidate_type)
        end
    end
    return nothing
end

function compat_builder_parent_argument_types(
        parent_argument_type,
    )::Vector{Any}
    parent_argument_type isa Union && return collect(Base.uniontypes(parent_argument_type))
    (
        parent_argument_type isa Type ||
        parent_argument_type isa UnionAll
    ) || return Any[Any]
    return Any[parent_argument_type]
end

function compat_parent_collection_type(
        parent_collection_types::Vector{Type},
        ::Type{HandleT},
    )::Type where {HandleT}
    unique_parent_collection_types = unique(parent_collection_types)
    if length(unique_parent_collection_types) == 1
        ParentCollectionT = only(unique_parent_collection_types)
        ParentCollectionT <: AbstractVector{HandleT} && return ParentCollectionT
    end
    return Vector{HandleT}
end

function rewrite_compat_builder_error(err)
    err isa ArgumentError || return err
    message = sprint(showerror, err)
    occursin("supplied typed builder request", message) || return err
    rewritten_message = replace(
        message,
        "supplied typed builder request" => "supplied `builder` callback",
    )
    return ArgumentError(rewritten_message)
end
