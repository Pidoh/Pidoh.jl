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
length(instance::Instance) = length(instance.individual)

function copy(instance::Instance; fitnessvalue::Number=fitness(instance))
    Instance(instance.individual,instance.problem, fitnessvalue=fitnessvalue )
end
