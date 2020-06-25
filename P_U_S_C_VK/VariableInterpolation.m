function [interpolated_samples] = VariableInterpolation (input_signal, m, model_coefficients, noise_variance)
%%% Preparing variables
global AR_model_order;
state_vector = input_signal(AR_model_order:-1:1);
covariance_matrix = zeros(AR_model_order);
%%% Interpolation loop
for t = AR_model_order+1:2*AR_model_order+m
  output_prediction = model_coefficients'*state_vector;
  error = input_signal(t) - output_prediction;
  state_vector = [output_prediction; state_vector];
  h = covariance_matrix*model_coefficients;
  noise_variance_estimate = model_coefficients'*h + noise_variance;
  covariance_matrix = [noise_variance_estimate, h'; h, covariance_matrix];
  model_coefficients = [model_coefficients; 0];
  if(t < AR_model_order+1+m)
    state_vector = state_vector;
    covariance_matrix = covariance_matrix;
  else
    l = (1/noise_variance_estimate)*covariance_matrix(:,1);
    state_vector = state_vector + l*error;
    covariance_matrix = covariance_matrix - noise_variance_estimate*l*l';
  endif
endfor
%%% Taking interpolated samples from state vector
interpolated_samples = flip(state_vector(AR_model_order+1:AR_model_order+m));
endfunction
