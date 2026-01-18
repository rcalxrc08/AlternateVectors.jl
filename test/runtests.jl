using AlternateVectors
using Test, Dates, ChainRulesCore, Zygote, LazyArrays, SparseArrays

struct ZeroDimensionalVector{T} <: AbstractArray{T, 0}
    value::T
    function ZeroDimensionalVector(value::T) where {T}
        return new{T}(value)
    end
end

### Implementation of the array interface
Base.size(::ZeroDimensionalVector) = ()

function Base.getindex(x::ZeroDimensionalVector, ind::Int)
    throw(BoundsError(x, ind))
end
function Base.getindex(A::ZeroDimensionalVector)
    return A.value
end

# IO
Base.showarg(io::IO, A::ZeroDimensionalVector, _) = print(io, typeof(A))

# Broacasting relation against other arrays
struct ArrayStyleZeroDimVector <: Broadcast.AbstractArrayStyle{0} end
Base.BroadcastStyle(::Type{<:ZeroDimensionalVector{T}}) where {T} = ArrayStyleZeroDimVector()
Base.BroadcastStyle(::ArrayStyleZeroDimVector, b::Base.Broadcast.Style{Tuple}) = b
function Base.BroadcastStyle(::ArrayStyleZeroDimVector, b::Broadcast.AbstractArrayStyle{N}) where {N}
    return b
end
function Base.BroadcastStyle(::ArrayStyleZeroDimVector, b::Broadcast.DefaultArrayStyle{N}) where {N}
    return b
end

@testset "AlternateVectors" begin
    @test_throws "length of AlternateVector must be greater than one." AlternateVector(1, 1, 1)
    N = 11
    av = AlternateVector(-2.0, 3.0, N)
    @test av[1] == -2.0
    @test av[2] == 3.0
    @test av[end] == -2.0
    Base.showarg(Core.CoreSTDOUT(), av, nothing)
    println(av)
    @show av
    av_c = collect(av)
    @test typeof(av[1:2]) <: AlternateVector
    @test typeof(av[:]) <: AlternateVector
    @test typeof(1 .+ av) <: AlternateVector
    @test typeof(av .+ 1) <: AlternateVector
    @test typeof(sin.(av)) <: AlternateVector
    @test !(typeof(av .+ tuple(ones(N)...)) <: AlternateVector)
    @test !(typeof(tuple(ones(N)...) .+ av) <: AlternateVector)
    @test typeof(@. sin(av) * av + 1 + av) <: AlternateVector
    @test typeof(@. sin(av) * av + 1 + exp(av)) <: AlternateVector
    @test typeof(@. sin(av) * av * av + 1 + exp(av)) <: AlternateVector
    @test typeof(@. sin(cos(av)) * av * av + exp(1) + exp(av)) <: AlternateVector
    @test typeof(@. 2 + sin(av) * av + 1 + exp(av)) <: AlternateVector
    @test all(@. av ≈ av_c)
    @test all(@. sin(av) ≈ sin(av_c))
    @test all(@. exp(av) + av ≈ exp(av_c) + av_c)
    @test all(@. exp(av) + av_c ≈ exp(av_c) + av)
    @test all(@. exp(av) + av_c ≈ exp(av_c) + av_c)
    @test all(@. exp(av) + av_c + av * av_c ≈ exp(av_c) + av_c + av * av_c)
    @test all(@. exp(av) + av + av * av ≈ exp(av_c) + av_c + av * av_c)
    @test sum(av) ≈ sum(av_c)
    av_d = AlternateVector(Dates.Date(1992, 1, 1), Dates.Date(1992, 10, 1), N)
    av_d_1 = collect(av_d)
    one_day = Dates.Day(1)
    res_av_with_ref = @. av_d + one_day
    @test all(@. res_av_with_ref == av_d_1 + one_day)
    #test sparse
    sparse_p = spzeros(Float64, N)
    sparse_p[1] = 4.0
    @test typeof(sin.(av .* sparse_p)) <: typeof(sparse_p)
    #test lazy arrays
    D = LazyArray(@~ exp.(1:N))
    D_c = collect(D)
    res_mul_lazy_1 = D .* av
    res_mul_lazy_2 = av .* D
    res_mul = av_c .* D_c
    @test all(@. res_mul_lazy_1 ≈ res_mul)
    @test all(@. res_mul_lazy_2 ≈ res_mul)

    x_zero_dim = ZeroDimensionalVector(1)
    res_lazy_1_zero_dim = x_zero_dim .* av
    res_lazy_2_zero_dim = av .* x_zero_dim
    @test all(@. res_lazy_1_zero_dim ≈ res_lazy_2_zero_dim)

    x_zero_dim_r = Array{Float64, 0}(undef)
    x_zero_dim_r .= 0
    res_zero_d_r = @. x_zero_dim_r * av
    res_zero_d = @. x_zero_dim_r * av_c
    @test all(@. res_zero_d ≈ res_zero_d_r)
