module Pidoh

abstract type AbstractProblem{SolutionT} end
abstract type AbstractAlgorithm end
abstract type AbstractPopAlgorithm <: AbstractAlgorithm end
abstract type AbstractStop end
abstract type AbstractIP{T} end

include("problems/problems.jl")
export AbstractProblem, AbstractBitstringProblem, AbstractGraphProblem, AbstractAlgorithm
export OneMax, ZeroMax, Jump
export MST, MaximumMatching
export MaxSAT, MaxSATgeneratorP
export TG, ER, Kn, GHL
export fitness, optimum

include("instance.jl")
export Instance, Population
export fitness

include("utils/utils.jl")
export UniformlyIndependentMutation, HeavyTailedMutation
export mutation, flip, mutationpositions, Population
export visualize, unmarkededges, markededges, graph_bitstring
export RandBitStringIndividualIP, RandBitStringPopulationIP
export generate


include("trace.jl")
export Trace, info, record!

include("algorithms/algorithms.jl")

include("experiments/experiments.jl")
# include("experiments/engines.jl")
export Experiment, run!
export HPC
export cluster,
    createworkspaceinserver, createworkspace, loadexperiment, fetch, mergeexperiments

include("benchmark/benchmark.jl")
export benchmark

end
