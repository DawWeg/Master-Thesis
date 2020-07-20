function [coefficents] = ewls_vector_batch(input_signal, regression, t)
  global ewls_lambda model_rank;
  
  r_inv = zeros(4*model_rank);
  p = zeros(4*model_rank, 1);
  coefficents = zeros(4*model_rank,1);
  
  
  for i=1:t-1
    phi = [regression(:,t-(i-1)), zeros(2*model_rank, 1); zeros(2*model_rank, 1), regression(:,t-(i-1))];
    r_inv += (ewls_lambda^(i-1))*phi*phi';
    p += (ewls_lambda^(i-1))*phi*input_signal(:,t-(i-1));
  endfor
  
  if abs(det(r_inv)) > 1e-9
    coefficents = r_inv \ p;
  endif
endfunction
