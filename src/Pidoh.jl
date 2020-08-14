module Pidoh

include("utils/utils.jl")
export UniformlyIndependentMutation
export mutation, flip


include("problems/problems.jl")
export OneMax, ZeroMax
export fitness
end
