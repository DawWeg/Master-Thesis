function [coefficients, covariance_matrix, error, noise_variance] =ewls_step_vector(
          current_samples, ...
          regression, ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance)
  
  global ewls_lambda ewls_lambda_0 ewls_noise_variance_coupled model_rank;
  
  regression_cov = regression' * covariance_matrix;
  phi = [regression, zeros(2*model_rank, 1); zeros(2*model_rank, 1), regression];
  
  error = current_samples - phi'*coefficients;
  gain_vector = (covariance_matrix*regression)/(ewls_lambda + regression_cov*regression);
  covariance_matrix = (1/ewls_lambda)*(covariance_matrix - gain_vector*regression_cov);

  coefficients = coefficients + [gain_vector*error(1); gain_vector*error(2)];
  
  if(ewls_noise_variance_coupled==1)
    sigma = ...
      ewls_lambda ...
      /...
      (ewls_lambda + regression_cov*regression);
      
    noise_variance = ewls_lambda*noise_variance + (1-ewls_lambda)*error*error'*sigma;
  else 
    noise_variance = ewls_lambda_0*noise_variance + (1-ewls_lambda_0)*error*error';
  endif
endfunction
