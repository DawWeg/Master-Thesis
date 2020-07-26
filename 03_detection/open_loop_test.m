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
  ewls_regression_vector = [ol_clear_signal(t-1); ewls_regression_vector(1:end-1)];
  [ewls_coefficients_estimate(:,t), ewls_covariance_matrix, ewls_error, ewls_noise_variance(t)] = ewls_recursive( ...
          ol_clear_signal(t), ...
          ewls_regression_vector, ...
          ewls_covariance_matrix, ...
          ewls_coefficients_estimate(:,t-1), ...
          ewls_noise_variance(t-1));  

  ol_threshold_trajectory(t) = mu*sqrt(ewls_noise_variance(t));
  ol_error_trajectory(t) = ewls_error;
  
  %%% Detection
  if(abs(ewls_error) > mu*sqrt(ewls_noise_variance(t)) && t > ewls_equivalent_window_length)
    ol_threshold_trajectory(t) = ol_threshold_trajectory(t-1);
    ol1_detection_signal(t) = 1;
    ol_corrupted_block_start = t;
    
    %%% Stability check
    if(!check_stability(ewls_coefficients_estimate(:,t-1), process_rank))   
    ewls_coefficients_estimate(:,t-1) = levinson_durbin_estimation( ...
        min([ewls_equivalent_window_length, t-1]), ...
        ol_clear_signal(t-(min([ewls_equivalent_window_length, t-1]))+1:t-1));    
    endif
    
    % Open loop detector parameters
    detection_regression_vector = ewls_regression_vector;    
    detection_noise_variance = ewls_noise_variance(t-1);
    f = 0;       
    for i = 0:max_corrupted_block_length+process_rank
      if(max(ol1_detection_signal(t+i:-1:t+i-process_rank)) == 0 || i == max_corrupted_block_length+process_rank)
        ol_detection_signal(t:t+i-process_rank-1) = 1;
        ol_corrupted_block_end = t+i-process_rank;
        m = ol_corrupted_block_end-ol_corrupted_block_start+1;
        ol_clear_signal(ol_corrupted_block_start:ol_corrupted_block_end) = variable_interpolation( ...
          ol_clear_signal(ol_corrupted_block_start-process_rank:ol_corrupted_block_end+process_rank), ...
          ewls_coefficients_estimate(:,ol_corrupted_block_start-1), ...
          ewls_noise_variance(ol_corrupted_block_start-1), m);
        for i = ol_corrupted_block_start:ol_corrupted_block_end                                                                  
          ewls_coefficients_estimate(:,i) = ewls_coefficients_estimate(:,ol_corrupted_block_start-1);  
        endfor  
        t = t + i;
        break;
      endif
      if(i == 0)
        output_prediction = ewls_coefficients_estimate(:,t-1)'*detection_regression_vector;
        prediction_error = ol_clear_signal(t+i) - output_prediction;
        detection_regression_vector = [output_prediction; detection_regression_vector(1:end-1)];  
      else
        [output_prediction, detection_error, detection_noise_variance, f] = open_loop_detector_step(ol_clear_signal(t+i), ...
                                                       ewls_coefficients_estimate(:,t-1), ...
                                                       detection_regression_vector, ...
                                                       detection_noise_variance, ...
                                                       ewls_noise_variance(t-1), ...
                                                       i+1, ...
                                                       f); 
        detection_regression_vector = [output_prediction; detection_regression_vector(1:end-1)];                                                  
        ol_error_trajectory(t+i) = detection_error;
        ol_threshold_trajectory(t+i) = mu*sqrt(detection_noise_variance);
        if(abs(detection_error) > mu*sqrt(detection_noise_variance))
          ol1_detection_signal(t+i) = 1;
        endif 
      endif   
    endfor   
  endif
  t = t + 1;  
endwhile