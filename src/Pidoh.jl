module Pidoh

abstract type AbstractProblem end
abstract type AbstractAlgorithm end
abstract type AbstractStop end


include("problems/problems.jl")
export AbstractProblem, OneMax, ZeroMax, Jump
export fitness, optimum

include("instance.jl")
export Instance

export fitness

include("utils/utils.jl")
export UniformlyIndependentMutation
export mutation, flip, mutationpositions


include("trace.jl")
export Trace, info, record

include("algorithms/algorithms.jl")
export optimize, ea1pλwith2rates, ea1p1, ea1p1SD
export SDCounter, SDCounterEstimation, thresholds
export fixedbudget, niterations

include("experiments/experiments.jl")
export Experiment
export HPC
export cluster, createworkspaceinserver, createworkspace

end
