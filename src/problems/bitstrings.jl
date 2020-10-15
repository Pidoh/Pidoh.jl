
abstract type AbstractBitstringProblem <: AbstractProblem end

struct OneMax <: AbstractBitstringProblem
    n :: Integer
end
fitness(x::BitArray, problem::OneMax) = problem.n - sum(x)
optimum(problem::OneMax) = problem.n

struct ZeroMax <: AbstractBitstringProblem
    n :: Integer
end

fitness(x::BitArray, problem::ZeroMax) = sum(x)
optimum(problem::ZeroMax) =  0

struct Jump <: AbstractBitstringProblem
    n :: Integer
    jumpsize :: Integer
end

function fitness(x::BitArray, problem::Jump)
    onemax = sum(x)
    n=length(x)
    k = problem.jumpsize
    jump = -1
    if ((onemax ≤ n - k) || (onemax == n))
        jump =k + onemax
    else
        jump = n - onemax
    end
    jump
end

optimum(problem::Jump) = problem.n+problem.jumpsize

function fitness(x::BitArray, problem::T, flipsposition) where {T <: AbstractProblem}
    y = copy(x)
    for item ∈ flipsposition
        flip!(y, item)
    end
    fitness(y, problem)
end
