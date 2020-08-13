using Pidoh

@testset "Flip bit string" begin
    @test flip(true) == false
    @test flip(false) == true
end
