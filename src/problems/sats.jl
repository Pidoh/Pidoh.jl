using Random

abstract type AbstractSatProblem <: AbstractProblem end

import Base: length

struct MaxSAT <: AbstractSatProblem
    cnf::Array{Array{Integer,1},1}
    variables::Array{Integer,1}
    optimum::Real
    function MaxSAT(
        cnf;
        variables::Array{Integer,1} = Array{Integer}(undef, 0),
        optimum::Real = length(cnf),
    )
        for clause in cnf
            for var in clause
                push!(variables, sign(var) * var)
            end
        end
        new(cnf, unique(variables), optimum)
    end
end

function fitness(x::BitArray, problem::MaxSAT)
    cnf = problem.cnf
    satisfied = 0
    for clause in cnf
        for var in clause
            pvar = var * sign(var)
            if var > 0 && x[pvar] == 1
                satisfied += 1
                break
            elseif var < 0 && x[pvar] == 0
                satisfied += 1
                break
            end
        end
    end
    satisfied
end

function optimum(problem::MaxSAT)
    return problem.optimum
end

length(problem::MaxSAT) = (length(problem.variables), length(problem.cnf))


function SATgeneratorP(n, m, k)
    cnf = []
    if k > n
        error("The number of variables must not be less than k.")
    end
    while length(cnf) < m
        clause = rand([-n:-1; 1:n], k)
        if sum(sign.(clause)) == -k
            continue
        end

        if length(unique(clause .* sign.(clause))) == k
            push!(cnf, clause)
        end
    end
    cnf
end

function MaxSATgeneratorP(n, m, k)
    while true
        cnf = SATgeneratorP(n, m, k)
        p = MaxSAT(cnf)
        fit = fitness(BitArray(ones(Bool, n)), p)
        println(fit)
        if optimum(p) == fit
            return p
        end
    end
end
