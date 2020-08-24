function isStable = check_stability_var (model_coefficients)
%%% Preparing variables
isStable = 1;
model_rank = length(model_coefficients)/4;
A = vector_generate_aq_cq(model_coefficients, model_rank, model_rank);
if(max(abs(eig(A))) > 1)
  isStable = 0;
endif
endfunction

