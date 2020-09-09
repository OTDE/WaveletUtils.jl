
@test degree(0) == 1
@test degree(1) == 2
@test detailindex(0,1) == 2

level = 5
@test degree(level) + 1 == first(detailrange(level))
@test detailindex(level, 3) == detailrange(level)[3]

level = 7
signal = zeros(2^level)

@test scales(2^level) == level
@test degree(dyadiclevelmax(2^level)) == 2^(level - 1)
@test scales(signal) == level
@test dyadiclevelmax(signal) == level - 1

dyadiclevel = 8
signalsize = 512
signal = zeros(signalsize)

@test todyadiclevel(signalsize, 1) == dyadiclevel
@test iszero(todyadiclevel(signalsize, dyadiclevel + 1))
@test todyadiclevel(signal, 1) == dyadiclevel
@test iszero(todyadiclevel(signal, dyadiclevel + 1))

signalsize = 64
level = 2
offset = 3

@test levelmax(signalsize) == scales(signalsize)
@test levelmax(signalsize) == overlaplevelmax(signalsize)
@test detailindex(signalsize, level, offset) == detailindex(todyadiclevel(signalsize, level), offset)
@test detailrange(signalsize, level) == detailrange(todyadiclevel(signalsize, level))
@test degree(signalsize, level) == degree(todyadiclevel(signalsize, level))

@test isdyadic(rand(4))
@test isdyadic(4)
@test isdyadic(rand(32,32))
@test !isdyadic(rand(6))
@test !isdyadic(6)