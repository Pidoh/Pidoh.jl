

struct OneMax <: AbstractProblem end
struct ZeroMax <: AbstractProblem end

fitness(x::BitArray, problem::OneMax) = length(x) - sum(x)

fitness(x::BitArray, problem::ZeroMax) = sum(x)
