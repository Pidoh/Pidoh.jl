
abstract type AbstractBitstringProblem <: AbstractProblem end

import Base: length


function fitness(x::Array{Bool,1}, problem)
    fitness(BitArray(x), problem)
end

function fitness(
    x::BitArray,
    problem::T,
    fitnessvalue::Number,
    flipsposition,
) where {T<:AbstractProblem}
    y = copy(x)
    for item ∈ flipsposition
        flip!(y, item)
    end
    fitness(y, problem)
end
"""
    struct OneMax <: AbstractBitstringProblem
        n::Integer
    end

Maximization of the number of `true` in a `BitArray`. The mathematical definition of this problem is
maximizing the number of one-bits in a bitstring, which can be seen in the following formula:

```math
OneMax(x_1,\\dots,x_n)\\coloneqq\\sum_{i=1}^{n}x_i.
```

## Examples
```jldoctest; setup = :(using Pidoh)
julia> problem = OneMax(4);

julia> fitness(BitArray([true,true,false,true]), problem)
3

julia> optimum(problem)
4

```
"""
struct OneMax <: AbstractBitstringProblem
    n::Integer
end
fitness(x::BitArray, problem::OneMax) = sum(x)
optimum(problem::OneMax) = problem.n
length(problem::OneMax) = problem.n

"""
    struct LeadingOnes <: AbstractBitstringProblem
        n::Integer
    end

Maximization of the length of a prefix of `BitArray`  that consits only of `true`. More formally

```math
LeadingOnes(x_1,\\dots,x_n)\\coloneqq\\sum_{i=1}^{n}\\prod_{j=1}^ix_j.
```

## Examples
```jldoctest; setup = :(using Pidoh)
julia> problem = LeadingOnes(4);

julia> fitness(BitArray([true,true,false,true]), problem)
2

julia> optimum(problem)
4

```
"""
struct LeadingOnes <: AbstractBitstringProblem
    n::Integer
end

function fitness(x::BitArray, problem::LeadingOnes)
    lo = 0
    while lo < problem.n && x[lo+1]
        lo += 1
    end
    lo
end

optimum(problem::LeadingOnes) = problem.n
length(problem::LeadingOnes) = problem.n


"""
    struct CliffTwoParameters <: AbstractBitstringProblem
        n::Integer
    end

## Examples
```jldoctest; setup = :(using Pidoh)
julia> problem = CliffTwoParameters(10, 4, 2);

```
"""
struct CliffTwoParameters <: AbstractBitstringProblem
    n::Integer
    m::Integer
    d::Integer
end

function fitness(x::BitArray, problem::CliffTwoParameters)
    onemax = sum(x)
    n = problem.n
    m = problem.m
    d = problem.d

    if onemax ≤ n - m
        return onemax
    else
        return onemax - d + 1
    end
end

optimum(problem::CliffTwoParameters) = problem.n - problem.d + 1
length(problem::CliffTwoParameters) = problem.n


struct ZeroMax <: AbstractBitstringProblem
    n::Integer
end

fitness(x::BitArray, problem::ZeroMax) = problem.n - sum(x)
optimum(problem::ZeroMax) = 0

struct Jump <: AbstractBitstringProblem
    n::Integer
    jumpsize::Integer
end

function fitness(x::BitArray, problem::Jump)
    onemax = sum(x)
    n = problem.n
    k = problem.jumpsize
    jump = -1
    if ((onemax ≤ n - k) || (onemax == n))
        jump = k + onemax
    else
        jump = n - onemax
    end
    jump
end

optimum(problem::Jump) = problem.n + problem.jumpsize
length(problem::Jump) = problem.n


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
