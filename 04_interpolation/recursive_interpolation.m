function [interpolated_samples] = recursive_interpolation (input_signal, m, q, model_coefficients, noise_variance)
%%% Preparing variables
global model_rank;
state_vector = input_signal(q:-1:1);
transition_matrix = [[model_coefficients, zeros(1, q-model_rank)]; eye(q-1,q)];
output_vector = [1; zeros(q-1,1)];
covariance_matrix = zeros(q);
%%% Interpolation loop
for t = q+1:q+m+model_rank
  state_vector = transition_matrix*state_vector;
  covariance_matrix = transition_matrix*covariance_matrix*transition_matrix' + ...
                      output_vector*output_vector'*noise_variance;
  if(t < q+m)
    state_vector = state_vector;
    covariance_matrix = covariance_matrix;
  else
    error = input_signal(t) - output_vector'*state_vector;
    g = output_vector'*covariance_matrix*output_vector;
    l = (covariance_matrix*output_vector)/g;
    state_vector = state_vector + l*error;
    covariance_matrix = covariance_matrix - g*l*l';
  endif
endfor
%%% Taking interpolated samples from state vector
interpolated_samples = flip(state_vector(model_rank+1:model_rank+m));
endfunction