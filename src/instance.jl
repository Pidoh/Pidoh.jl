import Base: length, copy

struct Instance
    individual
    problem :: AbstractProblem
    fitnessvalue :: Number

    function Instance(individual, problem::AbstractProblem; fitnessvalue=fitness( individual, problem))
        new(individual, problem, fitnessvalue)
    end
end


fitness(instance::Instance) = instance.fitnessvalue
fitness(instance::Instance, flippositions) = fitness(instance.individual, instance.problem, instance.fitnessvalue, flippositions)
optimum(instance::Instance) = optimum(instance.problem)
isoptimum(instance::Instance) = fitness(instance) == optimum(instance)
length(instance::Instance) = length(instance.individual)

function copy(instance::Instance; fitnessvalue::Number=fitness(instance))
    Instance(instance.individual,instance.problem, fitnessvalue=fitnessvalue )
end
