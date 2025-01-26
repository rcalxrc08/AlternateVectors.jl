# This file was generated, do not modify it. # hide
using AlternateVectors, BenchmarkTools, LinearAlgebra
n=10_000
function f_std_scalar(f_x)
	N=length(f_x)
	sum_z=zero(eltype(f_x))
	for i in 1:N
		w=ifelse(isodd(i),1,-1)
		sum_z+=@views @inbounds w*f_x[i]
	end
	return sum_z
end

function f_std_scalar_2(f_x)
	N=length(f_x)
	sum_z=zero(eltype(f_x))
	for i in 1:N
		if(isodd(i))
			sum_z+=@views @inbounds f_x[i]
		else
			sum_z-=@views @inbounds f_x[i]
		end
	end
	return sum_z
end

function f_std_vec(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(isodd(idx),1,-1)
	return sum(W.*f_x)
end

function f_std_vec_linear_algebra(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(isodd(idx),1,-1)
	return dot(W,f_x)
end

function f_apv(f_x)
	N=length(f_x)
	W=AlternateVector(1,-1,N)
	return sum(W.*f_x)
end
x=randn(n)
f_x=@. sin(x)+x*cos(x)
@btime f_std_scalar($f_x);
@btime f_std_scalar_2($f_x);
@btime f_std_vec($f_x);
@btime f_std_vec_linear_algebra($f_x);
@btime f_apv($f_x);