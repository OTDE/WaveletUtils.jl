n = 128
signal = randn(n)
for level in 0:scales(n)
    @test isvalidtree(signal, fulltree(signal, level))
    @test isvalidtree(signal, transformtree(signal, level))
end

tree = fulltree(signal, 4)
tree[5] = false
@test !isvalidtree(signal, tree)

tree = fulltree(signal, 4)
tree[18] = true
@test isvalidtree(signal, tree)

tree[7] = false
@test !isvalidtree(signal, tree)

tree[7] = true
tree[9] = false
@test !isvalidtree(signal, tree)