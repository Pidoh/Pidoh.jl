using Pidoh
using Documenter

makedocs(;
    modules=[Pidoh],
    authors="Amirhossein Rajabi",
    repo="https://github.com/ahrajabi/Pidoh.jl/blob/{commit}{path}#L{line}",
    sitename="Pidoh.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ahrajabi.github.io/Pidoh.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Problems" => "problems.md",
    ],
)

deploydocs(;
    repo="github.com/ahrajabi/Pidoh.jl",
)
