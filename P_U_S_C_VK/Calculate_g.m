function g = Calculate_g (k, f, i, model_coefficients)
  global AR_model_order;
  if(k == 1)
    g = model_coefficients(i+1);
    return;
%  elseif(k == 2)
%    g = model_coefficients(i+2) + model_coefficients(i+1)*f(k);
%    return;
  else
    if(i == AR_model_order-1)
      g = model_coefficients(i+1)*f(k-1);
    else
      g = Calculate_g(k-1, f, i+1, model_coefficients) + model_coefficients(i+1)*f(k);
    endif    
    return;
  endif
endfunction
