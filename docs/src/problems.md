```@meta
CurrentModule = Pidoh
DocTestSetup = quote
    using Pidoh
end
```
# Problems
---
Here, you can see the built-in problems.

## BitString Problems

!!! note
      The fitness functions for BitString problems just accept `BitArray` or `Array{Bool,1}` as the types of solution instances. However, it is recommended to use `BitArray` instead of `Array{Bool,1}` since `BitArray` uses memory more efficiently. Nevertheless, solution instances with type `Array{Bool,1}` are changed to `BitArray` automatically.


```@docs

OneMax
```
