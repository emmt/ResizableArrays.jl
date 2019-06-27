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
        @test eltype(B) == eltype(A)
        @test ndims(B) == ndims(A) == N
        @test size(B) == size(A)
        @test all(d -> size(B,d) == size(A,d), 1:(N+2))
        @test axes(B) == axes(A)
        @test length(B) == length(A) == prod(dims)
        @test maxlength(B) == length(B)
        @test all(d -> axes(B,d) == axes(A,d), 1:(N+2))
        copyto!(B, A)
        @test all(i -> B[i] == A[i], 1:length(A))
        if N > 0
            tmpdims = collect(size(B))
            tmpdims[end] += 1
            resize!(B, tmpdims...)
            @test maxlength(B) == length(B) == prod(tmpdims)
            @test all(i -> B[i] == A[i], 1:length(A))
        end
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
        D = ResizableArray{T,N}(Vector{T}(undef, length(A)), size(A))
        @test eltype(D) == eltype(A)
        @test ndims(D) == ndims(A) == N
        @test size(D) == size(A)
        @test all(d -> size(D,d) == size(A,d), 1:(N+2))
        @test axes(D) == axes(A)
        @test length(D) == length(A) == prod(dims)
        @test maxlength(D) == length(D)
        @test all(d -> axes(D,d) == axes(A,d), 1:(N+2))
    end
end

end # module
