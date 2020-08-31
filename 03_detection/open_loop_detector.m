function [corrupted_block_length] = ...
          open_loop_detector (ewls_regression_vector, ...
          ewls_noise_variance, ...
          ewls_coefficients, ...
          input_signal)
  
  global model_rank max_corrupted_block_length mu;  
  f = 0;
  ol_regression_vector = ewls_regression_vector;
  ol_noise_variance = ewls_noise_variance;
  ol_detection_signal = [1; zeros(length(input_signal)-1)];
     
  for i = 1:length(input_signal)
    [ol_output_prediction, ol_error, ol_noise_variance, f] = open_loop_detector_step(input_signal(i), ...
                                                       ewls_coefficients, ...
                                                       ol_regression_vector, ...
                                                       ol_noise_variance, ...
                                                       ewls_noise_variance, ...
                                                       i+1, ...
                                                       f); 
    ol_regression_vector = [ol_output_prediction; ol_regression_vector(1:end-1)];               
    if(abs(ol_error) > mu*sqrt(ol_noise_variance))
      ol_detection_signal(i) = 1;
    endif 
    
    if(i == length(input_signal))
      corrupted_block_length = i+1;
      break;
    elseif(i > model_rank && max(ol_detection_signal(i:-1:i-model_rank)) == 0)
      corrupted_block_length = i+1-model_rank;      
      break;
    endif    
  endfor  
endfunction
