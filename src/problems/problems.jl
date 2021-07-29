
include("bitstrings.jl")
include("graphs.jl")
include("sats.jl")

import Base: name

name(problem::AbstractProblem) = string(problem)

function Base.show(io::IO, problem::AbstractProblem)
    show(io, string(typeof(problem)))
    first = true
    for p in deepparameters(problem)
        if first
            print(io, " with ")
            first = false
        else
            print(io, " and ")
        end

        show(io, string(p[1]))
        print(io, ":")
        show(io, p[2])
    end
end
