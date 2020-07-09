function [coefficients_trajectory, ...
          error_trajectory, ...
          model_output] = P_U_V_C_VK (input_signal)
          
  global model_rank ewls_initial_cov_matrix ewls_lambda;
  N = length(input_signal);
  coefficients_trajectory = zeros(model_rank*2, N, 2);
  error_trajectory = zeros(1, N, 2);
  noise_variance_trajectory = zeros(1, N, 2);
  model_output = zeros(2, N);
  model_regression_vector = zeros(2*model_rank, 1);
  covariance_matrix = ewls_initial_cov_matrix*eye(model_rank*2);
  regression_vector = zeros(model_rank*2, 1);
  inv_lambda = 1/ewls_lambda;  
  
  for t = 2:N
    regression_vector = [input_signal(1,t-1); input_signal(2,t-1); regression_vector(1:end-2)];
    [coefficients_trajectory(:,t,:), ...
     covariance_matrix, ...
     error_trajectory(1,t,:), ...
     noise_variance_trajectory(1,t,:)] = ewls_step_vector2 (input_signal(:,t), ... 
                                                            regression_vector, ...
                                                            covariance_matrix, ...
                                                            coefficients_trajectory(:,t-1,:), ...
                                                            noise_variance_trajectory(1,t-1,:));    
    %temp = regression_vector'*covariance_matrix; 
    %gain_vector = (covariance_matrix*regression_vector)/(ewls_lambda + temp*regression_vector);
    %covariance_matrix = inv_lambda*(covariance_matrix - gain_vector*temp);
    model_regression_vector = [model_output(1,t-1); model_output(2,t-1); model_regression_vector(1:end-2)];
    for j = 1:2
      %error_trajectory(1,t,j) = input_signal(j,t) - regression_vector'*coefficients_trajectory(:,t-1,j);
      %coefficients_trajectory(:,t,j) = coefficients_trajectory(:,t-1,j) + gain_vector*error_trajectory(1,t,j);
      model_output(j,t) = coefficients_trajectory(:,t,j)'*model_regression_vector + error_trajectory(1,t,j);
    endfor 
    if(mod(t,1000) == 0)
      printf("[%*d|100]\n", 3, round((t/N)*100));
    endif   
  endfor
endfunction
