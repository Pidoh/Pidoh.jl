import Base: length, copy
using LaTeXStrings

"""
    Instance
A condidate solution for a specific problem.
## Examples
Consider the following example:
```jldoctest objective_function; setup = :(using Pidoh)
julia> x = Instance(BitArray([true,true,false,true]), OneMax(4));

julia> fitness(x)
3

julia> isoptimum(x)
false

```
"""
struct Instance{T}
    individual::T
    problem::AbstractProblem{T}
    fitnessvalue::Number
    name::LaTeXString

    function Instance(
        individual::T,
        problem::AbstractProblem{T};
        fitnessvalue::Number = -1,
        name::LaTeXString = L"problem",
    ) where {T}
        if fitnessvalue == -1
            fitnessvalue = fitness(individual, problem)
        end
        new{T}(individual, problem, fitnessvalue, name)
    end

    function Instance(
        individual,
        problem::AbstractProblem{T};
        fitnessvalue::Number = -1,
        name::LaTeXString = L"problem",
    ) where {T}
        throw(DomainError(
            individual,
            "The problem $(typeof(problem)) only accepts $(string(T)) as a solution.",
        ))
    end
end

fitness(solution::Instance) = solution.fitnessvalue
fitness(solution::Instance, flippositions) =
    fitness(solution.individual, solution.problem, solution.fitnessvalue, flippositions)
isoptimum(solution::Instance) = fitness(solution) == optimum(solution.problem)
length(solution::Instance) = length(solution.individual)

function copy(solution::Instance; fitnessvalue::Number = fitness(solution))
    Instance(solution.individual, solution.problem, fitnessvalue = fitnessvalue)
end

struct Population{T}
    solutions::Vector{Instance{T}}

    function Population(solutions::Vector{Instance{T}}) where {T}
      new{T}(solutions)
    end
end

fitness(population::Population) = maximum(fitness, population.solutions)