end

@testset "AlternatePaddedVector" begin
    N = 11
    av = AlternatePaddedVector(-2.0, 3.0, 2.0, 4.0, N)
    @test_throws "length of AlternatePaddedVector must be greater than three." AlternatePaddedVector(1, 1, 1, 1, 3)
    @test_throws "Trying to getindex with an AbstractRange of length" av[1:3]
    @test av[1] == -2.0
    @test av[2] == 3.0
    @test av[3] == 2.0
    @test av[4] == 3.0
    @test av[end] == 4.0
    @show av
    Base.showarg(Core.CoreSTDOUT(), av, nothing)
    println(av)
    av_c = collect(av)
    @test typeof(av[1:1:5]) <: AlternatePaddedVector
    @test typeof(av[:]) <: AlternatePaddedVector
    @test typeof(1 .+ av) <: AlternatePaddedVector
    @test typeof(av .+ 1) <: AlternatePaddedVector
    @test typeof(sin.(av)) <: AlternatePaddedVector
    @test typeof(@. sin(av) * av + 1 + av) <: AlternatePaddedVector
    @test typeof(@. sin(av) * av + 1 + exp(av)) <: AlternatePaddedVector
    @test typeof(@. sin(av) * av * av + 1 + exp(av)) <: AlternatePaddedVector
    @test typeof(@. 2 + sin(av) * av + 1 + exp(av)) <: AlternatePaddedVector
    @test typeof(@. 2 + sin(av) * av + 1 + log(abs(av))) <: AlternatePaddedVector
    @test typeof(@. 2 + sin(cos(av)) * av + 1 + exp(av) + exp(1)) <: AlternatePaddedVector
    @test !(typeof(av .+ tuple(ones(N)...)) <: AlternatePaddedVector)
    @test !(typeof(tuple(ones(N)...) .+ av) <: AlternateVector)
    @test all(@. av ≈ av_c)
    @test all(@. av[1:5] ≈ av_c[1:5])
    @test all(@. av[3:2:9] ≈ av_c[3:2:9])
    @test all(@. av[1:1:9] ≈ av_c[1:1:9])
    @test all(@. av[4:9] ≈ av_c[4:9])
    @test all(@. sin(av) ≈ sin(av_c))
    @test all(@. exp(av) + av ≈ exp(av_c) + av_c)
    @test all(@. exp(av) + av + 2 ≈ exp(av_c) + av_c + 2)
    @test all(@. exp(av) + av_c ≈ exp(av_c) + av)
    @test all(@. exp(av) + av_c ≈ exp(av_c) + av_c)
    @test all(@. exp(av) + av_c + av * av_c ≈ exp(av_c) + av_c + av * av_c)
    @test all(@. (exp(av) * av_c) + (av * av_c) ≈ exp(av_c) * av_c + av * av_c)
    @test all(@. exp(av) + av + av * av ≈ exp(av_c) + av_c + av * av_c)
    @test all(@. exp(av + sin(1 + av)) + av + av * av ≈ exp(av_c + sin(1 + av_c)) + av_c + av * av_c)
    @test sum(av) ≈ sum(av_c)
    av_d = AlternatePaddedVector(Dates.Date(1992, 1, 1), Dates.Date(1992, 9, 1), Dates.Date(1922, 1, 1), Dates.Date(1392, 10, 1), N)
    av_d_1 = collect(av_d)
    one_day = Dates.Day(1)
    res_av_with_ref = @. av_d + one_day
    @test all(@. res_av_with_ref == av_d_1 + one_day)
    #mixture
    av_1 = AlternateVector(-2.0, 3.0, N)
    @test typeof(av_1 .+ av) <: AlternatePaddedVector
    #test sparse
    sparse_p = spzeros(Float64, N)
    sparse_p[1] = 4.0
    @test typeof(sin.(av .* sparse_p)) <: typeof(sparse_p)

    #test lazy arrays
    D = LazyArray(@~ exp.(1:N))
    D_c = collect(D)
    res_mul_lazy_1 = D .* av
    res_mul_lazy_2 = av .* D
    res_mul = av_c .* D_c
    @test all(@. res_mul_lazy_1 ≈ res_mul)
    @test all(@. res_mul_lazy_2 ≈ res_mul)
    res_mul_lazy_1 = @. exp(av * av_c) + av * D * av * av_c + D * av
    res_mul_lazy_2 = @. exp(av_c * av_c) + av_c * D * av_c * av_c + D * av_c
    @test all(@. res_mul_lazy_1 ≈ res_mul_lazy_2)

    x_zero_dim = ZeroDimensionalVector(1)
    res_lazy_1_zero_dim = x_zero_dim .* av
    res_lazy_2_zero_dim = av .* x_zero_dim
    @test all(@. res_lazy_1_zero_dim ≈ res_lazy_2_zero_dim)
    res_lazy_1_zero_dim = @. (av_c * av) * x_zero_dim
    res_lazy_2_zero_dim = @. av_c * av * x_zero_dim
    @test all(@. res_lazy_1_zero_dim ≈ res_lazy_2_zero_dim)

    x_zero_dim_r = Array{Float64, 0}(undef)
    x_zero_dim_r .= 0
    res_zero_d_r = @. x_zero_dim_r * av
    res_zero_d = @. x_zero_dim_r * av_c
    @test all(@. res_zero_d ≈ res_zero_d_r)
