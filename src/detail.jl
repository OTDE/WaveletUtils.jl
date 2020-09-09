export
    detailindex, detailrange, degree, 
    scales, scalerange, levelmax, overlaplevelmax, 
    dyadiclevelmax, todyadiclevel, hasdyadicfactor, isdyadic

#####
##### Detail and scale coefficient utilities
#####

"""
    detailindex(size, level, offset)

Return the detail coefficient for a `size`-length signal at `level` with `offset`. 
"""
detailindex(size, level, offset) = round(Int, (size / degree(level)) + offset)

"""
    detailindex(signal::AbstractArray, level, offset)

Return the detail coefficient for `signal` at `level` with `offset`. 
"""
detailindex(signal::AbstractArray, level, offset) = detailindex(first(size(signal)), level, offset)

"""
    detailindex(level, offset)

Return the detail coefficient for a dyadic signal at `level` with `offset`. 
"""
detailindex(level, offset) = degree(level) + offset

"""
    detailrange(size::T, level::U) where {T<:Integer,U<:Integer}

Return the range of possible detail coefficients for
a `size`-length signal at `level`.
"""
function detailrange(size, level)
    lo = round(Int, size / degree(level) + one(level))
    hi = round(Int, size / degree(level - one(level)))
    return lo:hi
end

"""
    detailrange(signal::AbstractArray, level)

Return the range of possible detail coefficients for 
the first dimension of a `signal` at `level`.
"""
detailrange(signal::AbstractArray, level) = detailrange(first(size(signal)), level)

"""
    detailrange(level)

Return the range of detail coefficients for a dyadic signal at a given `level`.
"""
detailrange(level) = (degree(level) + one(level)):(degree(level + one(level)))

"""
    degree(size, level)

Return the number of detail coefficients for
a `size`-length signal at `level`.
"""
degree(size, level) = round(Int, size / degree(level))

"""
    degree(signal::AbstractArray, level)

Return the number of detail coefficients for
the first dimension of a `signal` at `level`.
"""
degree(signal::AbstractArray, level) = degree(first(size(signal)), level)

"""
    degree(level)

Return the number of detail coefficients for a dyadic signal at a given `level`.
"""
degree(level) = one(level) << level

"""
    scales(signal::AbstractArray)

Return the number of scales in the first dimension of a dyadic `signal`.
"""
scales(signal::AbstractArray) = scales(first(size(signal)))

"""
    scales(level::Integer)

Return the number of scales for a dyadic signal at `level`.
"""
scales(level::Integer) = round(Int, log2(level))

"""
    scalerange(level)

Return the range of scaling coefficients for a dyadic signal at a given `level`.
"""
scalerange(level) = one(level):degree(level)

#####
##### Transformation level utilities
#####

"""
    levelmax(size)

Return the largest possible number of transformations 
that can be performed on a `size`-length signal.
"""
function levelmax(size)
    size > 1 || return 0
    for power in Iterators.countfrom()
        hasdyadicfactor(size, power) || return power - 1
    end
end

"""
    levelmax(signal::AbstractArray)

Return the largest possible transformation level along the smallest axis of a `signal`.
"""
levelmax(signal::AbstractArray) = levelmax(minimum(size(signal)))

"""
    overlap_level_maximum(signal::AbstractArray)

Return the largest possible transformation level of a `signal`
when performing a maximal overlap transform.
"""
overlaplevelmax(signal::AbstractArray) = overlaplevelmax(length(signal))

"""
    overlap_level_maximum(size)

Return the largest possible transformation level of a 
`size`-length signal when performing a maximal overlap transform.
"""
overlaplevelmax(size) = floor(Int, log2(size))

"""
    dyadiclevelmax(signal::AbstractArray)

Return the largest possible transformation level for a dyadic `signal`.
"""
dyadiclevelmax(signal::AbstractArray) = dyadiclevelmax(first(size(signal)))

"""
    dyadiclevelmax(size::Integer)

Return the largest possible transformation level for a dyadic `size`-length signal.
"""
dyadiclevelmax(size::Integer) = scales(size) - one(size)

"""
    todyadiclevel(size, level) 

Given a `size`-length signal, return the corresponding
number of scales for a dyadic signal at `level`.
"""
todyadiclevel(size, level) = scales(size) - level

"""
    todyadiclevel(signal::AbstractArray, level) 

Given a `signal`, return the corresponding
number of scales for a dyadic signal at `level`.
"""
todyadiclevel(signal::AbstractArray, level) = todyadiclevel(length(signal), level)

#####
##### Dyadic utilities
#####

"""
    isdyadic(signal::AbstractArray)

Return `true` if all dimensions of a `signal` are dyadic.
"""
isdyadic(signal::AbstractArray) = all(isdyadic, size(signal))

"""
    isdyadic(size::T) where {T<:Integer}

Return `true` if a `size`-length signal is a power of two.
"""
isdyadic(size) = size == one(size) << scales(size)

"""
    hasdyadicfactor(signal::AbstractArray, power)

Return `true` if all dimensions of a `signal` are multiples of the `level`-th power of two.
"""
hasdyadicfactor(signal::AbstractArray, power) = all(hasdyadicfactor(axis, power) for axis in size(signal))

"""
    hasdyadicfactor(size, power)

Return `true` if `size` is a multiple of the `level`-th power of two.
"""
hasdyadicfactor(size, power) = iszero(size % degree(power))
