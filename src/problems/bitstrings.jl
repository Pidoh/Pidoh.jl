
abstract type AbstractBitstringProblem <: AbstractProblem end

"""
    OneMax
Fitness function for binary strings.
## Examples
Consider the following example:
```jldoctest PSDCone; setup = :(using JuMP)
julia> onemax = OneMax(100);
julia> fitness(BitArray([true, false, false, false]), onemax)
1
```
"""
struct OneMax <: AbstractBitstringProblem
    n :: Integer
end
fitness(x::BitArray, problem::OneMax) = sum(x)
optimum(problem::OneMax) = problem.n

struct ZeroMax <: AbstractBitstringProblem
    n :: Integer
end

fitness(x::BitArray, problem::ZeroMax) = problem.n - sum(x)
optimum(problem::ZeroMax) =  0

struct Jump <: AbstractBitstringProblem
    n :: Integer
    jumpsize :: Integer
end

function fitness(x::BitArray, problem::Jump)
    onemax = sum(x)
    n=problem.n
    k = problem.jumpsize
    jump = -1
    if ((onemax ≤ n - k) || (onemax == n))
        jump =k + onemax
    else
        jump = n - onemax
    end
    jump
end

optimum(problem::Jump) = problem.n+problem.jumpsize

function fitness(x::BitArray, problem::T, fitnessvalue :: Number, flipsposition) where {T <: AbstractProblem}
    y = copy(x)
    for item ∈ flipsposition
        flip!(y, item)
    end
    fitness(y, problem)
end

# function fitness(x::BitArray, problem::OneMax, fitnessvalue:: Number, flipsposition)
#     if length(flipsposition) == 0
#         return fitnessvalue
#     end
#     fit = fitnessvalue
#     for item ∈ flipsposition
#         @inbounds if x[item]
#             fit -= 1
#         else
#             fit += 1
#         end
#     end
#     fit
# end

# function fitness(x::BitArray, problem::Jump, fitnessvalue:: Number, flipsposition)
#     if length(flipsposition) == 0
#         return fitnessvalue
#     end
#     n=problem.n
#     k = problem.jumpsize
#
#     onemax = fitnessvalue
#
#     if fitnessvalue < k
#         onemax = n - fitnessvalue
#     else
#         onemax = fitnessvalue - k
#     end
#
#     if ((onemax ≤ n - k) || (onemax == n))
#         jump =k + onemax
#     else
#         jump = n - onemax
#     end
#
#     for item ∈ flipsposition
#         @inbounds if x[item]
#             onemax -= 1
#         else
#             onemax += 1
#         end
#     end
#
#     jump = -1
#     if ((onemax ≤ n - k) || (onemax == n))
#         jump =k + onemax
#     else
#         jump = n - onemax
#     end
#     jump
# end
