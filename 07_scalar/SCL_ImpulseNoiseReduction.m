function [input_signal, detection_signal, ewls_error_trajcetory, threshold_trajectory] = SCL_ImpulseNoiseReduction (input_signal)
  
  %%% Preparing variables
  global model_rank ewls_lambda ewls_initial_cov_matrix SCL_MODE mu max_corrupted_block_length;
  N = length(input_signal);
  ewls_regression_vector = zeros(model_rank, 1);
  ewls_coefficients_estimate = zeros(model_rank, N);
  ewls_covariance_matrix = ewls_initial_cov_matrix*eye(model_rank);
  ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
  ewls_noise_variance = zeros(N, 1);

  error_trajectory = zeros(N, 1);
  threshold_trajectory = zeros(N, 1);
  detection_signal = zeros(N, 1);
  detection_delay = 10*model_rank;

  t = model_rank+1;
  while(t <= N-100);
    print_progress("SCL Impulse Noise Reduction", t, N, N/100);
    %%% Estimation 
    ewls_regression_vector = input_signal(t-1:-1:t-model_rank);
    [ewls_coefficients_estimate(:,t), ewls_covariance_matrix, ewls_error_trajectory(t), ewls_noise_variance(t)] = ewls_recursive( ...
          input_signal(t), ...
          ewls_regression_vector, ...
          ewls_covariance_matrix, ...
          ewls_coefficients_estimate(:,t-1), ...
          ewls_noise_variance(t-1));  

    ewls_threshold_trajectory(t) = mu*sqrt(ewls_noise_variance(t));
  
    %%% Raising detection alarm
    if(abs(ewls_error_trajectory(t)) > ewls_threshold_trajectory(t) && t > ewls_equivalent_window_length)
      ewls_threshold_trajectory(t) = ewls_threshold_trajectory(t-1);
      corrupted_block_start = t;
    
      %%% Stability check
      if(!check_stability(ewls_coefficients_estimate(:,t-1), model_rank)) 
      printf("Model unstable on: %d", t);  
      ewls_coefficients_estimate(:,t-1) = levinson_durbin_estimation( ...
        min([ewls_equivalent_window_length, t-1]), ...
        input_signal(t-(min([ewls_equivalent_window_length, t-1]))+1:t-1));    
      endif
    
      %%% Detection
      if(SCL_MODE(1) == 0)
        corrupted_block_length = open_loop_detector(ewls_regression_vector, ...
          ewls_noise_variance(t-1), ...
          ewls_coefficients_estimate(:,t-1), ...
          input_signal(t:min([t+max_corrupted_block_length, N])));
        corrupted_block_end = corrupted_block_start+corrupted_block_length;
        detection_signal(corrupted_block_start:corrupted_block_end) = 1;      
      elseif(SCL_MODE(1) == 1)
        corrupted_block_length = closed_loop_detector(ewls_regression_vector, ...
          ewls_noise_variance(t-1), ...
          ewls_coefficients_estimate(:,t-1), ...
          input_signal(t:min([t+max_corrupted_block_length, N])));
        corrupted_block_end = corrupted_block_start+corrupted_block_length;
        detection_signal(corrupted_block_start:corrupted_block_end) = 1;
      endif
    
      %%% Interpolation
      if(SCL_MODE(2) == 0)
        input_signal(corrupted_block_start:corrupted_block_end) = batch_interpolation( ...
          input_signal(corrupted_block_start-model_rank:corrupted_block_end+model_rank), ...
          ewls_coefficients_estimate(:,corrupted_block_start-1));
      elseif(SCL_MODE(2) == 1)
        input_signal(corrupted_block_start:corrupted_block_end) = variable_interpolation( ...
          input_signal(corrupted_block_start-model_rank:corrupted_block_end+model_rank), ...
          ewls_coefficients_estimate(:,corrupted_block_start-1), ...
          ewls_noise_variance(corrupted_block_start-1), corrupted_block_length+1);  
      endif
    endif  
    t = t + 1;    
  endwhile
  print_progress("SCL Impulse Noise Reduction", N, N, N/100);
endfunction