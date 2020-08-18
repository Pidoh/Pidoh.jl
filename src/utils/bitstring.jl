
flip(bit::Bool) = ~bit

abstract type Mutation end

struct UniformlyIndependentMutation
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
    y = copy(x.individual)
    for bit ∈ mutationpositions(x, mut)
        y[bit] = flip(y[bit])
    end
    Instance(y, x.problem)
end
