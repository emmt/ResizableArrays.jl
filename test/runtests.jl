module ResizableArraysTests

using Test
using ResizableArrays

@testset "Basic methods" begin
    @testset "Dimensions: $dims" for dims in ((3,), (2,3), (2,3,4))
        A = rand(dims...)
        T = eltype(A)
        N = length(dims)
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
        tmpdims = collect(size(B))
        tmpdims[end] += 1
        resize!(B, tmpdims...)
        @test maxlength(B) == length(B) == prod(tmpdims)
        @test all(i -> B[i] == A[i], 1:length(A))
    end
end

end # module
