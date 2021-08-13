using Distributions
using StatsBase

flip(bit::Bool) = ~bit
function flip!(individual::BitArray, index::Integer)
    individual[index] = ~individual[index]
end

abstract type AbstractMutation end

struct UniformlyIndependentMutation <: AbstractMutation
    probability::Real
end


function uiimutationpositions(x::Instance{BitArray}, probability::Real)
    if probability == 0
        return []
    elseif probability == 1
        return collect(1:length(x))
    end

    positions::Array{Int64,1} = []
    geom = Geometric(probability)
    bit = rand(geom) + 1

    while bit ≤ length(x)
        push!(positions, bit)
        bit += rand(geom) + 1
    end
    positions
end


function mutation(x::Instance{BitArray}, mut::UniformlyIndependentMutation)
    positions = uiimutationpositions(x, mut.probability)
    length(positions) == 0 && return x

    y = copy(x.individual)
    for bit ∈ positions
        flip!(y, bit)
    end
    Instance(y, x.problem, fitnessvalue = fitness(x, positions))
end


struct KBitFlip <: AbstractMutation
    K::Integer
end

function mutation(x::Instance{BitArray}, mut::KBitFlip)
    positions = sample(1:length(x), mut.K, replace = false)
    y = copy(x.individual)
    for bit ∈ positions
        flip!(y, bit)
    end
    Instance(y, x.problem, fitnessvalue = fitness(x, positions))
end



function discretepowerlaw(β::Real, n)
    if β ≤ 1
        error("β must be greater than 1")
    end
    n2::Integer = floor(n / 2)

    pdf = collect(Float64, 1:n2) .^ (-β)

    pdf = pdf ./ sum(pdf)

    Categorical(pdf)
end


struct HeavyTailedMutation <: AbstractMutation
    β::Float64
    n::Integer
    dpl::DiscreteNonParametric{Int64,Float64,Base.OneTo{Int64},Array{Float64,1}}
    function HeavyTailedMutation(β::Float64, n::Integer; dpl = discretepowerlaw(β, n))
        new(β, n, dpl)
    end
end

function mutation(x::Instance{BitArray}, mut::HeavyTailedMutation)
    positions = uiimutationpositions(x, rand(mut.dpl) // mut.n)
    length(positions) == 0 && return x

    y = copy(x.individual)
    for bit ∈ positions
        flip!(y, bit)
    end
    Instance(y, x.problem, fitnessvalue = fitness(x, positions))
end

function mutation(x::Population, mut::AbstractMutation)
    Population(mutation.(x.solutions, [mut]), x.problem)
end
