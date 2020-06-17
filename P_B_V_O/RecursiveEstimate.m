function [recursive_estimate, noise_variance_estimate] = RecursiveEstimate (input_signal, lambda, delta)
%%% Preparing variables
global N AR_model_order;
inv_lambda = 1/lambda;
residual_errors = zeros(N,2);
recursive_estimate = zeros(2*AR_model_order, N, 2);
covariance_matrix = delta*eye(2*AR_model_order);
regression_vector = zeros(2*AR_model_order,1);
noise_variance_estimate = zeros(N,2);
for i = 1:4
  for j = 1:2
    regression_vector((i-1)*2+j) = input_signal(AR_model_order-i,j);
  endfor
endfor

%%% Estimation loop
for t = AR_model_order+1:N
  regression_vector = shift(regression_vector,2);
  regression_vector(1:2) = input_signal(t-1,:);
  gain_vector = (covariance_matrix*regression_vector)/(lambda+regression_vector'*covariance_matrix*regression_vector);
  covariance_matrix = inv_lambda*(eye(2*AR_model_order) - gain_vector*regression_vector')*covariance_matrix;
  for j = 1:2
    residual_errors(t,j) = input_signal(t,j) - regression_vector'*recursive_estimate(:,t-1,j);
    recursive_estimate(:,t,j) = recursive_estimate(:,t-1,j) + gain_vector*residual_errors(t,j);
  endfor  
  noise_variance_estimate(t,:) = lambda*noise_variance_estimate(t-1,:) + (1-lambda)*residual_errors(t,:)*...
                                 residual_errors(t,:)'*(lambda/(lambda+regression_vector'*covariance_matrix*regression_vector));                                 
endfor

endfunction
