using Random

struct RandBitStringIP <: AbstractIP{BitArray}
    n::Integer
end

generate(ip::RandBitStringIP) = bitrand(ip.n)
