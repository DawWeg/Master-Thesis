function [toeplitz_matrix] = build_toeplitz_matrix (coefficients)
  if(ndims(coefficients) == 2)
    N = length(coefficients)-1;
    toeplitz_matrix = zeros(N);
    for i = 1:N
      for j = i:N
        toeplitz_matrix(i,j) = coefficients(j-i+1);
        toeplitz_matrix(j,i) = coefficients(j-i+1);
      endfor
    endfor
  elseif(ndims(coefficients) == 3)
    N = length(coefficients);
    toeplitz_matrix = zeros(N*2);
    for i = 1:N
      for j = i:N
        toeplitz_matrix((i-1)*2+1:i*2,(j-1)*2+1:j*2) = coefficients(:,:,j-i+1);
        toeplitz_matrix((j-1)*2+1:j*2,(i-1)*2+1:i*2) = coefficients(:,:,j-i+1)';
      endfor
    endfor    
  endif
endfunction
