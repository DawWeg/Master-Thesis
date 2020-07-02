function [residual_errors] = residual_errors_for_block(current_block, previous_block)
  global model_rank;
  N = length(current_block);
  regression = [ previous_block(end:-1:end-model_rank+1)];
  covariance_matrix =100*eye(model_rank); 
  coefficients = zeros(model_rank, 1);
  residual_errors = zeros(N,1);
  regression_trajectory = zeros(model_rank, N);
  noise_variance = 0;
  % EWLS
  for t = 1:N  
    if t > 1
      regression = [ current_block(t-1) ; regression(1:model_rank-1) ];
    endif
    
    regression_trajectory(:, t) = regression;
    [coefficients, covariance_matrix, error, noise_variance] = ewls_step( ...
          current_block(t), ...
          regression, ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance);
  endfor
  
  % Calculate residual errors sequence
  for t = 1:N
    residual_errors(t) = current_block(t)-sum(regression_trajectory(:,t)'*coefficients);
  endfor 
endfunction
