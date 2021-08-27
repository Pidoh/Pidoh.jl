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

function temperature(cooling::FixedCooling, iter::Int)
    return cooling.temperature
end

"""
    struct SimulatedAnnealing <: AbstractSimulatedAnnealing
        cooling::AbstractCooling
        stop::AbstractStop
        name::LaTeXString
        temperature::Float64
    end
"""
struct SimulatedAnnealing <: AbstractSimulatedAnnealing
    cooling::AbstractCooling
    stop::AbstractStop
    name::LaTeXString
    temperature::Float64
    function SimulatedAnnealing(
        cooling::AbstractCooling;
        stop::AbstractStop = FixedBudget(10^10),
        name::LaTeXString = L"Simulated-Annealing",
        temperature::Float64 = -1.0,
    )
        new(cooling, stop, name, temperature)
    end
end

function optimize(x, setting::SimulatedAnnealing)
    trace = Trace(setting, individual = x)
    n = length(x)

    for iter ∈ 1:niterations(setting.stop)
        α = temperature(setting.cooling, iter)
        y = mutation(x, KBitFlip(1))
        Δ = fitness(y) - fitness(x)

        if Δ ≥ 0
            if Δ > 0
                record!(trace, iter, isoptimum(y), individual = y)
            end
            x = y
            if isoptimum(x)
                return trace
            end
        elseif rand() ≤ α^(Δ)
            record!(trace, iter, isoptimum(y), individual = y)
            x = y
        end
    end
    trace
end
