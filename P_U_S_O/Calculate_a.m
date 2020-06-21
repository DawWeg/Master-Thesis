function a = Calculate_a (model_coefficients, k, i, a_matrix)
global AR_model_order;
if(k == AR_model_order)
  a = -model_coefficients(i);
elseif(a_matrix(k,i) != 0)
  a = a_matrix(k,i);
else
  temp = Calculate_a(model_coefficients, k+1, k+1, a_matrix);
  a = Calculate_a(model_coefficients, k+1, i, a_matrix) - temp*Calculate_a(model_coefficients, k+1, k+1-i, a_matrix)/...
      (1 - pow2(temp));
endif
endfunction
