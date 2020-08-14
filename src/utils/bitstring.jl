
flip(bit::Bool) = ~bit

abstract type Mutation end

struct UniformlyIndependentMutation
    probability :: Real
end


mutation(x, mut::UniformlyIndependentMutation) = if (rand() < mut.probability) return flip(x) else return x end

function mutation(x::T, mut::UniformlyIndependentMutation) where T <:AbstractArray
    y = copy(x)
    for bit ∈ 1:length(y)
        y[bit] = mutation(y[bit], mut)
    end
    return y
end
