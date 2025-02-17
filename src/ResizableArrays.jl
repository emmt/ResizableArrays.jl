"""

Package `ResizableArrays` provides arrays which are resizable.

"""
module ResizableArrays

export
    ResizableArray,
    ResizableMatrix,
    ResizableVector,
    isgrowable,
    maxlength,
    grow!,
    shrink!

using TypeUtils
using Base: elsize, tail, throw_boundserror, @propagate_inbounds

"""
    ResizableArray{T}(undef, dims...)

yields a resizable array with un-initialized elements of type `T` and dimensions
`dims...`. Dimensions may be a tuple of integers or a a list of integers. The number `N`
of dimensions may be explicitly specified:

    ResizableArray{T,N}(undef, dims...)

To create an empty resizable array of given rank and element type, call:

    ResizableArray{T,N}()

The dimensions of a resizable array `A` may be changed by calling `resize!(A,dims)` with
`dims` the new dimensions. The number of dimensions must remain unchanged but the length
of the array may change. Depending on the type of the object backing the storage of the
array, it may be possible or not to augment the number of elements of the array. When
array elements are stored in a regular Julia vector, the number of element can always be
augmented. Changing only the last dimension of a resizable array preserves its contents.

Resizable arrays are designed to re-use storage if possible to avoid calling the garbage
collector. This may be useful for real-time applications. As a consequence, the storage
used by a resizable array `A` can only grow unless `shrink!(A)` is called to reduce the
storage to the minimum. The call `copy(ResizableArray,A)` yields a copy of `A` which is a
resizable array.

To improve performances, call `sizehint!(A,n)` to indicate the minimum number of elements
to preallocate for `A` (`n` can be a number of elements or array dimensions).

The `ResizableArray` constructor and the `convert` method can be used to convert an array
`A` to a resizable array:

    ResizableArray(A)
    convert(ResizableArray, A)

If possible, the `convert` method returns the input array while the `ResizableArray`
constructor always returns a new instance. Element type `T` and number of dimensions `N`
may be specified:

    ResizableArray{T[,N]}(A)
    convert(ResizableArray{T[,N]}, A)

`N` must match `ndims(A)` but `T` may be different from `eltype(A)`.

By default, the storage for the elements of a resizable array is provided by a regular
Julia vector. To use an object `buf` to store the elements of a resizable array, use one
of the following:

    A = ResizableArray(buf, dims)
    A = ResizableArray{T}(buf, dims)
    A = ResizableArray{T,N}(buf, dims)

The buffer `buf` must store its elements contiguously using linear indexing style with
1-based indices and have element type `T`, that is `IndexStyle(typeof(buf))` and
`eltype(buf)` must yield `IndexLinear()` and `T` respectively. The methods, `IndexStyle`,
`eltype`, `length`, `getindex` and `setindex!` must be applicable for the type of `buf`.
If the method `resize!` is applicable for `buf`, the number of elements of `A` can be
augmented; otherwise the maximum number of elements of `A` is `length(buf)`.

!!! warning
    When explicitly providing a resizable buffer `buf` for backing the storage of a
    resizable array `A`, it is the caller responsibility to make sure that the same
    buffer is not resized elsewhere. Otherwise a segmentation fault may occur because `A`
    might assume a wrong buffer size. To avoid this, the best is to make sure that only
    `A` owns `buf` and only `A` manages its size. In the current implementation, the size
    of the internal buffer is never automatically reduced so the same buffer may be
    safely shared by different resizable arrays.

"""
mutable struct ResizableArray{T,N,B} <: DenseArray{T,N}
    len::Int
    dims::Dims{N}
    vals::B
    # Inner constructor for provided storage buffer.
    function ResizableArray{T,N}(buf::B, dims::Dims{N}) where {T,N,B}
        eltype(B) === T || throw(ArgumentError("storage buffer has a different element type"))
        IndexStyle(B) === IndexLinear() || throw(ArgumentError("storage buffer must have linear indexing style"))
        len = checksize(dims)
        length(buf) ≥ len || throw(DimensionMismatch("storage buffer is too small"))
        return new{T,N,B}(len, dims, buf)
    end
    # Inner constructor using regular Julia's vector to store elements.
    function ResizableArray{T,N}(::UndefInitializer, dims::Dims{N}) where {T,N}
        len = checksize(dims)
        buf = Vector{T}(undef, len)
        return new{T,N,typeof(buf)}(len, dims, buf)
    end

