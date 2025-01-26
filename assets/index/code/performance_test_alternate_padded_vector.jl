# This file was generated, do not modify it. # hide
using AlternateVectors, BenchmarkTools,LinearAlgebra
n2=10_000
function f_simpson_std_scalar(f_x)
	N=length(f_x)
	sum_z=zero(eltype(f_x))
	for i in 1:N
		w=ifelse(i==1,1/3,ifelse(i==N,1/3,4/3))
		sum_z+=@views @inbounds w*f_x[i]
	end
	return sum_z
end

function f_simpson_std_vec(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(idx==1,1/3,ifelse(idx==N,1/3,4/3))
	return sum(W.*f_x)
end

function f_simpson_std_vec_linear_algebra(f_x)
	N=length(f_x)
	idx=1:N
	W=@. ifelse(idx==1,1/3,ifelse(idx==N,1/3,4/3))
	return dot(W,f_x)
end

function f_simpson_apv(f_x)
	N=length(f_x)
	W=AlternatePaddedVector(1/3,4/3,4/3,1/3,N)
	return sum(W.*f_x)
end

function f_simpson_apv_linear_algebra(f_x)
	N=length(f_x)
	W=AlternatePaddedVector(1/3,4/3,4/3,1/3,N)
	return dot(W,f_x)
end

x2=randn(n2)
f_x2=@. sin(x2)+x2*cos(x2)
@btime f_simpson_std_scalar($f_x2);
@btime f_simpson_std_vec($f_x2);
@btime f_simpson_std_vec_linear_algebra($f_x2);
@btime f_simpson_apv($f_x2);
@btime f_simpson_apv_linear_algebra($f_x2);