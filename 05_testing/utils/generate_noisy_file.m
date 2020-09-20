function generate_noisy_file(input_signal)
  global input_directory input_filename frequency;
  
  noise_start = 1000;
  noise_min_spacing = 20; 
  noise_max_spacing = 2000;  
  [noise, detection_ideal] =  generate_dual_artificial_noise( length(input_signal),... 
                                                              noise_start,...
                                                              noise_min_spacing,... 
                                                              noise_max_spacing);
                                                              
  %noise_norm_factor = max(max(abs(noise)));
  %noise /= noise_norm_factor;
  %noise = noise.*abs(input_signal).*10 + mean(mean(abs(input_signal))).*5;
  %noisy_signal = input_signal+noise;
  norm_input = abs(input_signal./max(abs(input_signal)));
  norm_input_energy_weight = zeros(size(input_signal));
  for i = 101 : length(norm_input)
    norm_input_energy_weight(i,:) = sum(norm_input(i-100:i,:).^2);
  endfor
  %noise = 5.*norm_input.*noise + noise*0.5;
  noise = 5.*norm_input_energy_weight.*noise + noise*0.5;
  noisy_signal = input_signal+noise;
  
  audiowrite(strtrim([input_directory, '../noise/', input_filename]), noisy_signal, frequency)
endfunction
