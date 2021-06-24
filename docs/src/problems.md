```@meta
CurrentModule = Pidoh
DocTestSetup = quote
    using Pidoh
end
```
# Implement your Optimization Problem
To implement your specific problem, you just need to define one struct and the three functions `fitness`, `optimum`, and `length`.
All basic information related to the problm such as dimensions or data structures must be put in the struct. The function `fitness` is supposed to evaluate an instance of the problem, taking the instance datatype and the problem struct as its inputs. `optimum` gets the problem object and returns the optimum value. The function `length` is used to understand the size or difficulty of the problem.