abstract type AbstractSimulatedAnnealing <: AbstractAlgorithm end
abstract type AbstractCooling end

"""
    struct FixedCooling <: AbstractCooling
        temperature::Float64
    end

Using this cooling scheduler, the algorithm accepts a worser solution with probability ``\\alpha^{-\\Delta}``, where 
``\\alpha`` is the parameter temperature and ``\\Delta`` is the absolute difference of the fitness functions between the parent and child.

Through `FixedCooling`, you are basicaully using `Metropolis` algorithm.
"""
struct FixedCooling <: AbstractCooling
    temperature::Float64
    function FixedCooling(temperature::Float64 = 0.0)
        new(temperature)
    end
end

function temperature(cooling::FixedCooling, temp::Real)
    return cooling.temperature
end

"""
    struct IntervalCooling <: AbstractCooling
        ℓ::Integer
        δ::Real
        k::Real
    end
"""
struct IntervalCooling <: AbstractCooling
    ℓ::Integer
    δ::Real
    k::Real
    function IntervalCooling(ℓ::Integer, δ::Real)
        k = δ^(1/ℓ)
        new(ℓ, δ, k)
    end
end

function temperature(cooling::IntervalCooling, temp::Real)
    temp/cooling.k
end

"""
    struct SimulatedAnnealing <: AbstractSimulatedAnnealing
        cooling::AbstractCooling
        stop::AbstractStop
        name::LaTeXString
        startingt::Real
        finishingt::Real
    end
"""
struct SimulatedAnnealing <: AbstractSimulatedAnnealing
    cooling::AbstractCooling
    temptransformation:: Function
    startingt::Real
    finishingt::Real
    stop::AbstractStop
    name::LaTeXString
    function SimulatedAnnealing(
        cooling::AbstractCooling;
        temptransformation::Function = (x->x) ,
        startingt::Real = 1,
        finishingt::Real = -1,
        stop::AbstractStop = FixedBudget(10^10),
        name::LaTeXString = L"Simulated-Annealing",
    )
        new(cooling, temptransformation, startingt, finishingt, stop, name)
    end
end

function optimize(x, setting::SimulatedAnnealing)
    trace = Trace(setting, x)
    x = initial(x)
    n = length(x)
    α = setting.startingt
    ϕ = setting.temptransformation

    for iter ∈ 1:niterations(setting.stop)
        α = float(temperature(setting.cooling, α))
        if α < setting.finishingt
            break
        end

        y = mutation(x, KBitFlip(1))
        Δ = fitness(y) - fitness(x)
        @info α
        if Δ ≥ 0
            if Δ > 0
                record(trace, y, iter, isoptimum(y))
            end
            x = y
            if isoptimum(x)
                return trace
            end
        elseif rand() ≤ (ϕ(α))^(Δ)
            record(trace, y, iter, isoptimum(y))
            x = y
        end
    end
    trace
end
