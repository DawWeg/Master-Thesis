function [coefficients, ...
          covariance_matrix, ...
          error, ...
          noise_variance] = ewls_step_vector2 (input_signal, ...
                                               regression_vector, ...
                                               covariance_matrix, ...
                                               coefficients, ...
                                               noise_variance)
  global ewls_lambda ewls_lambda_0 ewls_noise_variance_coupled;  
  temp = regression_vector'*covariance_matrix; 
  gain_vector = (covariance_matrix*regression_vector)/(ewls_lambda + temp*regression_vector);
  covariance_matrix = (1/ewls_lambda)*(covariance_matrix - gain_vector*temp);
  for j = 1:2
    error(j) = input_signal(j) - regression_vector'*coefficients(:,j);
    coefficients(:,j) = coefficients(:,j) + gain_vector*error(j);
  endfor
  noise_variance = [0; 0]; 
endfunction
