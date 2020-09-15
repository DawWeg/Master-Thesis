run("init.m");
global input_filename;
global frequency;

input_directory = "00_data/input_samples/clear/";
filenames = [ ...
                      "Chopin_Gavrilov_1_Bflat_clear_48.wav";...
                      "Chopin_Gavrilov_1_Bflat_clear.wav";...
                      "Chopin_Gavrilov_2_Dflat_clear.wav";...
                      "Chopin_Gavrilov_4_Fsharp_clear.wav";...
                      "electro_1.wav";... 
                      "jazz_2.wav";...
                      "classical_1.wav";
                    ]; 
% Prepare testing signal
input_filename = filenames(1,:); seconds_start = 0; seconds_end = 15;
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
save("-binary", get_data_save_filename("INPUT"), "input_signal", "noisy_signal");

VAR_BIDI_ImpulseNoiseReduction(noisy_signal);
SCL_BIDI_ImpulseNoiseReduction(noisy_signal);
