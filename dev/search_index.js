var documenterSearchIndex = {"docs":
[{"location":"problems/","page":"Implement your Optimization Problem","title":"Implement your Optimization Problem","text":"CurrentModule = Pidoh\nDocTestSetup = quote\n    using Pidoh\nend","category":"page"},{"location":"problems/#Implement-your-Optimization-Problem","page":"Implement your Optimization Problem","title":"Implement your Optimization Problem","text":"","category":"section"},{"location":"problems/","page":"Implement your Optimization Problem","title":"Implement your Optimization Problem","text":"To implement your specific problem, you just need to define one struct and the three functions fitness, optimum, and length. All basic information related to the problm such as dimensions or data structures must be put in the struct. The function fitness is supposed to evaluate an instance of the problem, taking the instance datatype and the problem struct as its inputs. optimum gets the problem object and returns the optimum value. The function length is used to understand the size or difficulty of the problem.","category":"page"},{"location":"bitstringproblems/","page":"BitString Problems","title":"BitString Problems","text":"CurrentModule = Pidoh\nDocTestSetup = quote\n    using Pidoh\nend","category":"page"},{"location":"bitstringproblems/#BitString-Problems","page":"BitString Problems","title":"BitString Problems","text":"","category":"section"},{"location":"bitstringproblems/#BitString-data-structure","page":"BitString Problems","title":"BitString data structure","text":"","category":"section"},{"location":"bitstringproblems/","page":"BitString Problems","title":"BitString Problems","text":"The fitness functions for BitString problems just accept BitArray or Array{Bool,1} as the types of solution instances. However, it is recommended to use BitArray instead of Array{Bool,1} since BitArray uses memory more efficiently. Nevertheless, solution instances with type Array{Bool,1} are changed to BitArray automatically.","category":"page"},{"location":"bitstringproblems/#Built-in-problems","page":"BitString Problems","title":"Built-in problems","text":"","category":"section"},{"location":"bitstringproblems/","page":"BitString Problems","title":"BitString Problems","text":"\nOneMax","category":"page"},{"location":"bitstringproblems/#Pidoh.OneMax","page":"BitString Problems","title":"Pidoh.OneMax","text":"struct OneMax <: AbstractBitstringProblem\n    n::Integer\nend\n\nMaximization of the number of true in a BitArray. The mathematical definition of this problem is maximizing the number of one-bits in a bitstring, which can be seen in the following formula:\n\nOneMax(x_1dotsx_n)coloneqqsum_i=1^nx_i\n\nExamples\n\njulia> problem = OneMax(4)\nOneMax(4)\n\njulia> fitness(BitArray([true,true,false,true]), problem)\n3\n\njulia> optimum(problem)\n4\n\n\n\n\n\n\n","category":"type"},{"location":"instances/","page":"Instances","title":"Instances","text":"CurrentModule = Pidoh\nDocTestSetup = quote\n    using Pidoh\nend","category":"page"},{"location":"instances/#Solution-Instances","page":"Instances","title":"Solution Instances","text":"","category":"section"},{"location":"instances/","page":"Instances","title":"Instances","text":"","category":"page"},{"location":"instances/","page":"Instances","title":"Instances","text":"\nInstance","category":"page"},{"location":"instances/#Pidoh.Instance","page":"Instances","title":"Pidoh.Instance","text":"Instance\n\nSolution instance\n\nExamples\n\nConsider the following example:\n\njulia> x = Instance(BitArray([true,true,false,true]), OneMax(4));\n\njulia> fitness(x)\n3\n\njulia> optimum(x)\n4\n\n\n\n\n\n\n","category":"type"},{"location":"simulatedannealing/","page":"Simulated Annealing and Metropolis Algorithms","title":"Simulated Annealing and Metropolis Algorithms","text":"CurrentModule = Pidoh\nDocTestSetup = quote\n    using Pidoh\nend","category":"page"},{"location":"simulatedannealing/#Simulated-Annealing-and-Metropolis-Algorithms","page":"Simulated Annealing and Metropolis Algorithms","title":"Simulated Annealing and Metropolis Algorithms","text":"","category":"section"},{"location":"simulatedannealing/#Examples","page":"Simulated Annealing and Metropolis Algorithms","title":"Examples","text":"","category":"section"},{"location":"simulatedannealing/","page":"Simulated Annealing and Metropolis Algorithms","title":"Simulated Annealing and Metropolis Algorithms","text":"using Pidoh\nalgorithm = SimulatedAnnealing(FixedCooling(10.0), stop = FixedBudget(10^6));\ninstance = Instance(generator = RandBitStringIP(100), OneMax(100));\nexperiment = Experiment(\"SAonOneMax\", [algorithm], [instance], save = false);\nres = run(experiment);\nlast(res.jobs[1].trace.rows, 10)","category":"page"},{"location":"simulatedannealing/#Built-in-algorithms","page":"Simulated Annealing and Metropolis Algorithms","title":"Built-in algorithms","text":"","category":"section"},{"location":"simulatedannealing/","page":"Simulated Annealing and Metropolis Algorithms","title":"Simulated Annealing and Metropolis Algorithms","text":"\nSimulatedAnnealing","category":"page"},{"location":"simulatedannealing/#Pidoh.SimulatedAnnealing","page":"Simulated Annealing and Metropolis Algorithms","title":"Pidoh.SimulatedAnnealing","text":"struct SimulatedAnnealing <: AbstractSimulatedAnnealing\n    cooling::AbstractCooling\n    stop::AbstractStop\n    name::LaTeXString\n    temperature::Float64\nend\n\n\n\n\n\n","category":"type"},{"location":"simulatedannealing/#Built-in-cooling-schedules","page":"Simulated Annealing and Metropolis Algorithms","title":"Built-in cooling schedules","text":"","category":"section"},{"location":"simulatedannealing/#Fixed-Cooling-Schedulers","page":"Simulated Annealing and Metropolis Algorithms","title":"Fixed Cooling Schedulers","text":"","category":"section"},{"location":"simulatedannealing/","page":"Simulated Annealing and Metropolis Algorithms","title":"Simulated Annealing and Metropolis Algorithms","text":"\nFixedCooling","category":"page"},{"location":"simulatedannealing/#Pidoh.FixedCooling","page":"Simulated Annealing and Metropolis Algorithms","title":"Pidoh.FixedCooling","text":"struct FixedCooling <: AbstractCooling\n    temperature::Float64\nend\n\nUsing this cooling scheduler, the algorithm accepts a worser solution with probability alpha^-Delta, where  alpha is the parameter temperature and Delta is the absolute difference of the fitness functions between the parent and child.\n\nThrough FixedCooling, you are basicaully using Metropolis algorithm.\n\n\n\n\n\n","category":"type"},{"location":"simulatedannealing/#Dynamic-Cooling-Schedulers","page":"Simulated Annealing and Metropolis Algorithms","title":"Dynamic Cooling Schedulers","text":"","category":"section"},{"location":"simulatedannealing/","page":"Simulated Annealing and Metropolis Algorithms","title":"Simulated Annealing and Metropolis Algorithms","text":"There is no dynamic cooling schedulers implemented yet.","category":"page"},{"location":"","page":"Pidoh","title":"Pidoh","text":"CurrentModule = Pidoh","category":"page"},{"location":"#Pidoh","page":"Pidoh","title":"Pidoh","text":"","category":"section"},{"location":"","page":"Pidoh","title":"Pidoh","text":"Profiling Iterative Discrete Optimization Heuristics","category":"page"},{"location":"","page":"Pidoh","title":"Pidoh","text":"Pages = [\n    \"problems.md\",\n    \"bitstringproblems.md\",\n    \"instances.md\",\n]\nDepth = 2","category":"page"}]
}