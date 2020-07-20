%%% Estimating process coefficients
ewls_delta = 100;
ewls_lambda = 0.999;
ewls_regression_vector = zeros(process_rank, 1);
ewls_coefficients_estimate = zeros(process_rank, N);
ewls_covariance_matrix = ewls_delta*eye(process_rank);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
ewls_noise_variance = zeros(N, 1);

ol_error_trajectory = zeros(N, 1);
ol_threshold_trajectory = zeros(N, 1);
ol1_detection_signal = zeros(N, 1);
ol_detection_signal = zeros(N, 1);

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

  ol_threshold_trajectory(t) = mu*sqrt(ewls_noise_variance(t));
  ol_error_trajectory(t) = ewls_error;
  
  %%% Detection
  if(abs(ewls_error) > mu*sqrt(ewls_noise_variance(t)) && t > ewls_equivalent_window_length)
    ol1_detection_signal(t) = 1;
   
    %%% Stability check
    if(!check_stability(ewls_coefficients_estimate(:,t-1), process_rank))   
    ewls_coefficients_estimate(:,t-1) = levinson_durbin_estimation( ...
        min([ewls_equivalent_window_length, t-1]), ...
        process_output(t-(min([ewls_equivalent_window_length, t-1]))+1:t-1));    
    endif
    
    % Open loop detector parameters
    detection_regression_vector = ewls_regression_vector;
    detection_noise_variance = ewls_noise_variance(t-1);
    f = 0;   
    
    for i = 0:max_corrupted_block_length
      % Debug
      if(t+i > length(process_output)-process_rank)
        break;
      endif       
      if(i > 0)
        detection_regression_vector = [output_prediction; detection_regression_vector(1:end-1)];           
      endif
      [output_prediction, detection_error, detection_noise_variance, f] = open_loop_detector_step(process_output(t+i), ...
                                                       ewls_coefficients_estimate(:,t-1), ...
                                                       detection_regression_vector, ...
                                                       detection_noise_variance, ...
                                                       ewls_noise_variance(t-1), ...
                                                       i+2, ...
                                                       f);
      if(i == 0)
        detection_noise_variance = ewls_noise_variance(t-1);
      endif  
      ol_error_trajectory(t+i) = detection_error;
      ol_threshold_trajectory(t+i) = mu*sqrt(detection_noise_variance);    

      if(abs(detection_error) > mu*sqrt(detection_noise_variance))
        ol1_detection_signal(t+i) = 1;
      endif      
      if(max(ol1_detection_signal(t+i:-1:t+i-process_rank)) == 0)
        ol_detection_signal(t:t+i-process_rank-1) = 1;
        t = t + i;
        break;
      elseif(i == max_corrupted_block_length-1)
        ol_detection_signal(t:t+i-1) = 1;
        t = t + i;
        break;
      endif
    endfor   
  endif
  t = t + 1;  
endwhile