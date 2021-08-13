using Random

struct RandBitStringIndividualIP <: AbstractIP{BitArray}
    n::Integer
end

generate(ip::RandBitStringIndividualIP)::BitArray = bitrand(ip.n)

struct RandBitStringPopulationIP <: AbstractIP{BitArray}
    n::Integer
    populationsize::Integer
end

generate(ip::RandBitStringPopulationIP)::Vector{BitArray} =
    map(_ -> bitrand(ip.n), 1:(ip.populationsize))
