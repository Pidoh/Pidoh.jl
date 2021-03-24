import Base: length, copy
using LaTeXStrings

"""
    Instance
Solution instance
## Examples
Consider the following example:
```jldoctest objective_function; setup = :(using Pidoh)
julia> x = Instance(BitArray([true,true,false,true]), OneMax(4));

julia> fitness(x)
3

julia> optimum(x)
4

```
"""
struct Instance
    individual::Any
    problem::AbstractProblem
    generator::Union{Nothing,AbstractIP}
    fitnessvalue::Number
    name::LaTeXString

    function Instance(
        individual,
        problem::AbstractProblem;
        generator::Union{Nothing,AbstractIP} = nothing,
        fitnessvalue::Number = -1,
        name::LaTeXString = L"problem",
    )
        if fitnessvalue == -1
            fitnessvalue = fitness(individual, problem)
        end
        new(individual, problem, generator, fitnessvalue, name)
    end

    function Instance(
        problem::AbstractProblem;
        generator::Union{Nothing,AbstractIP} = nothing,
        individual = nothing,
        fitnessvalue::Number = -1,
        name::LaTeXString = L"problem",
    )
        if !isnothing(individual) && fitnessvalue == -1
            fitnessvalue = fitness(individual, problem)
        end
        new(individual, problem, generator, fitnessvalue, name)
    end
end

fitness(instance::Instance) = instance.fitnessvalue
fitness(instance::Instance, flippositions) =
    fitness(instance.individual, instance.problem, instance.fitnessvalue, flippositions)
optimum(instance::Instance) = optimum(instance.problem)
isoptimum(instance::Instance) = fitness(instance) == optimum(instance)
length(instance::Instance) = length(instance.individual)

function initial(instance::Instance)
    ind = generate(instance.generator)
    if !isnothing(instance.generator)
        return Instance(instance.problem, individual = ind)
    end
end

function copy(instance::Instance; fitnessvalue::Number = fitness(instance))
    Instance(instance.individual, instance.problem, fitnessvalue = fitnessvalue)
end
