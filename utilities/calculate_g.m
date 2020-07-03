function g = calculate_g (k, f, i, model_coefficients)
  global model_rank;
  if(k == 1)
    g = model_coefficients(i+1);
    return;
  else
    if(i == model_rank-1)
      g = model_coefficients(i+1)*f(k-1);
    else
      g = calculate_g(k-1, f, i+1, model_coefficients) + model_coefficients(i+1)*f(k);
    endif    
    return;
  endif
endfunction
