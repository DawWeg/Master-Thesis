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

t = model_rank+1;
while(t <= N);
  %%% Estimation 
  ewls_regression_vector = cl_clear_signal(t-1:-1:t-model_rank);
  [ewls_coefficients_estimate(:,t), ewls_covariance_matrix, ewls_error, ewls_noise_variance(t)] = ewls_recursive( ...
          cl_clear_signal(t), ...
          ewls_regression_vector, ...
          ewls_covariance_matrix, ...
          ewls_coefficients_estimate(:,t-1), ...
          ewls_noise_variance(t-1));
  
  cl_threshold_trajectory(t) = mu*sqrt(ewls_noise_variance(t));
  cl_error_trajectory(t) = ewls_error;
  
  %%% Detection
  if(abs(ewls_error) > mu*sqrt(ewls_noise_variance(t)) && t > ewls_equivalent_window_length)
    cl1_detection_signal(t) = 1;
    cl_corrupted_block_start = t;
    %%% Stability check
    if(!check_stability(ewls_coefficients_estimate(:,t-1), process_rank))  
    ewls_coefficients_estimate(:,t-1) = levinson_durbin_estimation( ...
        min([ewls_equivalent_window_length, t-1]), ...
        cl_clear_signal(t-(min([ewls_equivalent_window_length, t-1]))+1:t-1));    
    endif 

    % Closed loop detector parameters
    kalman_state_vector = ewls_regression_vector;
    kalman_covariance_matrix = zeros(process_rank);
    kalman_coefficients = ewls_coefficients_estimate(:,t-1);
    
    for i = 0:max_corrupted_block_length+process_rank
      if(max(cl1_detection_signal(t+i:-1:t+i-process_rank)) == 0 || i == max_corrupted_block_length+process_rank-1)        
        cl_detection_signal(t:t+i-process_rank-1) = 1;
        cl_corrupted_block_end = t+i-process_rank;
        m = cl_corrupted_block_end-cl_corrupted_block_start+1;
        cl_clear_signal(cl_corrupted_block_start:cl_corrupted_block_end) = variable_interpolation( ...
          cl_clear_signal(cl_corrupted_block_start-process_rank:cl_corrupted_block_end+process_rank), ...
          ewls_coefficients_estimate(:,cl_corrupted_block_start-1), ...
          ewls_noise_variance(cl_corrupted_block_start-1), m);
        for i = cl_corrupted_block_start:cl_corrupted_block_end                                                                  
          ewls_coefficients_estimate(:,i) = ewls_coefficients_estimate(:,cl_corrupted_block_start-1); 
          ewls_noise_variance(i) = ewls_noise_variance(cl_corrupted_block_start-1); 
        endfor
        t = cl_corrupted_block_end;
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
                                cl_clear_signal(t+i));
      cl_error_trajectory(t+i) = kalman_error;
      cl_threshold_trajectory(t+i) = mu*sqrt(kalman_noise_variance);
      if(abs(kalman_error) > mu*sqrt(kalman_noise_variance))
        cl1_detection_signal(t+i) = 1;
      else
        kalman_l = mround((1/kalman_noise_variance)*kalman_covariance_matrix(:,1));         
        kalman_state_vector = mround(kalman_state_vector + kalman_l*kalman_error);
        kalman_covariance_matrix = mround(kalman_covariance_matrix - kalman_noise_variance*kalman_l*kalman_l');
      endif
    endfor   
  endif
  t = t + 1;  
endwhile