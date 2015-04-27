module Hamming
# Implements a general method to create hamming codes
# Following the lecture notes from MIT 6.02 S2012 and F2011

export hamming

using Docile
using IntModN

@doc """
Calculates the hamming distance between a, b
""" ->
function hamming(a, b)
    result = 0
    for (i, j) in zip(a,b)
        if i != j
            result += 1
        end
    end
end

@doc """
Creates the generator matrix for a Hamming Code (n, k)
A: parity matrix (see parity)
""" ->
function generator{T}(n, k, A :: Matrix{T})
    G = eye(T, k, n) # kxk identity matrices
    
    G[:, k+1:n] = A
    G
end

@doc """
Creates the decoder matrix for a Hamming Code (n, k)
A: parity matrix (see parity)
""" ->
function decoder{T}(n, k, A :: Matrix{T})
    H = hcat(A', eye(T, n-k))
    
    H
end

@doc """
Creates the parity matrix for a Hamming Code (n, k)
""" ->
function parity{T}(:: Type{T}, n, k)
    A = zeros(T, k, n-k)
    indices = bitindices(k) # get bitindices of d
    
    for i in 1:size(A, 2)
        p_i = 2^(i-1) # calculate the bit index of p_i
        
        for j in 1:size(A, 1)
            d_j = indices[j] # calculate the bit index of d_i
            
            if p_i & d_j != 0 # if logical *and* of bit indices d_j, p_i != 0
                              # d_j is part of the calculation for p_i
                A[j, i] = one(T)
            end
        end
    end
    A
end

@doc """
Calculates the bitindices of the data entries.
Indices that are a power of two are parity bits.
""" ->
function bitindices(n)
    indices = zeros(Int64, n)
    
    k = 1
    for i in 1:n
        while ispow2(k) # Skip the powers of two
            k += 1
        end
        
        indices[i] = k
        k += 1
    end
    
    indices
end

end # module
