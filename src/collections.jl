export 
    isregular, mirror, upsample, 
    downsample, coefficientcount, partition, 
    combine, copyrange, copyrange!

#####
##### Collection utilities
#####

"""
    isregular(signal::AbstractArray)

Return `true` if all dimensions of a `signal` are of equal size.
"""
isregular(signal::AbstractArray) = isone(length(unique(size(signal))))

"""
    mirror(signal::AbstractVector)

Flip the sign of each odd index in `signal` and return the resulting vector.
Roughly ten times faster than the original implementation.
"""
mirror(signal::AbstractVector) = [flipsign(sample, -iseven(index)) for (index, sample) in enumerate(signal)]

"""
    mirror(signal::StaticVector)

Flip the sign of each odd index in `signal` and return the resulting vector.
About 1/3 faster than when dispatching on `Base` arrays and non-allocating.
"""
mirror(signal::StaticVector) = typeof(signal)(_mirror(signal))

@generated function _mirror(signal::StaticVector{N,T}) where {N,T}
    return Expr(:tuple, (iseven(i) ? :(-signal[$i]) : :(signal[$i]) for i in 1:N)...)
end

"""
    upsample(signal; skipfirst=true)

Doubles the number of samples in `signal` by inserting a zero of `eltype(signal)`
on one side of each sample. If `skipfirst` is `true`, these zeros are inserted on
the left side of each element; otherwise, the zeros are inserted on the right side.
"""
function upsample(signal; skipfirst=false)
    dest = zeros(eltype(signal), length(signal) << 1)
    _upsample!(dest, signal; skipfirst)
    return dest
end

_upsample!(dest, src; skipfirst=false) = copyto!(@view(dest[(begin + skipfirst):2:end]), src)

"""
    downsample(signal; skipfirst=true)

Selects every other sample in `signal` and returns those samples as a vector.
If `skipfirst` is `true`, the sample selection process begins with the first
sample; otherwise, the process begins with the second sample in the signal.
"""
downsample(signal; skipfirst=false) = _downsample!(similar(signal, length(signal) >> 1), signal; skipfirst)

_downsample!(dest, src; skipfirst=false) = copyto!(dest, @view(src[(begin + skipfirst):2:end]))

"""
    coefficientcount(signal; threshold=zero(eltype(signal)), level::Integer=1)

Returns the number of coefficients in `signal` greater than or equal to
`threshold`, excluding coefficients in levels below `level`. 
"""
function coefficientcount(signal; threshold=zero(eltype(signal)), level::Integer=1)
    level > 0 || throw(ArgumentError("transform level must be greater than zero"))
    start = level > 1 ? 1 + (1 << (level - 2)) : 1
    return count(>=(threshold) ∘ abs, @view(signal[start:end]))
end

"""
    partition(signal; upto=lastindex(signal))

Split the odd- and even-indexed elements in `signal` from the start
to the index `upto`, storing the odd and even elements in-place, respectively, 
then the remaining elements from `signal`, returning the result.
"""
partition(signal; upto=lastindex(signal)) = _partition!(copy(signal), signal; upto)

function _partition!(dest, src; upto=lastindex(src))
    odd_range, even_range = 1:2:upto, 2:2:upto
    odd_size, even_size = length(odd_range), length(even_range)
    odd_dest, even_dest = 1:odd_size, (odd_size + 1):upto
    @views begin
        copyto!(dest[odd_dest], src[odd_range])
        copyto!(dest[even_dest], src[even_range])
        if upto != lastindex(src)
            remainder = (upto + 1):lastindex(src)
            copyto!(dest[remainder], src[remainder])
        end
    end
    return dest
end

"""
    partition(signal, range::AbstractRange)

Split the odd- and even-indexed elements in `signal` in the range 
given by `range`, storing the odd and even elements in-place, respectively, 
then the remaining elements from `signal`, returning the result.
"""
partition(signal, range::AbstractRange) = copyto!(copy(signal), partition(view(signal, range)))

"""
    combine(signal; upto=lastindex(signal))

Return the inverse operation of `partition(signal; upto=lastindex(signal))`.
"""
combine(signal; upto=lastindex(signal)) = _combine!(copy(signal), signal; upto)

function _combine!(dest, src; upto=lastindex(src))
    pivot = ceil(Int, upto / 2)
    @views begin
        copyto!(dest[1:2:upto], src[begin:pivot])
        copyto!(dest[2:2:upto], src[(pivot + 1):upto])
        copyto!(dest[upto:end], src[upto:end])
    end
    return dest
end

"""
    combine(signal; range::AbstractRange)

Return the inverse operation of `partition(signal, range::AbstractRange)`.
"""
function combine(signal, range::AbstractRange)
    dest = copy(signal)
    src = combine(signal; upto=length(range))
    @views copyto!(dest[range], src[begin:length(range)])
    return dest
end

"""
    copyrange!(dest, src, range)

Copy a `range` of elements from `src` into `dest` and return the resulting vector.
Adapted from `Wavelets.jl`'s `stridedcopy!`.
"""
copyrange!(dest, src, range) = copyto!(dest, view(src, range))

# Notable omission: `circshift!`, which now has an implementation in Base Julia.