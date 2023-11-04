using AlternateVectors
using Test

@testset "AlternateVectors arithmetical operations closed" begin
	N=11
	av=AlternateVector(-2.0,3.0,N)
	@test av[1]==-2.0
	@test av[2]==3.0
	@test av[end]==-2.0
	println(av)
	av_c=collect(av)
	@test typeof(av[1:2])<:AlternateVector
	@test typeof(1 .+ av)<:AlternateVector
	@test typeof(av.+1)<:AlternateVector
	@test typeof(sin.(av))<:AlternateVector
	@test !(typeof(av.+tuple(ones(N)...)) <: AlternateVector)
	@test typeof(@. sin(av)*av+1+av)<:AlternateVector
	@test typeof(@. sin(av)*av+1+exp(av))<:AlternateVector
	@test typeof(@. sin(av)*av*av+1+exp(av))<:AlternateVector
	@test typeof(@. sin(cos(av))*av*av+exp(1)+exp(av))<:AlternateVector
	@test typeof(@. 2+sin(av)*av+1+exp(av))<:AlternateVector
	@test all(@. av ≈ av_c)
	@test all(@. sin(av) ≈ sin(av_c))
	@test all(@. exp(av)+av ≈ exp(av_c)+av_c)
	@test all(@. exp(av)+av_c ≈ exp(av_c)+av)
	@test all(@. exp(av)+av_c ≈ exp(av_c)+av_c)
	@test all(@. exp(av)+av_c+av*av_c ≈ exp(av_c)+av_c+av*av_c)
	@test all(@. exp(av)+av+av*av ≈ exp(av_c)+av_c+av*av_c)
	@test sum(av) ≈ sum(ac)
end



@testset "arithmetical operations closed" begin
	N=11
	av=AlternatePaddedVector(-2.0,3.0,2.0,4.0,N)
	@test_throws "length of AlternatePaddedVector must be greater than 2." AlternatePaddedVector(1,1,1,1,1)
	@test_throws "Trying to getindex with an AbstractRange of length" av[1:1]
	@test av[1]==-2.0
	@test av[2]==3.0
	@test av[3]==2.0
	@test av[4]==3.0
	@test av[end]==4.0
	println(av)
	av_c=collect(av)
	@test typeof(av[1:2])<:AlternatePaddedVector
	@test typeof(1 .+ av)<:AlternatePaddedVector
	@test typeof(av.+1)<:AlternatePaddedVector
	@test typeof(sin.(av))<:AlternatePaddedVector
	@test typeof(@. sin(av)*av+1+av)<:AlternatePaddedVector
	@test typeof(@. sin(av)*av+1+exp(av))<:AlternatePaddedVector
	@test typeof(@. sin(av)*av*av+1+exp(av))<:AlternatePaddedVector
	@test typeof(@. 2+sin(av)*av+1+exp(av))<:AlternatePaddedVector
	@test typeof(@. 2+sin(av)*av+1+log(abs(av)))<:AlternatePaddedVector
	@test typeof(@. 2+sin(cos(av))*av+1+exp(av)+exp(1))<:AlternatePaddedVector
	@test all(@. av ≈ av_c)
	@test all(@. av[1:5] ≈ av_c[1:5])
	@test all(@. av[3:2:9] ≈ av_c[3:2:9])
	@test all(@. av[8:9] ≈ av_c[8:9])
	@test all(@. sin(av) ≈ sin(av_c))
	@test all(@. exp(av)+av ≈ exp(av_c)+av_c)
	@test all(@. exp(av)+av+2 ≈ exp(av_c)+av_c+2)
	@test all(@. exp(av)+av_c ≈ exp(av_c)+av)
	@test all(@. exp(av)+av_c ≈ exp(av_c)+av_c)
	@test all(@. exp(av)+av_c+av*av_c ≈ exp(av_c)+av_c+av*av_c)
	@test all(@. exp(av)+av+av*av ≈ exp(av_c)+av_c+av*av_c)
	@test sum(av) ≈ sum(ac)
end
