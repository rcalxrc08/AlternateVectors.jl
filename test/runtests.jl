using AlternateVectors
using Test, Dates, ChainRulesCore, Zygote
@show "Starting tests"
using SparseArrays
@testset "AlternateVectors arithmetical operations closed" begin
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
end

@testset "arithmetical operations closed" begin
    N = 11
    av = AlternatePaddedVector(-2.0, 3.0, 2.0, 4.0, N)
    @test_throws "length of AlternatePaddedVector must be greater than 2." AlternatePaddedVector(1, 1, 1, 1, 1)
    @test_throws "Trying to getindex with an AbstractRange of length" av[1:1]
    @test av[1] == -2.0
    @test av[2] == 3.0
    @test av[3] == 2.0
    @test av[4] == 3.0
    @test av[end] == 4.0
    @show av
    Base.showarg(Core.CoreSTDOUT(), av, nothing)
    println(av)
    av_c = collect(av)
    @test typeof(av[1:2]) <: AlternatePaddedVector
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
    @test all(@. av[8:9] ≈ av_c[8:9])
    @test all(@. sin(av) ≈ sin(av_c))
    @test all(@. exp(av) + av ≈ exp(av_c) + av_c)
    @test all(@. exp(av) + av + 2 ≈ exp(av_c) + av_c + 2)
    @test all(@. exp(av) + av_c ≈ exp(av_c) + av)
    @test all(@. exp(av) + av_c ≈ exp(av_c) + av_c)
    @test all(@. exp(av) + av_c + av * av_c ≈ exp(av_c) + av_c + av * av_c)
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
end

@testset "Zygote AlternateVector" begin
    function f_av(x)
        N = 11
        av = AlternateVector(x, -8.2 * x, N)
        return sum(av)
    end
    function f_std(x)
        N = 11
        one_minus_one = ChainRulesCore.@ignore_derivatives @. ifelse(isodd(1:N), 1.0, -8.2)
        av = one_minus_one .* x
        return sum(av)
    end
    x = 3.2
    res_av = Zygote.gradient(f_av, x)
    res_std = Zygote.gradient(f_std, x)
    @test res_av[1] ≈ res_std[1]
end

@testset "Zygote AlternatePaddedVector" begin
    function f_av(x)
        N = 11
        av = AlternatePaddedVector(x, -8.2 * x, -5.6 * x, 0.2 * x, N)
        return sum(av)
    end
    function f_std(x)
        N = 11
        one_minus_one = ChainRulesCore.@ignore_derivatives @. ifelse(isodd(1:N), -5.6, -8.2)
        ChainRulesCore.@ignore_derivatives one_minus_one[1] = 1.0
        ChainRulesCore.@ignore_derivatives one_minus_one[end] = 0.2
        av = one_minus_one .* x
        return sum(av)
    end
    x = 3.2
    res_av = Zygote.gradient(f_av, x)
    res_std = Zygote.gradient(f_std, x)
    @test res_av[1] ≈ res_std[1]
end
