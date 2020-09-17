function generate_noisy_file(input_signal)
  global input_directory input_filename frequency;
  
  noise_start = 1000;
  noise_min_spacing = 20; 
  noise_max_spacing = 800;  
  [noise, detection_ideal] =  generate_dual_artificial_noise( length(input_signal),... 
                                                              noise_start,...
                                                              noise_min_spacing,... 
                                                              noise_max_spacing);
                                                              
  noise_norm_factor = max(max(abs(noise)));
  noise /= noise_norm_factor;
  noise = noise.*abs(input_signal).*10 + mean(mean(abs(input_signal))).*5;
                                                            
  noisy_signal = input_signal+noise;
  audiowrite([input_directory, '../noise/', input_filename], noisy_signal, frequency)
endfunction
