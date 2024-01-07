using AlternateVectors
using Documenter

DocMeta.setdocmeta!(
    AlternateVectors,
    :DocTestSetup,
    :(using AlternateVectors);
    recursive = true
)

makedocs(;
    modules = [AlternateVectors],
    authors = "Nicola <nicola.scaramuzzino@yandex.com> and contributors",
    repo = "https://github.com/rcalxrc08/AlternateVectors.jl/blob/{commit}{path}#{line}",
    sitename = "AlternateVectors.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://rcalxrc08.github.io/AlternateVectors.jl",
        edit_link = "master",
        assets = String[]
    ),
    pages = ["Home" => "index.md"]
)

deploydocs(; repo = "github.com/rcalxrc08/AlternateVectors.jl", devbranch = "master")
