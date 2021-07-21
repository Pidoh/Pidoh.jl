
include("bitstrings.jl")
include("graphs.jl")
include("sats.jl")

import Base: show

function show(io::IO, problem::AbstractProblem)
    show(io, string(typeof(problem)))
    first = true
    for p in realparameters(problem)
        if first
            print(io, " with ")
            first = false
        else
            print(io, " and ")
        end

        show(io, p)
        print(io, ":")
        show(io, getfield(problem, p))
    end
end

function realparameters(problem::AbstractProblem)
    realfields = []
    for fieldname in fieldnames(typeof(problem))
        if typeof(getfield(problem, fieldname)) <: Real
            push!(realfields, fieldname)
        end
    end
    realfields
end