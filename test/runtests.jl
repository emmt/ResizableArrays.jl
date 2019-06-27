module ResizableArraysTests

using Test
using ResizableArrays
using ResizableArrays: checkdimension, checkdimensions

@testset "Basic methods" begin
    @testset "Utilities" begin
        @test checkdimension(Bool, π) == false
        @test checkdimensions(Bool, ()) == true
        @test checkdimensions(Bool, (1,)) == true
        @test checkdimensions(Bool, (1,2,0)) == true
        @test checkdimensions(Bool, (1,-2,0)) == false
        @test_throws ErrorException checkdimensions((1,-2,0))
        @test isgrowable(π) == false
        @test isgrowable((1,2,3)) == false
        @test isgrowable([1,2,3]) == true
    end
    @testset "Dimensions: $dims" for dims in ((), (3,), (2,3), (2,3,4))
        N = length(dims)
        if N > 0
            A = rand(dims...)
            T = eltype(A)
        else
            T = Float64
            A = Array{T}(undef, dims)
            A[1] = rand(dims...)
        end
        B = ResizableArray{T}(undef, size(A))
        @test IndexStyle(typeof(B)) == IndexLinear()
        @test eltype(B) == eltype(A)
        @test ndims(B) == ndims(A) == N
        @test size(B) == size(A)
        @test all(d -> size(B,d) == size(A,d), 1:(N+2))
        @test axes(B) == axes(A)
        @test length(B) == length(A) == prod(dims)
        @test maxlength(B) == length(B)
        @test all(d -> axes(B,d) == axes(A,d), 1:(N+2))
        copyto!(B, A)
        @test all(i -> A[i] == B[i], 1:length(A))
        @test all(i -> A[i] == B[i], CartesianIndices(A))
        @test all(i -> A[i] == B.vals[i], 1:length(A))
        for i in eachindex(B)
            B[i] = rand()
        end
        copyto!(A, B)
        @test all(i -> A[i] == B[i], 1:length(A))
        @test all(i -> A[i] == B[i], CartesianIndices(A))
        @test all(i -> A[i] == B.vals[i], 1:length(A))
        if N > 0
            tmpdims = collect(size(B))
            tmpdims[end] += 1
            resize!(B, tmpdims...)
            @test maxlength(B) == length(B) == prod(tmpdims)
            @test all(i -> B[i] == A[i], 1:length(A))
        end
        @test_throws BoundsError B[0]
        @test_throws BoundsError B[length(B) + 1]
        @test_throws ErrorException resize!(B, (dims..., 5))

        # Use a custom buffer.
        C = ResizableArray(Vector{T}(undef, length(A)), size(A))
        @test eltype(C) == eltype(A)
        @test ndims(C) == ndims(A) == N
        @test size(C) == size(A)
        @test all(d -> size(C,d) == size(A,d), 1:(N+2))
        @test axes(C) == axes(A)
        @test length(C) == length(A) == prod(dims)
        @test maxlength(C) == length(C)
        @test all(d -> axes(C,d) == axes(A,d), 1:(N+2))
        D = ResizableArray{T,N}(Vector{T}(undef, length(A)), size(A)...)
        @test eltype(D) == eltype(A)
        @test ndims(D) == ndims(A) == N
        @test size(D) == size(A)
        @test all(d -> size(D,d) == size(A,d), 1:(N+2))
        @test axes(D) == axes(A)
        @test length(D) == length(A) == prod(dims)
        @test maxlength(D) == length(D)
        @test all(d -> axes(D,d) == axes(A,d), 1:(N+2))

        # Use constructor to convert array.
        E = ResizableArray(A)
        @test eltype(E) == eltype(A)
        @test ndims(E) == ndims(A) == N
        @test size(E) == size(A)
        @test all(d -> size(E,d) == size(A,d), 1:(N+2))
        @test axes(E) == axes(A)
        @test length(E) == length(A) == prod(dims)
        @test maxlength(E) == length(E)
        @test all(d -> axes(E,d) == axes(A,d), 1:(N+2))
        @test all(i -> A[i] == E[i], 1:length(A))
        @test all(i -> A[i] == E[i], CartesianIndices(A))
        F = ResizableArray{T}(A)
        @test eltype(F) == eltype(A)
        @test ndims(F) == ndims(A) == N
        @test size(F) == size(A)
        @test all(d -> size(F,d) == size(A,d), 1:(N+2))
        @test axes(F) == axes(A)
        @test length(F) == length(A) == prod(dims)
        @test maxlength(F) == length(F)
        @test all(d -> axes(F,d) == axes(A,d), 1:(N+2))
        @test all(i -> A[i] == F[i], 1:length(A))
        @test all(i -> A[i] == F[i], CartesianIndices(A))
        G = ResizableArray{T,N}(A)
        @test eltype(G) == eltype(A)
        @test ndims(G) == ndims(A) == N
        @test size(G) == size(A)
        @test all(d -> size(G,d) == size(A,d), 1:(N+2))
        @test axes(G) == axes(A)
        @test length(G) == length(A) == prod(dims)
        @test maxlength(G) == length(G)
        @test all(d -> axes(G,d) == axes(A,d), 1:(N+2))
        @test all(i -> A[i] == G[i], 1:length(A))
        @test all(i -> A[i] == G[i], CartesianIndices(A))

        # Use convert to convert array.
        E = convert(ResizableArray, A)
        @test eltype(E) == eltype(A)
        @test ndims(E) == ndims(A) == N
        @test size(E) == size(A)
        @test all(d -> size(E,d) == size(A,d), 1:(N+2))
        @test axes(E) == axes(A)
        @test length(E) == length(A) == prod(dims)
        @test maxlength(E) == length(E)
        @test all(d -> axes(E,d) == axes(A,d), 1:(N+2))
        @test all(i -> A[i] == E[i], 1:length(A))
        @test all(i -> A[i] == E[i], CartesianIndices(A))
        F =convert(ResizableArray{T}, A)
        @test eltype(F) == eltype(A)
        @test ndims(F) == ndims(A) == N
        @test size(F) == size(A)
        @test all(d -> size(F,d) == size(A,d), 1:(N+2))
        @test axes(F) == axes(A)
        @test length(F) == length(A) == prod(dims)
        @test maxlength(F) == length(F)
        @test all(d -> axes(F,d) == axes(A,d), 1:(N+2))
        @test all(i -> A[i] == F[i], 1:length(A))
        @test all(i -> A[i] == F[i], CartesianIndices(A))
        G = convert(ResizableArray{T,N}, A)
        @test eltype(G) == eltype(A)
        @test ndims(G) == ndims(A) == N
        @test size(G) == size(A)
        @test all(d -> size(G,d) == size(A,d), 1:(N+2))
        @test axes(G) == axes(A)
        @test length(G) == length(A) == prod(dims)
        @test maxlength(G) == length(G)
        @test all(d -> axes(G,d) == axes(A,d), 1:(N+2))
        @test all(i -> A[i] == G[i], 1:length(A))
        @test all(i -> A[i] == G[i], CartesianIndices(A))
    end
end

end # module
