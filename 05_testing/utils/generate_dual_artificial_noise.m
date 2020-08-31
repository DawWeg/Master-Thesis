function [noise, detection] = generate_dual_artificial_noise(signal_length, skip, min_spacing, max_spacing)
  [noise_l, detection_ideal_l] = generate_artificial_noise(signal_length, skip, min_spacing, max_spacing);
  [noise_r, detection_ideal_r] = generate_artificial_noise(signal_length, skip, min_spacing, max_spacing);

  noise = [noise_l, noise_r];
  detection= [detection_ideal_l, detection_ideal_r];
endfunction
