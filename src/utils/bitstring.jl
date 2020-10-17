using Distributions

flip(bit::Bool) = ~bit
function flip!(individual::BitArray,index::Integer)
    individual[index] = ~individual[index]
end

abstract type Mutation end

struct UniformlyIndependentMutation <: Mutation
    probability :: Real
end

function mutationpositions(x::Instance, mut::UniformlyIndependentMutation)
    positions :: Array{Int64,1} = []
    for bit in 1:length(x)
        if rand() < mut.probability
            push!(positions, bit)
        end
    end
    positions
end


function mutation(x::Instance, mut::UniformlyIndependentMutation)
    positions = mutationpositions(x, mut)
    length(positions) == 0 && return x

    y = copy(x.individual)
    for bit ∈ positions
        flip!(y,bit)
    end

    Instance(y, x.problem, fitnessvalue=fitness(x,positions))
end
# sa

struct HeavyTailedMutation <: Mutation
    β :: Float16
end

function mutationpositions(x::Instance, mut::UniformlyIndependentMutation)
    if mut.probability == 0
        return []
    elseif mut.probability == 1
        return collect(1:length(x))
    end

    positions :: Array{Int64,1} = []
    geom = Geometric(mut.probability)
    bit = rand(geom)+1

    while bit ≤ length(x)
        push!(positions, bit)
        bit += rand(geom)+1
    end
    positions
end


function mutation(x::Instance, mut::UniformlyIndependentMutation)
    positions = mutationpositions(x, mut)
    length(positions) == 0 && return x

    y = copy(x.individual)
    for bit ∈ positions
        flip!(y,bit)
    end
    Instance(y, x.problem, fitnessvalue=fitness(x,positions))
end
# sa
