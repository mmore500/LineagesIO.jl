const NewickFormat = FileIO.DataFormat{:Newick}
const AmbiguousTextFormat = FileIO.DataFormat{:LineagesIOAmbiguousText}

"""
    AlifeStandardFormat

`FileIO` data format describing CSV sources that follow the
[ALife phylogeny data standard](https://alife-data-standards.github.io/alife-data-standards/phylogeny.html).

The `.csv` extension is registered as ambiguous, so `load("phylogeny.csv")`
raises a `FileIO` ambiguity error; pass an explicit
`File{LineagesIO.AlifeStandardFormat}(path)` (or
`Stream{LineagesIO.AlifeStandardFormat}(io, path)`) to disambiguate. See
also `load_alife_table` for direct in-memory Tables.jl input.
"""
const AlifeStandardFormat = FileIO.DataFormat{:AlifeStandard}
const AmbiguousCSVFormat = FileIO.DataFormat{:LineagesIOAmbiguousCSV}
const SAFE_NEWICK_EXTENSIONS = (".nwk", ".newick", ".tree", ".tre", ".trees")
const AMBIGUOUS_TEXT_EXTENSIONS = (".txt",)
const AMBIGUOUS_CSV_EXTENSIONS = (".csv",)
const _FILEIO_REGISTERED = Ref(false)

function register_newick_format!()::Nothing
    _FILEIO_REGISTERED[] && return nothing
    FileIO.add_format(NewickFormat, UInt8[], (SAFE_NEWICK_EXTENSIONS..., AMBIGUOUS_TEXT_EXTENSIONS...))
    FileIO.add_loader(NewickFormat, @__MODULE__)
    FileIO.add_format(AmbiguousTextFormat, UInt8[], AMBIGUOUS_TEXT_EXTENSIONS)
    FileIO.add_format(AlifeStandardFormat, UInt8[], AMBIGUOUS_CSV_EXTENSIONS)
    FileIO.add_loader(AlifeStandardFormat, @__MODULE__)
    FileIO.add_format(AmbiguousCSVFormat, UInt8[], AMBIGUOUS_CSV_EXTENSIONS)
    _FILEIO_REGISTERED[] = true
    return nothing
end

function fileio_load(file::FileIO.File{NewickFormat}, args...; builder = nothing, kwargs...)::LineageGraphStore
    assert_supported_load_keywords(kwargs)
    return canonical_load(
        NewickFilePathSourceDescriptor(FileIO.filename(file)),
        args...;
        builder = builder,
    )
end

function fileio_load(stream::FileIO.Stream{NewickFormat}, args...; builder = nothing, kwargs...)::LineageGraphStore
    assert_supported_load_keywords(kwargs)
    return canonical_load(
        NewickStreamSourceDescriptor(
            FileIO.stream(stream),
            normalize_source_path(FileIO.filename(stream)),
        ),
        args...;
        builder = builder,
    )
end

function fileio_load(file::FileIO.File{AlifeStandardFormat}, args...; builder = nothing, kwargs...)::LineageGraphStore
    assert_supported_load_keywords(kwargs)
    return canonical_load(
        AlifeFilePathSourceDescriptor(FileIO.filename(file)),
        args...;
        builder = builder,
    )
end

function fileio_load(stream::FileIO.Stream{AlifeStandardFormat}, args...; builder = nothing, kwargs...)::LineageGraphStore
    assert_supported_load_keywords(kwargs)
    return canonical_load(
        AlifeStreamSourceDescriptor(
            FileIO.stream(stream),
            normalize_source_path(FileIO.filename(stream)),
        ),
        args...;
        builder = builder,
    )
end

function assert_supported_load_keywords(kwargs)::Nothing
    isempty(kwargs) || throw(ArgumentError("Unsupported keyword options. Supported surfaces are `load(src)`, `load(src, NodeT)`, `load(src, basenode)`, and `load(src; builder = fn)`."))
    return nothing
end
