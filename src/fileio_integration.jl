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
