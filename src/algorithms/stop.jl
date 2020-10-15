
struct fixedbudget <: AbstractStop
    budget :: Int
end


niterations(stop::fixedbudget) = stop.budget
