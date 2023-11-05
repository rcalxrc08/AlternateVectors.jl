using .CUDA

CUDA.allowscalar(false)

# Base.BroadcastStyle(a::ArrayStyleAlternatePaddedVector, ::CUDA.CuArrayStyle{0}) = a
# Base.BroadcastStyle(::ArrayStyleAlternatePaddedVector, a::CUDA.CuArrayStyle{N}) where {N} = a

# Base.BroadcastStyle(a::ArrayStyleAlternateVector, ::CUDA.CuArrayStyle{0}) = a
# Base.BroadcastStyle(::ArrayStyleAlternateVector, a::CUDA.CuArrayStyle{N}) where {N} = a