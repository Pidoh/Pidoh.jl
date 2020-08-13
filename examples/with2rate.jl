using Random
using DataFrames
using Plots
using Pidoh

fit = OneMax()
# Here, we define the mutation function on one bit.
mutation(x::Bool, prob::Real) = if (rand() < prob) return ~x else return x end

function mutation(x::BitArray, prob::Real)
    y = copy(x)
    # The dot after function name means that run the function for each element in y.
    mutation.(y, prob)
end

function with2rate(n, λ, max_iter, fit)
    rowsdf = DataFrames.DataFrame()

    # bitrand returns a random bit string.
    x = bitrand(n)
    xfitness = fitness(x, fit)

    r = 2

    for iter ∈ 1:max_iter
        α = x
        αfitness = n
        rα = r
        for i in 1:λ
            if i ≤ λ/2
                ry = r/(2n)
                y = mutation(x, ry)
            else
                ry = 2r/n
                y = mutation(x, ry)
            end
            yfitness = fitness(y, fit)

            if yfitness < αfitness
                α = y
                αfitness = yfitness
                rα = ry
            end
        end

        # The second condition is for implementing "breaking ties randomly".
        if αfitness ≤ xfitness || (αfitness == xfitness && rand() < 0.5 )
            x = α
            xfitness = αfitness
            println(xfitness, " with rate= ", r, " in iteration= ", iter)
            push!(rowsdf, (iteration= iter, rate= rα, fitness= αfitness ))

            if xfitness == 0
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

df = with2rate(1000, 500, 10000, fit)


x = df.iteration
y = df.rate
# y = df.fitness

# plot(x, y)