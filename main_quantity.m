run("init.m");
source("06_vector_extension/vector_utils.m");
source("06_vector_extension/var_kalman.m");
global SCL_MODE = [1; 1];
global BIDI_MODE = [2; 0; 2; 2];
input_directory = "00_data/input_samples/clear/";
filenames = [ ...
                      "Chopin_Gavrilov_1_Bflat_clear_48.wav";...
                      "Chopin_Gavrilov_1_Bflat_clear.wav";...
                      "Chopin_Gavrilov_2_Dflat_clear.wav";...
                      "Chopin_Gavrilov_4_Fsharp_clear.wav";...
                    ]; 
% Prepare testing signal
current_file = filenames(1,:);
seconds_start = 0;
seconds_end = 5;
[input_signal, frequency] = load_audio(current_file, seconds_start, seconds_end);    
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


%[fb_clear_signal, fb_detection_signal] = SCL_BIDI_ImpulseNoiseReduction (noisy_signal);

printf("Quantity analysis...\n");

[ scl_total_alarms_ideal,...
  scl_total_alarms_est,...
  scl_energy_based_indicator,...
  scl_similarity_based_indicator ] = dual_channel_quantity_test( noise, detection_ideal, scl_detection_signal );
[ var_total_alarms_ideal,...
  var_total_alarms_est,...
  var_energy_based_indicator,...
  var_similarity_based_indicator ] = dual_channel_quantity_test( noise, detection_ideal, var_detection_signal' );
%dual_channel_quantity_test( noise, detection_ideal, fb_detection_signal );

save_audio(current_file, "Noisy", noisy_signal, frequency, 0);
save_audio(current_file, "SCL", scl_clear_signal, frequency, 0);
save_audio(current_file, "Clear", input_signal, frequency, 0);
save_audio(current_file, "VAR", var_clear_signal', frequency, 0);
%save_audio(current_file, "FB", fb_clear_signal', frequency, 0);


f_noisy   = [ '00_data/output_samples/Noisy_' current_file ];
f_scl_result   = [ '00_data/output_samples/SCL_' current_file ];
f_var_result   = [ '00_data/output_samples/VAR_' current_file ];
f_clean    = [ '00_data/output_samples/Clear_' current_file];


Fs = frequency;
StartS  = Fs*seconds_start;
EndS    = seconds_end*Fs;

ODG1    = PQevalAudio (f_clean, f_noisy); %, StartS, EndS);
ODG2    = PQevalAudio (f_clean, f_scl_result); %, StartS, EndS);
ODG3    = PQevalAudio (f_clean, f_var_result); %, StartS, EndS);

printf("SCL_L -> TAI: %d | TAD: %d | EBI: %d | SBI: %d\n",...
  scl_total_alarms_ideal(1),...
  scl_total_alarms_est(1),...
  scl_energy_based_indicator(1),...
  scl_similarity_based_indicator(1));
printf("SCL_R -> TAI: %d | TAD: %d | EBI: %d | SBI: %d\n",...
  scl_total_alarms_ideal(2),...
  scl_total_alarms_est(2),...
  scl_energy_based_indicator(2),...
  scl_similarity_based_indicator(2));
 
printf("VAR_L -> TAI: %d | TAD: %d | EBI: %d | SBI: %d\n",...
  var_total_alarms_ideal(1),...
  var_total_alarms_est(1),...
  var_energy_based_indicator(1),...
  var_similarity_based_indicator(1));
printf("VAR_R -> TAI: %d | TAD: %d | EBI: %d | SBI: %d\n",...
  var_total_alarms_ideal(2),...
  var_total_alarms_est(2),...
  var_energy_based_indicator(2),...
  var_similarity_based_indicator(2));

printf("ODG-> Noisy: %d | SCL: %d | VAR: %d\n", ODG1, ODG2, ODG3);
