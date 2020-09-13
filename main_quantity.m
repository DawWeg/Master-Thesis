run("init.m");
global input_filename;
global frequency;

input_directory = "00_data/input_samples/clear/";
filenames = [ ...
                      "Chopin_Gavrilov_1_Bflat_clear_48.wav";...
                      "Chopin_Gavrilov_1_Bflat_clear.wav";...
                      "Chopin_Gavrilov_2_Dflat_clear.wav";...
                      "Chopin_Gavrilov_4_Fsharp_clear.wav";...
                    ]; 
% Prepare testing signal
input_filename = filenames(1,:); seconds_start = 0; seconds_end = 10;
[input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
    
noise_start = 1000;
noise_min_spacing = 10; noise_max_spacing = 1000;  
[noise, detection_ideal] =  generate_dual_artificial_noise( length(input_signal),... 
                                                            noise_start,...
                                                            noise_min_spacing,... 
                                                            noise_max_spacing);%5

input_norm_factor = 1/max(max(input_signal));
noise_norm_factor = 1/max(max(noise));
noise_scale_factor = noise_norm_factor/input_norm_factor;
noise *= noise_scale_factor;                                                            
noisy_signal = input_signal+noise;

[dir, name, ext] = fileparts(input_filename);
output_directory =  ["00_data/output_samples/" name "/"];
mkdir(output_directory);

save_audio("NOISY", noisy_signal, 0);
save_audio("CLEAR", input_signal, 0);

VAR_BIDI_ImpulseNoiseReduction(noisy_signal);
SCL_BIDI_ImpulseNoiseReduction(noisy_signal);

f_noisy     = [ output_directory 'audio/NOISY_' name ext];
f_clear     = [ output_directory 'audio/CLEAR_' name ext];
f_scl_f     = [ output_directory 'audio/SCL_F_' name ext];
f_scl_b     = [ output_directory 'audio/SCL_B_' name ext];
f_scl_fb    = [ output_directory 'audio/SCL_FB_' name ext];
f_scl_fbb   = [ output_directory 'audio/SCL_FBB_' name ext];
f_scl_fbf   = [ output_directory 'audio/SCL_FBF_' name ext];
f_var_f     = [ output_directory 'audio/VAR_F_' name ext];
f_var_b     = [ output_directory 'audio/VAR_B_' name ext];
f_var_fb    = [ output_directory 'audio/VAR_FB_' name ext];
f_var_fbb   = [ output_directory 'audio/VAR_FBB_' name ext];
f_var_fbf   = [ output_directory 'audio/VAR_FBF_' name ext];
%printf("Quantity analysis...\n");

%[ scl_total_alarms_ideal,...
%  scl_total_alarms_est,...
%  scl_energy_based_indicator,...
%  scl_similarity_based_indicator ] = dual_channel_quantity_test( noise, detection_ideal, scl_detection_signal );
%[ var_total_alarms_ideal,...
%  var_total_alarms_est,...
%  var_energy_based_indicator,...
%  var_similarity_based_indicator ] = dual_channel_quantity_test( noise, detection_ideal, var_detection_signal' );

%start = 0.1*frequency;
%finish = 0.2*frequency;

odg.clear    = PQevalAudio (f_clear, f_clear);
odg.noisy    = PQevalAudio (f_clear, f_noisy);

odg.scl_f    = PQevalAudio (f_clear, f_scl_f);
odg.scl_b    = PQevalAudio (f_clear, f_scl_b);
odg.scl_fb   = PQevalAudio (f_clear, f_scl_fb);
odg.scl_fbb  = PQevalAudio (f_clear, f_scl_fbb);
odg.scl_fbf  = PQevalAudio (f_clear, f_scl_fbf);

odg.var_f    = PQevalAudio (f_clear, f_var_f);
odg.var_b    = PQevalAudio (f_clear, f_var_b);
odg.var_fb   = PQevalAudio (f_clear, f_var_fb);
odg.var_fbb  = PQevalAudio (f_clear, f_var_fbb);
odg.var_fbf  = PQevalAudio (f_clear, f_var_fbf);

save("-text", [output_directory, "PEAQ_Report.txt"], "odg");
disp(odg);
