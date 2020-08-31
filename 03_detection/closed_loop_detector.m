function [corrupted_block_length, kalman_state_vector] = ...
          closed_loop_detector (ewls_regression_vector, ...
          ewls_noise_variance, ...
          ewls_coefficients, ...
          input_signal)
  
  global model_rank max_corrupted_block_length mu;  
  kalman_state_vector = ewls_regression_vector;
  kalman_covariance_matrix = zeros(model_rank);
  kalman_coefficients = ewls_coefficients;
  cl_detection_signal = [1; zeros(length(input_signal),1)];
  false_positive = 0;
    
  for i = 1:length(input_signal)    
    [kalman_state_vector, ...
     kalman_covariance_matrix, ...
     kalman_coefficients, ...
     kalman_error, ...
     kalman_noise_variance] = closed_loop_detector_step( ...
                                kalman_state_vector, ...
                                kalman_covariance_matrix, ...
                                kalman_coefficients, ...
                                ewls_noise_variance, ...
                                input_signal(i));
    if(abs(kalman_error) > mu*sqrt(kalman_noise_variance))
      cl_detection_signal(i+1) = 1;
      if(cl_detection_signal(i) == 0)
        false_positive = 1;
      endif
    else
      kalman_l = mround((1/kalman_noise_variance)*kalman_covariance_matrix(:,1));         
      kalman_state_vector = mround(kalman_state_vector + kalman_l*kalman_error);
      kalman_covariance_matrix = mround(kalman_covariance_matrix - kalman_noise_variance*kalman_l*kalman_l');
    endif
    if(i == length(input_signal))
      corrupted_block_length = i+1;
      kalman_state_vector = [1; kalman_state_vector];
      break;      
    elseif(i > model_rank && max(cl_detection_signal(i:-1:i-model_rank)) == 0)     
      corrupted_block_length = i+1-model_rank;
      kalman_state_vector = [false_positive; kalman_state_vector];
      break;
    endif      
  endfor   
endfunction
