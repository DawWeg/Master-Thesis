%%% Estimating process coefficients
ewls_delta = 100;
ewls_lambda = 0.999;
ewls_regression_vector = zeros(process_rank, 1);
ewls_coefficients_estimate = zeros(process_rank, N);
ewls_covariance_matrix = ewls_delta*eye(process_rank);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
ewls_noise_variance = zeros(N, 1);

cl_error_trajectory = zeros(N, 1);
cl_threshold_trajectory = zeros(N, 1);
cl1_detection_signal = zeros(N, 1);
cl_detection_signal = zeros(N, 1);

detection_delay = 10*process_rank;

t = 2;
while(t <= N);
  %%% Estimation 
  ewls_regression_vector = [process_output(t-1); ewls_regression_vector(1:end-1)];
  [ewls_coefficients_estimate(:,t), ewls_covariance_matrix, ewls_error, ewls_noise_variance(t)] = ewls_recursive( ...
          process_output(t), ...
          ewls_regression_vector, ...
          ewls_covariance_matrix, ...
          ewls_coefficients_estimate(:,t-1), ...
          ewls_noise_variance(t-1));
  
  cl_threshold_trajectory(t) = mu*sqrt(ewls_noise_variance(t));
  cl_error_trajectory(t) = ewls_error;
  
  %%% Detection
  if(abs(ewls_error) > mu*sqrt(ewls_noise_variance(t)) && t > ewls_equivalent_window_length)
    cl1_detection_signal(t) = 1;
    
    %%% Stability check
    if(!check_stability(ewls_coefficients_estimate(:,t-1), process_rank))   
    ewls_coefficients_estimate(:,t-1) = levinson_durbin_estimation( ...
        min([ewls_equivalent_window_length, t-1]), ...
        process_output(t-(min([ewls_equivalent_window_length, t-1]))+1:t-1));    
    endif 

    % Closed loop detector parameters
    kalman_state_vector = ewls_regression_vector;
    kalman_covariance_matrix = zeros(process_rank);
    kalman_coefficients = ewls_coefficients_estimate(:,t-1);
    
    for i = 0:max_corrupted_block_length
      % Debug
      if(t+i > length(process_output)-process_rank)
        break;
      endif  
   
      [kalman_state_vector, ...
       kalman_covariance_matrix, ...
       kalman_coefficients, ...
       kalman_error, ...
       kalman_noise_variance] = closed_loop_detector_step( ...
                                kalman_state_vector, ...
                                kalman_covariance_matrix, ...
                                kalman_coefficients, ...
                                ewls_noise_variance(t-1), ...
                                process_output(t+i));
      cl_error_trajectory(t+i) = kalman_error;
      cl_threshold_trajectory(t+i) = mu*sqrt(kalman_noise_variance);
      if(abs(kalman_error) > mu*sqrt(kalman_noise_variance))
        cl1_detection_signal(t+i) = 1;
      else
        kalman_l = mround((1/kalman_noise_variance)*kalman_covariance_matrix(:,1));         
        kalman_state_vector = mround(kalman_state_vector + kalman_l*kalman_error);
        kalman_covariance_matrix = mround(kalman_covariance_matrix - kalman_noise_variance*kalman_l*kalman_l');
      endif            
      if(max(cl1_detection_signal(t+i:-1:t+i-process_rank)) == 0)
        cl_detection_signal(t:t+i-process_rank-1) = 1;
        t = t + i;
        break;
      elseif(i == max_corrupted_block_length-1)
        cl_detection_signal(t:t+i-1) = 1;
        t = t + i;
      endif
    endfor   
  endif
  t = t + 1;  
endwhile