const NewickFormat = FileIO.DataFormat{:Newick}
const AmbiguousTextFormat = FileIO.DataFormat{:LineagesIOAmbiguousText}
const SAFE_NEWICK_EXTENSIONS = (".nwk", ".newick", ".tree", ".tre", ".trees")
const AMBIGUOUS_TEXT_EXTENSIONS = (".txt",)
const _FILEIO_REGISTERED = Ref(false)

function register_newick_format!()::Nothing
    _FILEIO_REGISTERED[] && return nothing
    FileIO.add_format(NewickFormat, UInt8[], (SAFE_NEWICK_EXTENSIONS..., AMBIGUOUS_TEXT_EXTENSIONS...))
    FileIO.add_loader(NewickFormat, @__MODULE__)
    FileIO.add_format(AmbiguousTextFormat, UInt8[], AMBIGUOUS_TEXT_EXTENSIONS)
    _FILEIO_REGISTERED[] = true
    return nothing
end

function fileio_load(file::FileIO.File{NewickFormat}, args...; builder = nothing, kwargs...)::LineageGraphStore
    assert_supported_load_keywords(kwargs)
    open(file, "r") do stream
        return fileio_load(stream, args...; builder = builder)
    end
end

function fileio_load(stream::FileIO.Stream{NewickFormat}, args...; builder = nothing, kwargs...)::LineageGraphStore
    assert_supported_load_keywords(kwargs)
    load_request = build_load_request(args, builder)
    source_path = normalize_source_path(FileIO.filename(stream))
    source_text = read(FileIO.stream(stream), String)
    return build_newick_store(source_text, source_path, load_request)
end

function assert_supported_load_keywords(kwargs)::Nothing
    isempty(kwargs) || throw(ArgumentError("Unsupported keyword options for Newick loads. Supported surfaces are `load(src)`, `load(src, NodeT)`, `load(src, rootnode)`, and `load(src; builder = fn)`."))
    return nothing
end

function build_load_request(args::Tuple{}, builder)::AbstractLoadRequest
    builder === nothing && return TablesOnlyLoadRequest()
    return BuilderLoadRequest(builder)
end

function build_load_request(args::Tuple{Type}, builder)::AbstractLoadRequest
    builder === nothing || throw(ArgumentError("Choose either `load(src, NodeT)` or `load(src; builder = fn)`, not both at once."))
    return NodeTypeLoadRequest(first(args))
end

function build_load_request(args::Tuple{RootNodeT}, builder)::AbstractLoadRequest where {RootNodeT}
    builder === nothing || throw(ArgumentError("An explicit `builder` callback cannot be combined with a supplied `rootnode`; choose one construction ownership model."))
    return RootBindingLoadRequest(first(args))
end

function build_load_request(args::Tuple, builder)::AbstractLoadRequest
    throw(ArgumentError("Newick loads accept at most one positional construction target. Supported surfaces are `load(src)`, `load(src, NodeT)`, `load(src, rootnode)`, and `load(src; builder = fn)`."))
end

function normalize_source_path(source_path::Nothing)::OptionalString
    return source_path
end

function normalize_source_path(source_path::AbstractString)::OptionalString
    return String(source_path)
end