end

@testset "SparseArraysExt for AlternateVector" begin
    @test_throws "length of AlternateVector must be greater than one." AlternateVector(1, 1, 1)
    N = 11
    av = AlternateVector(-2.0, 3.0, N)
    av_c = collect(av)
    #test sparse
    sparse_p = spzeros(Float64, N)
    sparse_p[1] = 4.0
    @test typeof(sin.(av .* sparse_p)) <: typeof(sparse_p)
    @test all(@. av * sparse_p ≈ av_c * sparse_p)
end

@testset "SparseArraysExt for AlternatePaddedVector" begin
    N = 11
    av = AlternatePaddedVector(-2.0, 3.0, 2.0, 4.0, N)
    av_c = collect(av)
    #test sparse
    sparse_p = spzeros(Float64, N)
    sparse_p[1] = 4.0
    @test typeof(sin.(av .* sparse_p)) <: typeof(sparse_p)
    @test all(@. av * sparse_p ≈ av_c * sparse_p)
end

@testset "Zygote AlternateVector" begin
    function f_av(x)
        N = 11
        av = AlternateVector(x, -8.2 * x, N)
        return sum(av)
    end
    function f_std_av(x)
        N = 11
        one_minus_one = ChainRulesCore.@ignore_derivatives @. ifelse(isodd(1:N), 1.0, -8.2)
        av = one_minus_one .* x
        return sum(av)
    end
    x = 3.2
    res_av = Zygote.gradient(f_av, x)
    res_std = Zygote.gradient(f_std_av, x)
    @test res_av[1] ≈ res_std[1]
end

@testset "Zygote AlternatePaddedVector" begin
    function f_av(x)
        N = 11
        av = AlternatePaddedVector(x, -8.2 * x, -5.6 * x, 0.2 * x, N)
        return sum(av)
    end
    function f_std_apv(x)
        N = 11
        one_minus_one = ChainRulesCore.@ignore_derivatives @. ifelse(isodd(1:N), -5.6, -8.2)
        ChainRulesCore.@ignore_derivatives one_minus_one[1] = 1.0
        ChainRulesCore.@ignore_derivatives one_minus_one[end] = 0.2
        av = one_minus_one .* x
        return sum(av)
    end
    x = 3.2
    res_av = Zygote.gradient(f_av, x)
    res_std = Zygote.gradient(f_std_apv, x)
    @test res_av[1] ≈ res_std[1]
end

@testset "Composite Broadcasting for AlternateVector" begin
    N = 11
    av = AlternateVector(-2.0, 4.0, N)
    global incr = 0
    function scalar_f_av(x)
        global incr += 1
        return sin(x)
    end
    res = @. scalar_f_av(av)
    @test incr == 2
    incr = 0
    av_c = collect(av)
    res = @. scalar_f_av(av) * av_c
    @test incr == 2
end

@testset "Composite Broadcasting for AlternatePaddedVector" begin
    N = 11
    av = AlternatePaddedVector(-2.0, 3.0, 2.0, 4.0, N)
    global incr = 0
    function scalar_f(x)
        global incr += 1
        return sin(x)
    end
    res = @. scalar_f(av)
    @test incr == 4
    incr = 0
    av_c = collect(av)
    res = @. scalar_f(av) * av_c
    @test incr == 4
end