module SparseArraysExt

using SparseArrays, AlternateVectors

Base.BroadcastStyle(::AlternateVectors.ArrayStyleAlternateVector, ::SparseArrays.HigherOrderFns.SparseVecStyle) = SparseArrays.HigherOrderFns.PromoteToSparse()
SparseArrays.HigherOrderFns.is_supported_sparse_broadcast(::AlternateVector, rest...) = SparseArrays.HigherOrderFns.is_supported_sparse_broadcast(rest...)

Base.BroadcastStyle(::AlternateVectors.ArrayStyleAlternatePaddedVector, ::SparseArrays.HigherOrderFns.SparseVecStyle) = SparseArrays.HigherOrderFns.PromoteToSparse()
SparseArrays.HigherOrderFns.is_supported_sparse_broadcast(::AlternatePaddedVector, rest...) = SparseArrays.HigherOrderFns.is_supported_sparse_broadcast(rest...)

end # module