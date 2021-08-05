import Base: length, copy
using LaTeXStrings

"""
    CondidateSolution
A condidate solution for a specific problem.
## Examples
Consider the following example:
```jldoctest objective_function; setup = :(using Pidoh)
julia> x = CondidateSolution(BitArray([true,true,false,true]), OneMax(4));

julia> fitness(x)
3

julia> isoptimum(x)
false

```
"""
struct CondidateSolution{T}
    individual::T
    problem::AbstractProblem{T}
    fitnessvalue::Number
    name::LaTeXString

    function CondidateSolution(
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

    function CondidateSolution(
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

fitness(solution::CondidateSolution) = solution.fitnessvalue
fitness(solution::CondidateSolution, flippositions) =
    fitness(solution.individual, solution.problem, solution.fitnessvalue, flippositions)
isoptimum(solution::CondidateSolution) = fitness(solution) == optimum(solution.problem)
length(solution::CondidateSolution) = length(solution.individual)

function copy(solution::CondidateSolution; fitnessvalue::Number = fitness(solution))
    CondidateSolution(solution.individual, solution.problem, fitnessvalue = fitnessvalue)
end

struct Population{T}
    solutions::Vector{CondidateSolution{T}}

    function Population(solutions::Vector{CondidateSolution{T}}) where {T}
      new{T}(solutions)
    end
end

fitness(population::Population) = maximum(fitness, population.solutions)
