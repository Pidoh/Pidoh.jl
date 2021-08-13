```@meta
CurrentModule = Pidoh
DocTestSetup = quote
    using Pidoh
end
```
# Simulated Annealing and Metropolis Algorithms

## Examples
```@example
using Pidoh
algorithm = SimulatedAnnealing(FixedCooling(10.0), stop = FixedBudget(10^6));
instance = Instance(generator = RandBitStringIP(100), OneMax(100));
experiment = Experiment("SAonOneMax", [algorithm], [instance], save = false);
res = run(experiment);
last(res.jobs[1].trace.rows, 10)
```

## Built-in algorithms
```@docs

SimulatedAnnealing
```

## Built-in cooling schedules
### Fixed Cooling Schedulers
```@docs

FixedCooling
```

### Dynamic Cooling Schedulers
There is no dynamic cooling schedulers implemented yet.