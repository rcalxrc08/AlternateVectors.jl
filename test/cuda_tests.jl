using AlternateVectors
using Test, Dates, ChainRulesCore, Zygote, CUDA
CUDA.allowscalar(false)
@show "Starting CUDA tests"

@testset "CUDA AV" begin
    N = 11
    av = AlternateVector(-2.0, 3.0, N)
    av_cpu = collect(av)
    av_gpu = cu(av_cpu)
    res_av = collect(@. av * av_gpu)
    res_av_gpu = collect(@. av_gpu * av_gpu)
    @test all(@. res_av ≈ res_av_gpu)
    res_av = collect(@. muladd(av, av, av_gpu))
    res_av_gpu = collect(@. muladd(av_gpu, av_gpu, av_gpu))
    @test all(@. res_av ≈ res_av_gpu)

    res_av = collect(@. muladd(av, 3.0, av_gpu))
    res_av_gpu = collect(@. muladd(av_gpu, 3.0, av_gpu))
    @test all(@. res_av ≈ res_av_gpu)
end

@testset "CUDA APV" begin
    N = 11
    av = AlternatePaddedVector(-2.0, 1.0, 50.0, 3.0, N)
    av_cpu = collect(av)
    av_gpu = cu(av_cpu)
    res_av = collect(@. av * av_gpu)
    res_av_gpu = collect(@. av_gpu * av_gpu)
    @test all(@. res_av ≈ res_av_gpu)
    res_av = collect(@. muladd(av, av, av_gpu))
    res_av_gpu = collect(@. muladd(av_gpu, av_gpu, av_gpu))
    @test all(@. res_av ≈ res_av_gpu)

    res_av = collect(@. muladd(av, 3.0, av_gpu))
    res_av_gpu = collect(@. muladd(av_gpu, 3.0, av_gpu))
    @test all(@. res_av ≈ res_av_gpu)
end