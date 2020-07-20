function [coefficents] = ewls_batch(input_signal, regression, t)
  global ewls_lambda model_rank;
  
  r_inv = zeros(model_rank);
  p = zeros(model_rank, 1);
  coefficents = zeros(model_rank,1);
  
  for i=1:t-1
    r_inv += (ewls_lambda^(i-1))*regression(:,t-(i-1))*regression(:,t-(i-1))';
    p += (ewls_lambda^(i-1))*input_signal(t-(i-1))*regression(:,t-(i-1));
  endfor
  
  if abs(det(r_inv)) > 1e-9
    coefficents = r_inv \ p;
  endif
endfunction
