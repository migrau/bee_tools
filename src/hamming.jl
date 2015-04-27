module Hamming
# Implements a general method to create hamming codes
# Following the lecture notes from MIT 6.02 S2012 and F2011

export hamming, hamming_code, encode, decode

using Docile
using IntModN

# The mathematical field used for calculations
const Field = ZField{2, Int64}

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
    return result
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

@doc """
Creates the generator and decoder matrices for a Hamming code (n, k)
T :: Type of the matrices

returns: (Generator, Decoder)
""" ->
function hamming_code{T}( :: Type{T}, n, k)
  A = parity(T, n, k)

  G = generator(n, k, A)
  H = decoder(n, k, A)

  return G, H
end

@doc """
Encodes a msg given a generator matrix
""" ->
encode(G, msg) = (msg * G)

@doc """
Deccodes a msg given a decoder matrix and the syndroms
""" ->
function decode(H, syndroms, msg)
    s = H * msg # Calculate syndrom
    
    if sum(s) == 0
        ind = convert(Array{Int64}, s)
        i = syndroms[ind + 1]
        msg[i] ^= 1
    end
    
    msg
end

# TODO: rewrite with @generate function
# This codes caches and generates the syndroms and other necessary matrices.
# Provides utility methods.
export encode_7_4, decode_7_4, encode_15_11, decode_15_11
for (n, k) in ((7, 4), (15, 11))
    G = symbol("G#$n#$k")
    H = symbol("H#$n#$k")
    S = symbol("Syndroms#$n#$k")
    enc = symbol("encode_$(n)_$k")
    dec = symbol("decode_$(n)_$k")
    @eval begin
      const $G, $H = hamming_code($Field, $n, $k)

      # Precalculate Syndroms
      const $S = zeros(Int64, [2 for i in 1:$(n-k)]...)

      for i in 1:$n
        e = $Field[j == i ? 1 : 0 for j in 1:$n]
        ind = convert(Array{Int64}, $H * e) # convert to Int64 to escape field arithmetic

        $S[ind + 1] = i # 1-based indexing
      end

      $enc(msg) = encode($G, msg)
      $dec(msg) = decode($H, $S, msg)[1:$k]

    end
end

end # module