end

# Accessors.
storage(A::ResizableArray) = getfield(A, :vals)
Base.length(A::ResizableArray) = getfield(A, :len)
Base.size(A::ResizableArray) = getfield(A, :dims)

# Calling the `ResizableArray` constructor always creates a new instance.

ResizableArray(buf, dims::Integer...) = ResizableArray(buf, dims)
ResizableArray(buf, dims::NTuple{N,Integer}) where {N} = ResizableArray{eltype(buf),N}(buf, dims)

ResizableArray{T}(buf, dims::Integer...) where {T} = ResizableArray{T}(buf, dims)
ResizableArray{T}(buf, dims::NTuple{N,Integer}) where {T,N} = ResizableArray{T,N}(buf, dims)

ResizableArray{T,N}(buf, dims::Integer...) where {T,N} = ResizableArray{T,N}(buf, dims)
ResizableArray{T,N}(buf, dims::NTuple{N,Integer}) where {T,N} = ResizableArray{T,N}(buf, map(Int, dims))
ResizableArray{T,N}(buf, dims::Dims{M}) where {T,N,M} = throw_mismatching_number_of_dimensions()

ResizableArray(A::AbstractArray) = ResizableArray{eltype(A)}(A)
ResizableArray{T}(A::AbstractArray) where {T} = copyto!(ResizableArray{T}(undef, size(A)), A)
ResizableArray{T,N}(A::AbstractArray{<:Any,N}) where {T,N} = ResizableArray{T}(A)
ResizableArray{T,N}(A::AbstractArray{<:Any,M}) where {T,N,M} = throw_mismatching_number_of_dimensions()
ResizableArray{T,N,B}(A::AbstractArray) where {T,N,B} =
    Vector{T} <: B ? ResizableArray{T,N}(A) : throw(ErrorException("invalid buffer type $B (must be ≥ Vector{$T})"))

# Constructor for, initially empty, workspace of given rank and element type.
ResizableArray{T,N}() where {T,N} = ResizableArray{T,N}(undef, ntuple(i -> 0, Val(N)))

@noinline throw_mismatching_number_of_dimensions() =
    throw(DimensionMismatch("mismatching number of dimensions"))

# Make a resizable copy.
Base.copy(::Type{T}, A::AbstractArray) where {T<:ResizableArray} = T(A)

# Unlike the `ResizableArray` constructor, calling the `convert` method avoids
# creating a new instance if possible.
Base.convert(::Type{ResizableArray{T,N,B}}, A::ResizableArray{T,N,C}) where {T,N,B,C<:B} = A
Base.convert(::Type{ResizableArray{T,N}}, A::ResizableArray{T,N}) where {T,N} = A
Base.convert(::Type{ResizableArray{T}}, A::ResizableArray{T}) where {T} = A
Base.convert(::Type{ResizableArray}, A::ResizableArray) = A
Base.convert(::Type{T}, A::AbstractArray) where {T<:ResizableArray} = T(A)

"""
    ResizableVector{T}

is the supertype of one-dimensional resizable arrays with elements of type `T`. Alias for
[`ResizableArray{T,1}`](@ref).

"""
const ResizableVector{T,B} = ResizableArray{T,1,B}
ResizableVector(A::AbstractArray{T}) where {T} = ResizableVector{T}(A)

"""
    ResizableMatrix{T}

is the supertype of two-dimensional resizable arrays with elements of type `T`. Alias for
[`ResizableArray{T,2}`](@ref).

"""
const ResizableMatrix{T,B} = ResizableArray{T,2,B}
ResizableMatrix(A::AbstractArray{T}) where {T} = ResizableMatrix{T}(A)

"""
    ResizableArrays.checksize(dims) -> len

yields the number of elements of an array of size `dims` throwing an error if any
dimension is invalid.

"""
function checksize(dims::Dims{N}) where {N}
    len = 1
    @inbounds for i in 1:N
        dim = dims[i]
        dim ≥ 0 || throw(ArgumentError("dimensions must be ≥ 0, got `dims[$i] = $dim`"))
        len *= dim
    end
    return len
end

