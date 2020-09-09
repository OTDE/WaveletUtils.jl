using WaveletUtils, StaticArrays, Test

@testset "Detail" begin 
    include("detail.jl")
end

@testset "Collections" begin
    include("collections.jl")
end

@testset "Trees" begin
    include("trees.jl")
end