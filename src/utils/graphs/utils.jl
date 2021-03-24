
function unmarkededges(g, x::BitArray)
    selected_edges = Vector{edgetype(g)}()


    for item in zip(1:ne(g), edges(g))
        if x[item[1]] == false
            # rem_edge!(subgraph, src(item[2]), dst(item[2]))
            push!(selected_edges, item[2])
        end
    end
    return selected_edges
end

function markededges(g, x::BitArray)
    selected_edges = Vector{edgetype(g)}()
    for item in zip(1:ne(g), edges(g))
        if x[item[1]]
            # rem_edge!(subgraph, src(item[2]), dst(item[2]))
            push!(selected_edges, item[2])
        end
    end
    return selected_edges
end

function graph_bitstring(g, x::BitArray)
    selected_edges = markededges(g, x)
    g2 = SimpleWeightedGraph(nv(g))
    for item in selected_edges
        # add_edge!(g2, src(item), dst(item), weight(item))
        add_edge!(g2, item)
    end
    return g2
end



mst_value(g) = sum([g.weights[src(edge), dst(edge)] for edge in prim_mst(g)])
