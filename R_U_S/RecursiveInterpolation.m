function [interpolated_samples] = RecursiveInterpolation (input_signal, m, q, model_coefficients, noise_variance)
%%% Preparing variables
AR_model_order = length(model_coefficients);

state_vector = input_signal(q:-1:1);
transition_matrix = [[model_coefficients', zeros(1, q-AR_model_order)]; eye(q-1,q)];
output_vector = [1; zeros(q-1,1)];
covariance_matrix = zeros(q);
%%% Interpolation loop
for t = q+1:q+m+AR_model_order
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
interpolated_samples = flip(state_vector(AR_model_order+1:AR_model_order+m));
endfunction