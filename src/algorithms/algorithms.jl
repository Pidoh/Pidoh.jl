import Base: show

include("stop.jl")
include("eas.jl")
include("simulated-annealing.jl")
export name
export optimize, ea1pλwith2rates, ea1p1, ea1p1SD, ea1pλSASD, RLSSDstar, RLS12, RLSSDstarstar
export SDCounter, SDCounterEstimation, RLSSDCounter, threshold_gen
export FixedBudget, niterations
export FixedCooling, temperature, SimulatedAnnealing, AbstractCooling


name(algo::AbstractAlgorithm) = algo.name

function show(io::IO,algo::AbstractAlgorithm)
    show(io, algo.name)
    first = true
    for p in realparameters(algo)
        if first
            print(io, " with ")
            first = false
        else
            print(io, " and ")
        end

        show(io, p)
        print(io, ":")
        show(io, getfield(algo, p))
    end
end

function realparameters(algo::AbstractAlgorithm)
    realfields = []
    for fieldname in fieldnames(typeof(algo))
        if typeof(getfield(algo, fieldname)) <: Real
            push!(realfields, fieldname)
        end
    end
    realfields
end