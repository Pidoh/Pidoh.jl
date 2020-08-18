using Random
using DataFrames
using Plots
using Pidoh


# Here, we define the mutation function on one bit.
function with2rate(x, λ, max_iter)
    rowsdf = DataFrames.DataFrame()
    # bitrand returns a random bit string.

    r = 2

    for iter ∈ 1:max_iter
        α = copy(x, fitnessvalue = length(x))
        rα = r
        for i in 1:λ
            if i ≤ λ/2
                ry = r/(2n)
                y = mutation(x, UniformlyIndependentMutation(ry))
            else
                ry = 2r/n
                y = mutation(x, UniformlyIndependentMutation(ry))
            end

            if fitness(y) ≦ fitness(α)
                α = y
                rα = ry
            end
        end

        # The second condition is for implementing "breaking ties randomly".
        if fitness(α) ≤ fitness(x) || (fitness(α) == fitness(x) && rand() < 0.5 )
            x = α
            println(fitness(x), " with rate= ", r, " in iteration= ", iter)
            push!(rowsdf, (iteration= iter, rate= rα, fitness= fitness(α) ))

            if fitness(x) == 0
                println("The Optimum is found.")
                return rowsdf
            end
        end

        if rand() < 0.5
            r = rα
        else
            r = if (rand() < 0.5)  r = r/2  else  r = 2r  end
        end
        r = min(max(r,2),n/4)
    end
    return rowsdf
end

n = 10000
x = Instance(bitrand(n), OneMax())

df = with2rate(x, 50, 10000)


x = df.iteration
y = df.rate
# y = df.fitness

plot(x, y)
