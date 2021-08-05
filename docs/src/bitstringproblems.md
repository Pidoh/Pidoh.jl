```@meta
CurrentModule = Pidoh
DocTestSetup = quote
    using Pidoh
end
```
# BitString Problems

## BitString data structure
The fitness functions for BitString problems just accept `BitArray` or `Array{Bool,1}` as the types of solution instances. However, it is recommended to use `BitArray` instead of `Array{Bool,1}` since `BitArray` uses memory more efficiently. Nevertheless, solution instances with type `Array{Bool,1}` are changed to `BitArray` automatically.

## Built-in problems
### Unimodal problems
```@docs

OneMax
LeadingOnes
```

### Multimodal problems
```@docs

CliffTwoParameters
```