"""
    isgrowable(x) -> boolean

yields whether `x` is a growable object, that is its size can be augmented.

"""
isgrowable(A::ResizableArray) = isgrowable(storage(A))
isgrowable(A::ResizableArray{T,0}) where {T} = false
isgrowable(::Vector) = true
isgrowable(::Any) = false

"""
    maxlength(A)

yields the maximum number of elements which can be stored in resizable array
`A` without resizing its internal buffer.

See also: [`ResizableArray`](@ref).

"""
maxlength(A::ResizableArray) = length(storage(A))

# Array interface.
Base.size(A::ResizableArray{T,N}, d::Integer) where {T,N} =
    (d > N ? 1 : d ≥ 1 ? size(A)[d] : error("out of range dimension"))
Base.axes(A::ResizableArray) = map(Base.OneTo, size(A))
Base.axes(A::ResizableArray, d::Integer) = Base.OneTo(size(A, d))
Base.axes1(A::ResizableArray{<:Any,0}) = Base.OneTo(1)
Base.axes1(A::ResizableArray) = Base.OneTo(size(A, 1))
Base.IndexStyle(::Type{<:ResizableArray}) = IndexLinear()
Base.parent(A::ResizableArray) = storage(A)
Base.similar(::Type{ResizableArray{T}}, dims::Dims{N}) where {T,N} =
    ResizableArray{T,N}(undef, dims)

# Make sizeof() return the number of bytes of the actual contents.
Base.elsize(::Type{ResizableArray{T,N,B}}) where {T,N,B} = elsize(B)
Base.sizeof(A::ResizableArray) = elsize(A)*length(A)

# Make ResizableArray's efficient iterators.
@inline Base.iterate(A::ResizableArray, i::Int = 1) =
    ((i % UInt) - 1 < length(A) ? (@inbounds A[i], i + 1) : nothing)

Base.resize!(A::ResizableArray, dims::Integer...) = resize!(A, dims)
function Base.resize!(A::ResizableArray{T,L}, dims::NTuple{N,Integer}) where {T,L,N}
    N == L || error("changing the number of dimensions is not allowed")
    return resize!(A, as_array_size(dims))
end
function Base.resize!(A::ResizableArray{T,N}, dims::Dims{N}) where {T,N}
    if dims != size(A)
        newlen = checksize(dims)
        newlen > length(storage(A)) && resize!(storage(A), newlen)
        setfield!(A, :dims, dims)
        setfield!(A, :len, newlen)
    end
    return A
end

Base.sizehint!(A::ResizableArray, dims::Integer...) = sizehint!(A, dims)
function Base.sizehint!(A::ResizableArray{T,L}, dims::NTuple{N,Integer}) where {T,L,N}
    N == L || error("changing the number of dimensions is not allowed")
    return sizehint!(A, as_array_size(dims))
end
function Base.sizehint!(A::ResizableArray{T,N},
                        dims::Dims{N}) where {T,N}
    len = checksize(dims)
    len > maxlength(A) && sizehint!(parent(A), len)
    return A
end
Base.sizehint!(A::ResizableArray, len::Integer) = sizehint!(A, Int(len))
function Base.sizehint!(A::ResizableArray, len::Int)
    len ≥ 0 || throw(ArgumentError("number of elements must be ≥ 0, got $len"))
    len > maxlength(A) && sizehint!(parent(A), len)
    return A
end

"""
    shrink!(A) -> A

shrinks as much as possible the storage of resizable array `A` and returns `A`. Call
`copy(ResizableArray,A)` to make a copy of `A` which is a resizable array with shrunk
storage.

"""
function shrink!(A::ResizableArray)
    length(A) < length(storage(A)) && resize!(storage(A), length(A))
    return A
end

