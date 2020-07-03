function [  clear_signal,...
            detection_signal,...
            error_trajectory,...
            error_threshold  ] = P_U_S_O_VK(input_signal)
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
    if(t < detection_delay || t > N-model_rank || counter > 0)
      counter = counter - 1;
      t = t + 1;
      continue;
    endif
    
    % Checking if the sample is corrupted
    if(abs(error_trajectory(t)) > error_threshold(t))
      % If the sample is corrupted alarm is raised.
      % We check the model stability, and if it's not stable we use Levinson-Durbin
      % algorithm to make sure that it is.
      %dbstop("CheckStability");
      if(!check_stability(coefficients_trajectory(t-1,:)))
        disp("Model unstable");     
      endif    
      detection_signal(t) = 1;
      block_start_index = t;
      prediction_regression_vector = regression_vector;
      prediction_noise_variance = noise_variance_trajectory(t-1);
      f = 0;
      for i = 1:(max_corrupted_block_length+model_rank-1)
        % Starting open loop detection process:
        prediction_regression_vector = [clear_signal(t+i-1); prediction_regression_vector(1:end-1)];
        [prediction_error, prediction_noise_variance, f] = open_loop_detector_step(clear_signal(t+i), ...
                                                           coefficients_trajectory(t-1,:), ...
                                                           prediction_regression_vector, ...
                                                           prediction_noise_variance, ...
                                                           noise_variance_trajectory(t-1), ...
                                                           i+1, ...
                                                           f); 
        if(abs(prediction_error) > mu*sqrt(prediction_noise_variance))
          detection_signal(t+i) = 1;
        endif        
        if(max(detection_signal(t+i-model_rank+1:1:t+i)) == 0)
          % If last 5 samples are deemed uncorrupted we:
          %   * fill the whole block from beginning till the end in the detection signal with ones
          %   * interpolate corrupted fragment using Kalman filter
          %   * go back to the sample prior to the detection alarm and continue
          m = t + i - block_start_index - model_rank;
          detection_signal(block_start_index:block_start_index+m-1) = 1;
          clear_signal(block_start_index:block_start_index+m-1) = variable_interpolation( ...
                  clear_signal(block_start_index-model_rank:block_start_index+m+model_rank-1), ...
                  m, ...
                  coefficients_trajectory(t-1,:), ...
                  noise_variance_trajectory(t-1));          
          t = t-1;
          counter = model_rank;
          break;
        elseif(i >= max_corrupted_block_length)
          % If we reached max block length we:
          %   * fill the whole block with ones in the detection signal
          %   * interpolate whole block 
          %   * go back to the sample prior to the detection alarm and continue
          m = max_corrupted_block_length; 
          detection_signal(block_start_index:block_start_index+m-1) = 1;
          clear_signal(block_start_index:block_start_index+m-1) = variable_interpolation( ...
                  clear_signal(block_start_index-model_rank:block_start_index+m+model_rank-1), ...
                  m, ...
                  coefficients_trajectory(t-1,:), ...
                  noise_variance_trajectory(t-1));
          t = t-1; 
          counter = model_rank;         
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
