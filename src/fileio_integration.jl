const NewickFormat = FileIO.DataFormat{:Newick}
const AmbiguousTextFormat = FileIO.DataFormat{:LineagesIOAmbiguousText}
const SAFE_NEWICK_EXTENSIONS = (".nwk", ".newick", ".tree", ".tre", ".trees")
const AMBIGUOUS_TEXT_EXTENSIONS = (".txt",)
const _FILEIO_REGISTERED = Ref(false)

function register_newick_format!()::Nothing
    _FILEIO_REGISTERED[] && return nothing
    FileIO.add_format(NewickFormat, UInt8[], SAFE_NEWICK_EXTENSIONS)
    FileIO.add_loader(NewickFormat, @__MODULE__)
    FileIO.add_format(AmbiguousTextFormat, UInt8[], AMBIGUOUS_TEXT_EXTENSIONS)
    FileIO.add_loader(AmbiguousTextFormat, @__MODULE__)
    _FILEIO_REGISTERED[] = true
    return nothing
end

function fileio_load(file::FileIO.File{NewickFormat}; kwargs...)::LineageGraphStore
    assert_no_load_keywords(kwargs)
    open(file, "r") do stream
        return fileio_load(stream; kwargs...)
    end
end

function fileio_load(stream::FileIO.Stream{NewickFormat}; kwargs...)::LineageGraphStore
    assert_no_load_keywords(kwargs)
    source_path = normalize_source_path(FileIO.filename(stream))
    source_text = read(FileIO.stream(stream), String)
    return build_newick_store(source_text, source_path)
end

function fileio_load(file::FileIO.File{AmbiguousTextFormat}; kwargs...)
    assert_no_load_keywords(kwargs)
    throw_ambiguous_override_error(FileIO.filename(file))
end

function fileio_load(stream::FileIO.Stream{AmbiguousTextFormat}; kwargs...)
    assert_no_load_keywords(kwargs)
    throw_ambiguous_override_error(FileIO.filename(stream))
end

function assert_no_load_keywords(kwargs)::Nothing
    isempty(kwargs) || throw(ArgumentError("Tranche 1 tables-only Newick loads do not accept keyword options."))
    return nothing
end

function normalize_source_path(source_path::Nothing)::OptionalString
    return source_path
end

function normalize_source_path(source_path::AbstractString)::OptionalString
    return String(source_path)
end

function throw_ambiguous_override_error(source_path)::Nothing
    source_text = source_path === nothing ? "this text source" : "`$(source_path)`"
    throw(ArgumentError("Ambiguous format for $(source_text). Supply an explicit override such as `File{format\"Newick\"}(...)`."))
end
