function [coefficients, covariance_matrix, error, noise_variance] = ewls_recursive( ...
          current_sample, ...
          regression, ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance)
          
  global ewls_lambda ewls_lambda_0 ewls_noise_variance_coupled;
  
  regression_cov = regression' * covariance_matrix;
  
  % Calculate error as 
  % e(t) = y(t) - fi(t)' * teta(t-1)
  error = current_sample - regression' * coefficients;
  
  % Calculate gain as 
  %                  Q(t-1) * fi(t)
  % k(t) = ----------------------------------
  %         lambda + fi'(t) * Q(t-1) * fi(t)
  %
  gain_vector = ...
      (covariance_matrix * regression) ...
      / ...
      (ewls_lambda + regression_cov * regression);
      
  % Calculate new covariance matrix as 
  %          1     
  % Q(t) = ------ * ( Ir - k(t) * fi'(t) ) * Q(t-1)
  %        lambda
  %   
  covariance_matrix = ...
      (1/ewls_lambda) * (covariance_matrix - gain_vector * regression_cov);
  
  % Calculate new coefficients as:
  % theta(t) = theta(t-1) + Q(t) * fi(t) * e(t) 
  %         = theta(t-1) + k(t) * e(t)
  coefficients = coefficients + gain_vector * error;
  
  % Calculate noise variance as:
  % 
  % -> EWLS Coupled
  %                          lambda
  % sigma(t) = ---------------------------------
  %             lambda + fi'(t) * Q(t-1) * fi(t)
  %
  % ro(t) = lambda * ro(t-1) + (1-lambda) * e^2(t) * sigma(t)
  %
  % -> EWLS Decoupled
  %
  % ro(t) = lambda_0 * ro(t-1) + (1-lambda_0) * e^2(t)
  if(ewls_noise_variance_coupled==1)
    sigma = ...
      ewls_lambda ...
      /...
      (ewls_lambda + regression_cov*regression);
      
    noise_variance = ewls_lambda*noise_variance + (1-ewls_lambda)*error*error*sigma;
  else 
    noise_variance = ewls_lambda_0*noise_variance + (1-ewls_lambda_0)*error*error;
  endif
endfunction