module Pidoh



include("problems/problems.jl")
export AbstractProblem, OneMax, ZeroMax
export fitness

include("instance.jl")
export Instance
export fitness

include("utils/utils.jl")
export UniformlyIndependentMutation
export mutation, flip, mutationpositions
end
