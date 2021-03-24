using Colors: @colorant_str
using GraphPlot


function visualize(g, gcolour)

    selected_edges = []


    edge_labels = map(e -> string(adjacency_matrix(g)[dst(e), src(e)]), edges(g))
    edge_colors =
        map(e -> e ∈ edges(gcolour) ? colorant"red" : colorant"lightgrey", edges(g))

    gplot(
        g,
        layout = circular_layout,
        nodelabel = vertices(g),
        edgelabel = edge_labels,
        edgestrokec = edge_colors,
    )
end

function visualize(g)

    selected_edges = []


    edge_labels = map(e -> string(adjacency_matrix(g)[dst(e), src(e)]), edges(g))

    gplot(g, layout = circular_layout, nodelabel = vertices(g), edgelabel = edge_labels)
end
