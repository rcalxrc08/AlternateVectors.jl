module SparseArraysExt

using SparseArrays, AlternateVectors

Base.BroadcastStyle(::AlternateVectors.AbstractArrayStyleAlternateVector, ::SparseArrays.HigherOrderFns.SparseVecStyle) = SparseArrays.HigherOrderFns.PromoteToSparse()
SparseArrays.HigherOrderFns.is_supported_sparse_broadcast(::AlternateVectors.AbstractAlternateVector, rest...) = SparseArrays.HigherOrderFns.is_supported_sparse_broadcast(rest...)

end # module