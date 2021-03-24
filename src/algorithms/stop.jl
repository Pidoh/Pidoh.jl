
struct FixedBudget <: AbstractStop
    budget::Int
end


niterations(stop::FixedBudget) = stop.budget
