using LineagesIO
using Documenter

DocMeta.setdocmeta!(LineagesIO, :DocTestSetup, :(using LineagesIO); recursive=true)

makedocs(;
    modules=[LineagesIO],
    authors="Jeet Sukumaran <jeetsukumaran@gmail.com>",
    sitename="LineagesIO.jl",
    format=Documenter.HTML(;
        canonical="https://jeetsukumaran.github.io/LineagesIO.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jeetsukumaran/LineagesIO.jl",
    devbranch="main",
)
