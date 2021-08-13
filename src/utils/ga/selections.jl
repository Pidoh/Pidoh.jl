using StatsBase
using Distributions

abstract type AbstractSelection end

struct UniformlyIndependentSelection <: AbstractSelection
    probability::Float64
end

function select(
    population::Population{T},
    selection::UniformlyIndependentSelection,
)::Population{T} where {T}
    selected_solutions::Vector{Instance{T}} = []

    geometric = Geometric(selection.probability)
    index = rand(geometric) + 1

    while index ≤ length(population.solutions)
        push!(selected_solutions, population.solutions[index])
        index += rand(geometric) + 1
    end

    Population(selected_solutions, population.problem)
end

struct TournamentSelection <: AbstractSelection
    tournament_size::Int64
    count_of_tournaments::Int64
end

function fittest(solutions::Vector{Instance{T}})::Instance{T} where {T}
    return reduce(
        (x::Instance, y::Instance) -> x.fitnessvalue > y.fitnessvalue ? x : y,
        solutions,
    )
end

function select(
    population::Population{T},
    selection::TournamentSelection,
)::Population{T} where {T}
    tournaments = [
        sample(population.solutions, selection.tournament_size) for
        _ = 1:(selection.count_of_tournaments)
    ]
    selected_solutions = cat(population.solutions, fittest.(tournaments), dims = 1)

    Population(selected_solutions, population.problem)
end
