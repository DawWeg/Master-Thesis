function [coefficients, noise_variance, error, covariance_matrix] = ...
  EWLS_Step (regression_vector, covariance_matrix, input_sample, coefficients, noise_variance)
  
global lambda lambda0;
temp = regression_vector'*covariance_matrix;
error = input_sample - regression_vector'*coefficients;
gain_vector = (covariance_matrix*regression_vector)/(lambda + temp*regression_vector);
covariance_matrix = (1/lambda)*(covariance_matrix - gain_vector*temp);
coefficients = coefficients + gain_vector*error;
sigma = lambda/(lambda + temp*regression_vector);
noise_variance = lambda0*noise_variance + (1-lambda0)*error*error*sigma;
endfunction
