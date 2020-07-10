function [detection_signal, ...
          coefficients_trajectory, ...
          error_trajectory, ...
          error_threshold_trajectory, ...
          noise_variance_trajectory, ...
          model_output] = P_U_V_C_VK (input_signal)
          
  global model_rank ewls_initial_cov_matrix ewls_lambda ewls_lambda0 mu detection_delay max_corrupted_block_length;
  N = length(input_signal);
  coefficients_trajectory = zeros(model_rank*2, N, 2);
  error_trajectory = zeros(2, N);
  error_threshold_trajectory = zeros(2, N);
  noise_variance_trajectory = zeros(2, N);
  covariance_matrix = ewls_initial_cov_matrix*eye(model_rank*2);
  regression_vector = zeros(model_rank*2, 1);
  clear_signal = input_signal;
  detection_signal = zeros(2, N);
  counter = 0;  
  inv_lambda = 1/ewls_lambda;
  
  model_output = zeros(2, N);  
  model_regression_vector = zeros(2*model_rank, 1);
  
  t = 2;
  while(t <= N)
    %%% Model estimation
    regression_vector = [clear_signal(1,t-1); clear_signal(2,t-1); regression_vector(1:end-2)];
    [coefficients_trajectory(:,t,:), ...
     covariance_matrix, ...
     error_trajectory(:,t), ...
     noise_variance_trajectory(:,t)] = ewls_step_vector2 (clear_signal(:,t), ... 
                                                            regression_vector, ...
                                                            covariance_matrix, ...
                                                            coefficients_trajectory(:,t-1,:), ...
                                                            noise_variance_trajectory(:,t-1));
    error_threshold_trajectory(:,t) = mu*sqrt(noise_variance_trajectory(:,t));
    
    %%% TEMP calculating model output                                                        
    model_regression_vector = [model_output(1,t-1); model_output(2,t-1); model_regression_vector(1:end-2)];
    for j = 1:2      
      model_output(j,t) = coefficients_trajectory(:,t,j)'*model_regression_vector + error_trajectory(j,t);
    endfor 
    
    if(t < detection_delay || t > N-model_rank-max_corrupted_block_length || counter > 0)
      t = t + 1;
      counter = counter - 1;
      continue;
    endif
    
    %%% Detection        
    detection = abs(error_trajectory(:,t)) > error_threshold_trajectory(:,t);
    if(any(detection))
      detection_signal(:,t) = detection;
      kalman_state_vector = regression_vector;
      kalman_covariance_matrix = zeros(2*model_rank);
      kalman_coefficients = [coefficients_trajectory(:,t-1,1), coefficients_trajectory(:,t-1,2)];
      for i = 1:max_corrupted_block_length-1
        kalman_output_prediction = kalman_coefficients'*kalman_state_vector;
        kalman_error = clear_signal(:,t+i) - kalman_output_prediction;
        kalman_state_vector = [kalman_output_prediction; kalman_state_vector];
        kalman_H = kalman_covariance_matrix*kalman_coefficients;
        kalman_noise_variance = kalman_coefficients'*kalman_H + noise_variance_trajectory(:,t-1);
        kalman_covariance_matrix = [kalman_noise_variance, kalman_H'; kalman_H, kalman_covariance_matrix];
        kalman_coefficients = [kalman_coefficients; zeros(2)];        
        detection = mround(kalman_error'*inv(kalman_noise_variance)*kalman_error) > mu*mu;
        detection_signal(:,t+i) = detection;
        %detection = abs(kalman_error) > mu*sqrt([kalman_noise_variance(1,1); kalman_noise_variance(end,end)]);
        if(!any(detection) || i == max_corrupted_block_length)     
          kalman_L = mround(kalman_covariance_matrix(:,1:2)*inv(kalman_noise_variance));
          kalman_state_vector = kalman_state_vector + kalman_L*kalman_error;
          kalman_covariance_matrix = kalman_covariance_matrix - kalman_L*kalman_noise_variance*kalman_L';
        elseif(all(detection))
          kalman_state_vector = kalman_state_vector;
          kalman_covariance_matrix = kalman_covariance_matrix;
        elseif(detection(1))
          kalman_L = mround((1/kalman_noise_variance(end,end))*kalman_covariance_matrix(:,2));
          kalman_state_vector = kalman_state_vector + kalman_L*kalman_error(2,:);
          kalman_covariance_matrix = kalman_covariance_matrix - kalman_noise_variance(end,end)*kalman_L*kalman_L';
        else
          kalman_L = mround((1/kalman_noise_variance(1,1))*kalman_covariance_matrix(:,1));
          kalman_state_vector = kalman_state_vector + kalman_L*kalman_error(1,:);
          kalman_covariance_matrix = kalman_covariance_matrix - kalman_noise_variance(1,1)*kalman_L*kalman_L';
        endif
        if(i == max_corrupted_block_length-1)
          %%% Interpolate
          counter = model_rank;
          t = t-1;
          break;
        elseif(max(max(detection_signal(:,t+i-model_rank+1:t+i))) == 0)
          %%% Interpolate
          counter = model_rank;
          t = t-1;
          break;
        endif        
      endfor      
    endif     
    if(mod(t,5000) == 0)
      printf("[%*d|100]\n", 3, round((t/N)*100));
    endif 
    t = t + 1;  
  endwhile
endfunction
