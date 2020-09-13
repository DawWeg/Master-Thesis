function [clear_signal_fb, clear_signal_f, clear_signal_b, clear_signal_fbf, clear_signal_fbb] = SCL_BIDI_ImpulseNoiseReduction (input_signal)
  
  global model_rank;
  
  %%% Forward analysis
  N = length(input_signal);
  clear_signal_f = zeros(N,2);
  detection_signal_f = zeros(N,2);
  ewls_error_trajectory_f = zeros(N,2);
  ewls_noise_variance_f = zeros(N,2);

  [clear_signal_f(:,1), ...
   detection_signal_f(:,1), ...
   ewls_error_trajectory_f(:,1), ~, ~, ...
   ewls_noise_variance_f(:,1)] = SCL_ImpulseNoiseReduction(input_signal(:,1));
 
  [clear_signal_f(:,2), ...
   detection_signal_f(:,2), ...
   ewls_error_trajectory_f(:,2), ~, ~, ... 
   ewls_noise_variance_f(:,2)] = SCL_ImpulseNoiseReduction(input_signal(:,2));
   
   save("-binary", get_data_save_filename("SCL_F"), "clear_signal_f", "detection_signal_f", "ewls_error_trajectory_f", "ewls_noise_variance_f");
   save_audio("SCL_F", clear_signal_f, 0);
   clear ewls_error_trajectory_f;

  %%% Backward analysis
  clear_signal_b = zeros(N,2);
  detection_signal_b = zeros(N,2);
  ewls_error_trajectory_b = zeros(N,2);
  ewls_noise_variance_b = zeros(N,2);

  [clear_signal_b(:,1), ...
   detection_signal_b(:,1), ...
   ewls_error_trajectory_b(:,1), ~, ~, ...
   ewls_noise_variance_b(:,1)] = SCL_ImpulseNoiseReduction(flip(input_signal(:,1)));
 
  [clear_signal_b(:,2), ...
   detection_signal_b(:,2), ...
   ewls_error_trajectory_b(:,2), ~, ~, ...
   ewls_noise_variance_b(:,2)] = SCL_ImpulseNoiseReduction(flip(input_signal(:,2)));
 
  clear_signal_b = flip(clear_signal_b,1);
  detection_signal_b = flip(detection_signal_b,1);
  ewls_error_trajectory_b = flip(ewls_error_trajectory_b,1);
  ewls_noise_variance_b = flip(ewls_noise_variance_b,1);
  
  save("-binary", get_data_save_filename("SCL_B"), "clear_signal_b", "detection_signal_b", "ewls_error_trajectory_b", "ewls_noise_variance_b");
  save_audio("SCL_B", clear_signal_b, 0);
  clear ewls_error_trajectory_b;  
  
  %%% Merging alarms
  detection_signal_fb = zeros(size(detection_signal_f));  
  detection_signal_fb(:,1) = merge_alarms_2(detection_signal_f(:,1), detection_signal_b(:,1));
  detection_signal_fb(:,2) = merge_alarms_2(detection_signal_f(:,2), detection_signal_b(:,2));
  
  clear detection_signal_f detection_signal_b;
  
  %%% Forward analysis with merged detection signal
  clear_signal_fbf = zeros(N,2);
  detection_signal_fbf = zeros(N,2);
  ewls_error_trajectory_fbf = zeros(N,2);
  ewls_noise_variance_fbf = zeros(N,2);
  ewls_coefficients_estimate_fbf = zeros(model_rank,N,2);
  
  [clear_signal_fbf(:,1), ...
   detection_signal_fbf(:,1), ...
   ewls_error_trajectory_fbf(:,1), ~, ...
   ewls_coefficients_estimate_fbf(:,:,1), ...
   ewls_noise_variance_fbf(:,1)] = SCL_ImpulseNoiseReduction(input_signal(:,1), detection_signal_fb(:,1));
   
  [clear_signal_fbf(:,2), ...
   detection_signal_fbf(:,2), ...
   ewls_error_trajectory_fbf(:,2), ~, ...
   ewls_coefficients_estimate_fbf(:,:,2), ...
   ewls_noise_variance_fbf(:,2)] = SCL_ImpulseNoiseReduction(input_signal(:,2), detection_signal_fb(:,2));
   
   save("-binary", get_data_save_filename("SCL_FBF"), "clear_signal_fbf", "detection_signal_fbf", "ewls_error_trajectory_fbf", "ewls_noise_variance_fbf");
   save_audio("SCL_FBF", clear_signal_fbf, 0);
   clear detection_signal_fbf ewls_error_trajectory_fbf ewls_coefficients_estimate_fbf;
   
  %%% Backward analysis with merged detection signal
  clear_signal_fbb = zeros(N,2);
  detection_signal_fbb = zeros(N,2);
  ewls_error_trajectory_fbb = zeros(N,2);
  ewls_noise_variance_fbb = zeros(N,2);
  ewls_coefficients_estimate_fbb = zeros(model_rank,N,2);
  
  [clear_signal_fbb(:,1), ...
   detection_signal_fbb(:,1), ...
   ewls_error_trajectory_fbb(:,1), ~, ...
   ewls_coefficients_estimate_fbb(:,:,1), ...
   ewls_noise_variance_fbb(:,1)] = SCL_ImpulseNoiseReduction(flip(input_signal(:,1)), flip(detection_signal_fb(:,1)));
   
  [clear_signal_fbb(:,2), ...
   detection_signal_fbb(:,2), ...
   ewls_error_trajectory_fbb(:,2), ~, ...
   ewls_coefficients_estimate_fbb(:,:,2), ...
   ewls_noise_variance_fbb(:,2)] = SCL_ImpulseNoiseReduction(flip(input_signal(:,2)), flip(detection_signal_fb(:,2)));
  
  clear_signal_fbb = flip(clear_signal_fbb,1);
  detection_signal_fbb = flip(detection_signal_fbb,1);
  ewls_error_trajectory_fbb = flip(ewls_error_trajectory_fbb,1);
  ewls_noise_variance_fbb = flip(ewls_noise_variance_fbb,1);
  
  save("-binary", get_data_save_filename("SCL_FBB"), "clear_signal_fbb", "detection_signal_fbb", "ewls_error_trajectory_fbb", "ewls_noise_variance_fbb");
  save_audio("SCL_FBB", clear_signal_fbb, 0);
  clear detection_signal_fbf ewls_error_trajectory_fbf ewls_coefficients_estimate_fbb;
  
  %%% Bidirectional interpolation  
  clear_signal_fb = clear_signal_f;
  [clear_signal_fb(:,1)] = bidirectional_interpolation(detection_signal_fb(:,1), ...
                                                clear_signal_fbf(:,1), ...
                                                clear_signal_fbb(:,1), ...
                                                input_signal(:,1), ...                                                 
                                                ewls_noise_variance_fbf(:,1), ...
                                                ewls_noise_variance_fbb(:,1));
                                                
  [clear_signal_fb(:,2)] = bidirectional_interpolation(detection_signal_fb(:,2), ...
                                                clear_signal_fbf(:,2), ...
                                                clear_signal_fbb(:,2), ...
                                                input_signal(:,2), ...                                                
                                                ewls_noise_variance_fbf(:,2), ...
                                                ewls_noise_variance_fbb(:,2));   
  
  save("-binary", get_data_save_filename("SCL_FB"), "clear_signal_fb", "detection_signal_fb");
  save_audio("SCL_FB", clear_signal_fb, 0);   
endfunction
