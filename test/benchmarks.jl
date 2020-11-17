module ResizableArraysBenchmarks

using ResizableArrays
using BenchmarkTools
using Printf

# Fill array using linear indices.
function myfill!(::IndexLinear, A::AbstractArray{T}, val) where {T}
    x = convert(T, val)
    @inbounds @simd for i in 1:length(A)
        A[i] = x
    end
    return A
end

# Fill array using Cartesian indices.
function myfill!(::IndexCartesian, A::AbstractArray{T}, val) where {T}
    x = convert(T, val)
    @inbounds @simd for i in CartesianIndices(A)
        A[i] = x
    end
    return A
end

# Copy arrays using linear indices.
function mycopyto!(::IndexLinear,
                   dst::AbstractArray{Td,N},
                   src::AbstractArray{Ts,N}) where {Td,Ts,N}
    @assert length(src) == length(dst)
    @inbounds @simd for i in 1:length(dst)
        dst[i] = src[i]
    end
    return dst
end

# Copy arrays using Cartesian indices.
function mycopyto!(::IndexCartesian,
                   dst::AbstractArray{Td,N},
                   src::AbstractArray{Ts,N}) where {Td,Ts,N}
    @assert axes(src) == axes(dst)
    @inbounds @simd for i in CartesianIndices(dst)
        dst[i] = src[i]
    end
    return dst
end

if false
A = rand(5,10,20)
T = eltype(A)
B = ResizableArray{T}(undef, size(A))
C = similar(A)
D = ResizableArray{T}(undef, size(A))
copyto!(C, A)
copyto!(B, A)
copyto!(D, B)
println("**********")
@printf("All arrays have %d elements.\n", length(A))
println("**********")

@printf("copyto!          Array -> Array ........................")
@btime copyto!($C, $A)
@printf("copyto!          Array -> ResizableArray ...............")
@btime copyto!($B, $A)
@printf("copyto! ResizableArray -> Array ........................")
@btime copyto!($A, $B)
@printf("copyto! ResizableArray -> ResizableArray ...............")
@btime copyto!($D, $B)
println()
# FIXME: using Cartesian indices here is catastrophic!
@printf("mycopyto! Cartesian          Array -> Array ............")
@btime mycopyto!(IndexCartesian(), $C, $A)
@printf("mycopyto! Cartesian          Array -> ResizableArray ...")
@btime mycopyto!(IndexCartesian(), $B,$A)
@printf("mycopyto! Cartesian ResizableArray -> Array ............")
@btime mycopyto!(IndexCartesian(), $A,$B)
@printf("mycopyto! Cartesian ResizableArray -> ResizableArray ...")
@btime mycopyto!(IndexCartesian(), $D,$B)
println()
@printf("fill! Array ............................................")
@btime fill!($A, π)
@printf("fill! ResizableArray ...................................")
@btime fill!($B, π)
println()
@printf("myfill! Linear Array ...................................")
@btime myfill!(IndexLinear(), $A, π)
@printf("myfill! Linear ResizableArray ..........................")
@btime myfill!(IndexLinear(), $B, π)
println()
@printf("myfill! Cartesian Array ................................")
@btime myfill!(IndexCartesian(), $A, π)
@printf("myfill! Cartesian ResizableArray .......................")
@btime myfill!(IndexCartesian(), $B, π)

end # if false

function repeat_v1(v::Vector{T}, n::Int) where {T}
    r = ResizableArray{T,2}(undef, length(v),0)
    for i in 1:n
        append!(r, v)
    end
    return r
end

function repeat_v2(v::Vector{T}, n::Int) where {T}
    len = length(v)
    r = sizehint!(ResizableArray{T,2}(undef, len, 0), len*n)
    for i in 1:n
        append!(r, v)
    end
    return r
end
v = [1,2,3,4,5]
println()
@printf("append! without sizehint! ...")
@btime repeat_v1($v, 50);
@printf("append! with sizehint! ......")
@btime repeat_v2($v, 50);

sum_v1(iter::AbstractArray) = (s = zero(eltype(iter));
                               for x in iter; s += x; end;
                               return s)
sum_v2(iter::AbstractArray) = (s = zero(eltype(iter));
                               @inbounds for x in iter; s += x; end;
                               return s)
sum_v3(iter::AbstractArray) = (s = zero(eltype(iter));
                               @inbounds @simd for x in iter; s += x; end;
                               return s)

A = randn(1000)
B = ResizableArray(A)
println()
@printf("sum(::Array) ...................................")
@btime sum($A);
@printf("sum(::ResizableArray) ..........................")
@btime sum($B);
@printf("sum(::Array)          with bound checking ......")
@btime sum_v1($A);
@printf("sum(::ResizableArray) with bound checking ......")
@btime sum_v1($B);
@printf("sum(::Array)          without bound checking ...")
@btime sum_v2($A);
@printf("sum(::ResizableArray) without bound checking ...")
@btime sum_v2($B);
@printf("sum(::Array)          with SIMD ................")
@btime sum_v3($A);
@printf("sum(::ResizableArray) with SIMD ................")
@btime sum_v3($B);

end # module
