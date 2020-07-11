function [toeplitz_matrix] = build_toeplitz_matrix (coefficients)
  N = length(coefficients)-1;
  toeplitz_matrix = zeros(N);
  for i = 1:N
    for j = i:N
      toeplitz_matrix(i,j) = coefficients(j-i+1);
      toeplitz_matrix(j,i) = coefficients(j-i+1);
    endfor
  endfor
endfunction
