function [  clear_signal,...
            detection_signal,...
            error_trajectory,...
            error_threshold  ] = P_U_S_C_VK(input_signal)
%%% Preparing variables
global model_rank ewls_lambda ewls_lambda_0 ewls_initial_cov_matrix mu max_corrupted_block_length detection_delay;
N = length(input_signal);
clear_signal = input_signal;
covariance_matrix = ewls_initial_cov_matrix*eye(model_rank);
coefficients_trajectory = zeros(N, model_rank);
regression_vector = zeros(model_rank, 1);
noise_variance_trajectory = zeros(N, 1);
detection_signal = zeros(N, 1);
inv_lambda = 1/ewls_lambda;
error_trajectory = zeros(N, 1);
error_threshold = zeros(N, 1);
counter = 0;

%%% Corrupted samples detection loop
t = 2;
while(t <= N)
    % Estimating model parameters using weighted recursive least squares algorithm
    regression_vector = [clear_signal(t-1); regression_vector(1:end-1)];
    [coefficients_trajectory(t,:), covariance_matrix, error_trajectory(t), noise_variance_trajectory(t)] = ...
              ewls_step(clear_signal(t), ...
              regression_vector, ...
              covariance_matrix, ...
              coefficients_trajectory(t-1,:)', ...
              noise_variance_trajectory(t-1));
    error_threshold(t) = mu*sqrt(noise_variance_trajectory(t-1)); 
    if(t < detection_delay || t > N-model_rank-max_corrupted_block_length || counter > 0)
      counter = counter - 1;
      t = t + 1;
      continue;
    endif
    % Checking if the sample is corrupted
    if(abs(error_trajectory(t)) > error_threshold(t))
      % If the sample is corrupted alarm is raised.
      % We check the model stability, and if it's not stable we use Levinson-Durbin
      % algorithm to make sure that it is.
      % TODO Levinson-Durbin algorithm
      if(!check_stability(coefficients_trajectory(t-1,:)))
        disp("Model unstable");     
      endif    
      false_positive = 0;
      detection_signal(t) = 1;
      block_start_index = t;
      kalman_state_vector = clear_signal(t:-1:t-model_rank+1);
      kalman_covariance_matrix = zeros(model_rank);
      kalman_coefficients = coefficients_trajectory(t-1,:);
      for i = 1:(max_corrupted_block_length-1)
        [kalman_state_vector, ...
        kalman_covariance_matrix, ...
        kalman_coefficients, ...
        kalman_error, ...
        kalman_noise_variance] = closed_loop_detector_step( ...
                                 kalman_state_vector, ...
                                 kalman_covariance_matrix, ...
                                 kalman_coefficients, ...
                                 noise_variance_trajectory(t-1,:), ...
                                 clear_signal(t+i));       
        if(abs(kalman_error) > mu*sqrt(kalman_noise_variance))
          detection_signal(t+i) = 1;
          kalman_state_vector = kalman_state_vector;
          kalman_covariance_matrix = kalman_covariance_matrix;
        else
          kalman_l = mround((1/kalman_noise_variance)*kalman_covariance_matrix(:,1));         
          kalman_state_vector = mround(kalman_state_vector + kalman_l*kalman_error);
          kalman_covariance_matrix = mround(kalman_covariance_matrix - kalman_noise_variance*kalman_l*kalman_l');
          if(max(detection_signal(t+i-model_rank+1:t+i)) != 0)
            false_positive = 1;
          endif          
        endif        
        if(max(detection_signal(t+i-model_rank+1:1:t+i)) == 0)
          m = t + i - block_start_index - model_rank;
          detection_signal(block_start_index:block_start_index+m-1) = 1;
          clear_signal(block_start_index:block_start_index+m-1) = variable_interpolation( ...
                  clear_signal(block_start_index-model_rank:t+i), ...
                  m, ...
                  coefficients_trajectory(t-1,:), ...
                  noise_variance_trajectory(t-1));          
          t = t-1;
          counter = model_rank;
          break;
        elseif(i >= max_corrupted_block_length)
          m = max_corrupted_block_length; 
          detection_signal(block_start_index:block_start_index+m-1) = 1;
          clear_signal(block_start_index:block_start_index+m-1) = variable_interpolation( ...
                  clear_signal(block_start_index-model_rank:block_start_index+m+model_rank), ...
                  m, ...
                  coefficients_trajectory(t-1,:), ...
                  noise_variance_trajectory(t-1));
          t = t-1; 
          counter = model_rank;    
          break;
        endif                
      endfor 
    endif
    if(mod(t,1000) == 0)
      printf("[%*d|100]\n", 3, round((t/N)*100));
    endif
    t = t + 1;
endwhile
disp("[100|100]");
endfunction