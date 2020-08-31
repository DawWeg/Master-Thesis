run("init.m");
source("06_vector_extension/vector_utils.m");
source("06_vector_extension/var_kalman.m");

[samples_clear, frequency] = audioread("00_data/test_samples/Numer 6.wav");
start = round(30*44100);
finish = round(30.5*44100);
samples_clear = samples_clear(start:finish,:);

N=length(samples_clear);
[noise, detection_ideal] =  generate_dual_artificial_noise(N, 1000, 10, 1000);

noisy_signal = samples_clear+noise;

[ clear_signal,...
  detection_est,...
  error,...
  variance ] = VAR_ImpulseNoiseReduction(noisy_signal);
  

dual_channel_quantity_test( noise, detection_ideal, detection_est' );