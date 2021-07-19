include("stop.jl")
include("eas.jl")
include("simulated-annealing.jl")
export name
export optimize, ea1pλwith2rates, ea1p1, ea1p1SD, ea1pλSASD, RLSSDstar, RLS12, RLSSDstarstar
export SDCounter, SDCounterEstimation, RLSSDCounter, threshold_gen
export FixedBudget, niterations
export FixedCooling, temperature, sa, AbstractCooling


name(algo::AbstractAlgorithm) = algo.name
