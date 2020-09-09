@test isregular(rand(4))
@test isregular(rand(4,4,4,4))
@test !isregular(rand(4,5))

@test mirror([1]) == [1]
@test mirror([2,3]) == [2,-3]
@test mirror([2,3,4]) == [2,-3,4]
@test mirror(@SVector([2,3,4])) == @SVector [2,-3,4]
@test mirror([4.9,5,6,7]) == [4.9,-5,6,-7]

@test upsample([1]) == [1,0]
@test upsample([1]; skipfirst=true) == [0,1]
@test upsample([1,2]) == [1,0,2,0]
@test upsample([1,2]; skipfirst=true) == [0,1,0,2]
@test downsample([1,2]) == [1]
@test downsample([1,2]; skipfirst=true) == [2]
@test downsample([1,2,3,4]) == [1,3]
@test downsample([1,2,3,4]; skipfirst=true) == [2,4]

signalsize = 64

@test_throws ArgumentError coefficientcount(ones(signalsize); level=0)
@test coefficientcount(ones(signalsize)) == signalsize
@test coefficientcount(rand(signalsize); threshold=1.01) == 0
@test coefficientcount(rand(signalsize).-2.5; threshold=1.01) == signalsize
@test coefficientcount([0,2,6,7,8]; threshold=6.6) == 2
@test coefficientcount([10,-11,6,7,8.0,-5,-8,0]; threshold=3, level=4) == 3
@test coefficientcount(ones(signalsize,signalsize)) == signalsize * signalsize
@test coefficientcount(rand(signalsize,signalsize); threshold=1.01) == 0
@test coefficientcount([-1 2;3 4]; threshold=2.5) == 2

signal = [1,2]
output = [1,2]
upto = 2
@test partition(signal) == output
@test partition(signal; upto) == output
@test combine(signal) == output
@test combine(signal; upto) == output


signal = [-1,2,3.3,4]
output = [-1,3.3,2,4]
upto = 4
@test partition(signal) == output
@test partition(signal; upto) == output

signal = [-1,3.3,2,4]
output = [-1,2,3.3,4]
@test combine(signal) == output
@test combine(signal; upto) == output

signal = randn(128)
@test signal == combine(partition(signal))

# with strides
signal = [1,2,3,4,5,6,7,8,9,10,11,12,13,14]

stride(s, i, l) = s:i:(s + (l - 1) * i)

@test partition(signal, stride(3, 2, 2))[1:2] == [3,5]
@test partition(signal, stride(3, 2, 4))[1:4] == [3,7,5,9]
@test partition(signal, stride(1, 3, 4))[1:4] == [1,7,4,10]
@test partition(signal, stride(1, 1, 8)) ==  partition(signal; upto=8)

range = stride(3, 2, 2)
@test combine(signal, range)[range] == [1,2]

range = stride(3, 2, 4)
@test combine(signal, range)[range] == [1,3,2,4]

range = stride(1, 3, 4)
@test combine(signal, range)[range] == [1,3,2,4]
@test combine(signal, stride(1, 1, 8)) ==  combine(signal; upto=8)