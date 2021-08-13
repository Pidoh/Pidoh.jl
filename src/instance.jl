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
        throw(
            DomainError(
                individual,
                "The problem $(typeof(problem)) only accepts $(string(T)) as a solution.",
            ),
        )
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
    problem::AbstractProblem{T}
    solutions::Vector{Instance{T}}
    fittest::Instance{T}

    function Population(
        solutions::Vector{Instance{T}},
        problem::AbstractProblem{T},
    ) where {T}
        @assert length(solutions) > 0 "your population can't be empty"

        fittest = solutions[1]
        for i = 2:length(solutions)
            if fitness(solutions[i]) > fitness(fittest)
                fittest = solutions[i]
            end
        end

        new{T}(problem, solutions, fittest)
    end

    function Population(solutions::Vector{T}, problem::AbstractProblem{T}) where {T}
        @assert length(solutions) > 0 "your population can't be empty"
        solutions::Vector{Instance{T}} = map(x -> Instance(x, problem), solutions)

        fittest = solutions[1]
        for i = 2:length(solutions)
            if fitness(solutions[i]) > fitness(fittest)
                fittest = solutions[i]
            end
        end

        new{T}(problem, solutions, fittest)
    end
end

fittest(population::Population) = population.fittest
fitness(population::Population) = fitness(fittest(population))
hasoptimum(population::Population) =
    fitness(population.fittest) == optimum(population.problem)
