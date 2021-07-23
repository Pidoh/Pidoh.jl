using Pidoh
using Documenter

makedocs(;
    modules = [Pidoh],
    authors = "Amirhossein Rajabi",
    repo = "https://github.com/Pidoh/Pidoh.jl/blob/{commit}{path}#L{line}",
    sitename = "Pidoh.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://Pidoh.github.io/Pidoh.jl",
        assets = String[],
        collapselevel = 1,
    ),
    pages = [
        "Pidoh" => "index.md",
        "Problems" => Any["bitstringproblems.md", "problems.md"],
        "Algorithms" => Any["simulatedannealing.md"],
        "Instances" => "instances.md",
    ],
)

deploydocs(; repo = "github.com/Pidoh/Pidoh.jl")
