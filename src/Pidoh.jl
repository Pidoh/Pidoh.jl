module Pidoh

include("utils/utils.jl")
export flip

include("problems/problems.jl")
export OneMax, ZeroMax
export fitness
end
