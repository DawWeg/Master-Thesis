function [] = ewls_init(input_signal, model_rank, cov_initial, )
  
  N = length(current_block);
  regression = [ previous_block(end:-1:end-model_rank+1)];
  covariance_estimation_errors =100*eye(model_rank); 
  coefficients = zeros(model_rank, 1);
  residual_errors = zeros(N,1);
  regression_trajectory = zeros(model_rank, N);
endfunction
