module Pidoh

abstract type AbstractProblem end
abstract type AbstractAlgorithm end
abstract type AbstractStop end
abstract type AbstractIP end

include("problems/problems.jl")
export AbstractProblem, AbstractBitstringProblem, AbstractGraphProblem, AbstractAlgorithm
export OneMax, ZeroMax, Jump
export MST, MaximumMatching
export MaxSAT, MaxSATgeneratorP
export TG, ER, Kn, GHL
export fitness, optimum

include("instance.jl")
export Instance
export initial
export fitness

include("utils/utils.jl")
export UniformlyIndependentMutation, HeavyTailedMutation
export mutation, flip, mutationpositions, Population
export OnePointCrossover, crossover, mate
export UniformlyIndependentSelection, TournamentSelection
export visualize, unmarkededges, markededges, graph_bitstring
export RandBitStringIP
export generate


include("trace.jl")
export Trace, info, record

include("algorithms/algorithms.jl")
export name
export optimize, ea1pλwith2rates, ea1p1, ea1p1SD, ea1pλSASD, RLSSDstar, RLS12, RLSSDstarstar
export ga
export SDCounter, SDCounterEstimation, RLSSDCounter, threshold_gen
export FixedBudget, niterations

include("experiments/experiments.jl")
# include("experiments/engines.jl")
export Experiment
export HPC
export cluster,
    createworkspaceinserver, createworkspace, loadexperiment, fetch, mergeexperiments

include("benchmark/benchmark.jl")
export benchmark

end
