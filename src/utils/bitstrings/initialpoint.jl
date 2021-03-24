using Random

struct RandBitStringIP <: AbstractIP
    n::Integer
end

generate(ip::RandBitStringIP) = bitrand(ip.n)
