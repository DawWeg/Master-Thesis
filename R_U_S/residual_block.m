function [residual_errors] = residual_block(current_block, previous_block, model_rank, lambda)
  N = length(current_block);
  regression = [ previous_block(end:-1:end-model_rank+1)];
  covariance_estimation_errors =100*eye(model_rank); 
  coefficients = zeros(model_rank, 1);
  residual_errors = zeros(N,1);
  regression_trajectory = zeros(model_rank, N);
  % EWLS
  for t = 1:N  
    if t > 1
      regression = [ 0 ; regression(1:model_rank-1) ];
      regression(1) = current_block(t-1);
    endif
    
    regression_trajectory(:, t) = regression;
    error = current_block(t) - regression' * coefficients;
    gain_vector = (covariance_estimation_errors*regression)/(lambda+regression'*covariance_estimation_errors*regression);
    covariance_estimation_errors = (1/lambda)*(eye(model_rank)-gain_vector*regression')*covariance_estimation_errors;
    coefficients = coefficients + covariance_estimation_errors*regression*error;
  endfor
  
  % Calculate residual errors sequence
  for t = 1:N
    residual_errors(t) = current_block(t)-sum(regression_trajectory(:,t)'*coefficients);
  endfor 
endfunction
