function [interpolated_samples] = variable_interpolation (input_signal, model_coefficients, noise_variance, m)
%%% Preparing variables
global model_rank;
state_vector = input_signal(model_rank:-1:1);
covariance_matrix = zeros(model_rank);
%%% Interpolation loop
for t = model_rank+1:2*model_rank+m
  output_prediction = model_coefficients'*state_vector;
  error = input_signal(t) - output_prediction;
  state_vector = [output_prediction; state_vector];
  h = covariance_matrix*model_coefficients;
  noise_variance_estimate = model_coefficients'*h + noise_variance;
  covariance_matrix = [noise_variance_estimate, h'; h, covariance_matrix];
  model_coefficients = [model_coefficients; 0];
  if(t < model_rank+1+m)
    state_vector = state_vector;
    covariance_matrix = covariance_matrix;
  else
    l = mround((1/noise_variance_estimate)*covariance_matrix(:,1));
    state_vector = mround(state_vector + l*error);
    covariance_matrix = mround(covariance_matrix - noise_variance_estimate*l*l');
    %l = ((1/noise_variance_estimate)*covariance_matrix(:,1));
    %state_vector = (state_vector + l*error);
    %covariance_matrix = (covariance_matrix - noise_variance_estimate*l*l');
  endif
endfor
%%% Taking interpolated samples from state vector
interpolated_samples = flip(state_vector(model_rank+1:model_rank+m));
endfunction
