run("init.m");
source("06_vector_extension/vector_utils.m");
source("06_vector_extension/var_kalman.m");
global SCL_MODE = [1; 1];
global BIDI_MODE = [2; 0; 2; 2];
input_directory = "00_data/input_samples/clear/";
filenames = [ ...
                      "Chopin_Gavrilov_1_Bflat_clear.wav";...
                      "Chopin_Gavrilov_2_Dflat_clear.wav";...
                      "Chopin_Gavrilov_4_Fsharp_clear.wav";...
                    ]; 
% Prepare testing signal
current_file = filenames(1,:);

[input_signal, frequency] = load_audio(current_file, 0, 10);    
noise_start = 1000;
noise_min_spacing = 10; noise_max_spacing = 1000;  
[noise, detection_ideal] =  generate_dual_artificial_noise( length(input_signal),... 
                                                            noise_start,...
                                                            noise_min_spacing,... 
                                                            noise_max_spacing);
noisy_signal = input_signal+noise;

% Scalar model
printf("Scalar model analysis...\n");
scl_clear_signal = zeros(size(input_signal));
scl_detection_signal = zeros(size(input_signal));
[scl_clear_signal(:,1), scl_detection_signal(:,1)] = SCL_ImpulseNoiseReduction(noisy_signal(:,1));
[scl_clear_signal(:,2), scl_detection_signal(:,2)] = SCL_ImpulseNoiseReduction(noisy_signal(:,2));

% VAR model
printf("VAR model analysis...\n");
[ var_clear_signal,...
  var_detection_signal,...
  var_error,...
  var_variance ] = VAR_ImpulseNoiseReduction(noisy_signal);


[fb_clear_signal, fb_detection_signal] = SCL_BIDI_ImpulseNoiseReduction (noisy_signal);

printf("Quantity analysis...\n");

dual_channel_quantity_test( noise, detection_ideal, scl_detection_signal );
dual_channel_quantity_test( noise, detection_ideal, var_detection_signal' );
dual_channel_quantity_test( noise, detection_ideal, fb_detection_signal );

save_audio(current_file, "Noisy", noisy_signal, frequency, 0);
save_audio(current_file, "SCL", scl_clear_signal, frequency, 0);
save_audio(current_file, "VAR", var_clear_signal', frequency, 0);
save_audio(current_file, "FB", fb_clear_signal', frequency, 0);






