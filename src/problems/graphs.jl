abstract type AbstractGraphProblem <: AbstractProblem{Any} end

import Base: length


using LightGraphs, SimpleWeightedGraphs

struct MST <: AbstractGraphProblem
    g::Any
    optimum::Real
    function MST(g; optimum::Real = -mst_value(g))
        new(g, optimum)
    end
end

function fitness(x::BitArray, problem::MST)
    penalty = 100000000
    g = problem.g

    subg = graph_bitstring(g, x)

    cc = connected_components(subg)
    if length(cc) != 1
        return -1 * (penalty + length(cc))
    end
    weights = sum(subg.weights) / 2 #Becuase subg.weights counts each edge twice.

    return -weights
end

function optimum(problem::MST)
    return problem.optimum
end

length(problem::MST) = nv(problem.g)

function TG(n)
    p = floor(Int, n / 4)
    q = floor(Int, n / 2)
    a = n^2
    g = SimpleWeightedGraph(complete_graph(q), 1)
    add_vertices!(g, 2 * p)
    for j = q+1:2:q+2p
        add_edge!(g, j, j - 1, 2 * a)
        add_edge!(g, j, j + 1, 2 * a)
        add_edge!(g, j + 1, j - 1, 3 * a)
    end
    g
end

#
function ER(n::Integer)
    g = erdos_renyi(n, 2 * Base.Math.log(n) / n)
    egs = collect(edges(g))
    k = SimpleWeightedGraph(n)
    for edge in egs
        add_edge!(k, src(edge), dst(edge), rand(1:n^2))
    end
    if n - 1 != length(prim_mst(k))
        return ER(n)
    end
    k
end


function Kn(n::Integer)
    g = complete_graph(n)
    egs = collect(edges(g))
    k = SimpleWeightedGraph(n)
    for edge in egs
        add_edge!(k, src(edge), dst(edge), rand(1:n^2))
    end
    if n - 1 != length(prim_mst(k))
        return ER(n)
    end
    k
end


#
#
# using GraphPlot
# g = ER(100)
# g.weights
#
#


#
#
struct MaximumMatching <: AbstractGraphProblem
    g::Any
    optimum::Real
    function MaximumMatching(g, optimum::Real)
        new(g, optimum)
    end
end


function fitness(x::BitArray, problem::MaximumMatching)
    h = copy(problem.g)

    for item in findall(row -> row == 0, x)
        edge = collect(edges(problem.g))[item]
        rem_edge!(h, edge)
    end

    degreeh = degree(h)
    dh = degreeh
    penalty = (ne(problem.g) + 1) * sum([max(0, i - 1) for i in dh])
    ne(h) - penalty
end

function optimum(problem::MaximumMatching)
    return problem.optimum
end

length(problem::MaximumMatching) = ne(problem.g)

function GHL(h, l)

    g = SimpleGraph(h * l)
    function nodeindex(L, H, l, h)
        return (h - 1) * L + l
    end

    for i = 1:l
        for j = 1:h
            if i != l
                if i % 2 == 1
                    add_edge!(g, nodeindex(l, h, i, j), nodeindex(l, h, i + 1, j))
                else
                    for k = 1:h
                        add_edge!(g, nodeindex(l, h, i, j), nodeindex(l, h, i + 1, k))
                    end
                end
            end
        end
    end
    g
end