"""
    grow!(A, B, prepend=false) -> A

grows resizable array `A` with the elements of `B` and returns `A`. If `prepend` is
`true`, the elements of `B` are inserted before those of `A`; otherwise, the elements of
`B` are appended after those of `A`. By default, `prepend` is `false`.

Assuming `A` has `N` dimensions, array `B` may have `N` or `N-1` dimensions. The `N-1`
leading dimensions of `A` and `B` must be identical and are the leading dimensions of the
result. If `B` has the same number of dimensions as `A`, the last dimension of the result
is the sum of the last dimensions of `A` and `B`; otherwise, the last dimension of the
result is one plus the last dimension of `A`.

Depending on argument `prepend`, calling the `grow!` method is equivalent to calling
`append!` or `prepend!` methods.

See also [`ResizableArray`](@ref).

"""
function grow!(A::ResizableArray{<:Any,N},
               B::AbstractArray{<:Any,M}, prepend::Bool=false) where {N,M}
    N - 1 ≤ M ≤ N || throw(DimensionMismatch("invalid number of dimensions"))
    indA = axes(A)
    indB = axes(B)
    @inbounds for d in 1:N-1
        indA[d] == indB[d] ||
            throw(DimensionMismatch("leading dimensions must be identical"))
    end
    dimN = length(indA[N]) + (M == N ? length(indB[N]) : 1)
    lenA = length(A)
    lenB = length(B)
    minlen = lenA + lenB
    buf = storage(A)
    length(buf) ≥ minlen || resize!(buf, minlen)
    if prepend
        copyto!(buf, lenB + 1, buf, 1, lenA)
        copyto!(buf, 1, B, 1, lenB)
    else
        copyto!(buf, lenA + 1, B, 1, lenB)
    end
    setfield!(A, :len, lenA + lenB)
    setfield!(A, :dims, ntuple(d -> (d < N ? size(A,d) : dimN), Val(N)))
    return A
end

Base.append!(dst::ResizableArray, src::AbstractArray) =
    grow!(dst, src, false)

Base.prepend!(dst::ResizableArray, src::AbstractArray) =
    grow!(dst, src, true)

@inline Base.getindex(A::ResizableArray, i::Int) = begin
    @boundscheck checkbounds(A, i)
    @inbounds r = storage(A)[i]
    return r
end

@inline Base.setindex!(A::ResizableArray, x, i::Int) = begin
    @boundscheck checkbounds(A, i)
    @inbounds storage(A)[i] = x
    return A
end

@inline Base.checkbounds(::Type{Bool}, A::ResizableArray, i::Int) =
    (i % UInt) - 1 < length(A)

Base.copyto!(dst::ResizableArray{T}, src::Array{T}) where {T} =
    copyto!(dst, 1, src, 1, length(src))
Base.copyto!(dst::Array{T}, src::ResizableArray{T}) where {T} =
    copyto!(dst, 1, src, 1, length(src))
Base.copyto!(dst::ResizableArray{T}, src::ResizableArray{T}) where {T} =
    copyto!(dst, 1, src, 1, length(src))

function Base.copyto!(dst::ResizableArray{T}, doff::Integer,
                      src::Array{T}, soff::Integer, n::Integer) where {T}
    if n != 0
        checkcopyto(length(dst), doff, length(src), soff, n)
        unsafe_copyto!(storage(dst), doff, src, soff, n)
    end
    return dst
end

function Base.copyto!(dst::Array{T}, doff::Integer,
                      src::ResizableArray{T}, soff::Integer,
                      n::Integer) where {T}
    if n != 0
        checkcopyto(length(dst), doff, length(src), soff, n)
        unsafe_copyto!(dst, doff, storage(src), soff, n)
    end
    return dst
end

function Base.copyto!(dst::ResizableArray{T}, doff::Integer,
                      src::ResizableArray{T}, soff::Integer,
                      n::Integer) where {T}
    if n != 0
        checkcopyto(length(dst), doff, length(src), soff, n)
        unsafe_copyto!(storage(dst), doff, storage(src), soff, n)
    end
    return dst
end

@inline function checkcopyto(dlen::Integer, doff::Integer,
                             slen::Integer, soff::Integer, n::Integer)
     @noinline throw_invalid_length() =
        throw(ArgumentError("number of elements to copy must be nonnegative"))
    n ≥ 0 || throw_invalid_length()
    (doff > 0 && doff - 1 + n ≤ dlen &&
     soff > 0 && soff - 1 + n ≤ slen) || throw(BoundsError())
end

# It is sufficient to extend `unsafe_convert` method with the following
# signature to get a qualified pointer to the base address of the storage
# buffer.
Base.unsafe_convert(::Type{Ptr{T}}, A::ResizableArray{T}) where {T} =
    Base.unsafe_convert(Ptr{T}, storage(A))

end # module
