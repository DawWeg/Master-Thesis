function isStable = check_stability (model_coefficients)
%%% Preparing variables
global model_rank;
a = zeros(model_rank);
a(end,:) = -model_coefficients;
isStable = 1;
%%% Decision loop
for k = model_rank-1:-1:1
  for i = 1:k
    a(k,i) = (a(k+1,i) - a(k+1,k+1)*a(k+1,k+1-i))/(1-power(a(k+1,k+1),2));
  endfor
endfor
if(max(max(abs(diag(a)))) > 1)
  isStable = 0;
endif
endfunction
