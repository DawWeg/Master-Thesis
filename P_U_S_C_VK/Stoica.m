function [noise_variance, f] = Stoica (previous_noise_variance, starting_noise_variance, model_coefficients, k, f)
  f_temp = Calculate_g(k-1, f, 0, model_coefficients);
  f = [f, f_temp];
  noise_variance = previous_noise_variance + starting_noise_variance*f(k)*f(k);
endfunction