run("init.m");
global input_filename;
global frequency;

input_directory = "00_data/input_samples/clear/";
filenames = [ ...
                      "Chopin_Gavrilov_1_Bflat_clear_48.wav";...
                      "Chopin_Gavrilov_2_Dflat_clear_48.wav"; ...
                      "Chopin_Gavrilov_4_Fsharp_clear_48.wav"; ... 
                      "jazz_2.wav";
                    ]; 
% Prepare testing signal
input_filename = filenames(4 ,:); seconds_start = 0; seconds_end = 10;
[input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
   
noise_start = 1000;
noise_min_spacing = 10; noise_max_spacing = 1000;  
[noise, detection_ideal] =  generate_dual_artificial_noise( length(input_signal),... 
                                                            noise_start,...
                                                            noise_min_spacing,... 
                                                            noise_max_spacing);%5%
input_norm_factor = 1/max(max(input_signal));
noise_norm_factor = 1/max(max(noise));
noise_scale_factor = noise_norm_factor/input_norm_factor;%
noise *= noise_scale_factor;                                                            
noisy_signal = input_signal+noise;

[dir, name, ext] = fileparts(input_filename);
output_directory =  ["00_data/output_samples/" name "/"];
mkdir(output_directory);

save_audio("NOISY", noisy_signal, 0);
save_audio("CLEAR", input_signal, 0);
save("-binary", get_data_save_filename("INPUT"), "input_signal", "noisy_signal");


ARSIN_ImpulseNoiseReduction(noisy_signal);
%dbstop("VAR_BIDI_ImpulseNoiseReduction");
VAR_BIDI_ImpulseNoiseReduction(noisy_signal);

%[c,d,e,v] = VAR_ImpulseNoiseReduction(noisy_signal);

SCL_BIDI_ImpulseNoiseReduction(noisy_signal);
%{
delta_f = 10000;
delta_b = 10000;
center =  144000;
range = center-delta_b:center+delta_f;


figure(1);
subplot(2,1,1); plot(c(1,range) ,'color', 'blue'); xlim([-inf inf]); hold on;
%plot(noisy_signal'(1,range), 'color', 'red'); xlim([-inf inf]); 
hold off;
subplot(2,1,2); plot(c(2,range) ,'color', 'blue'); xlim([-inf inf]); hold on;
%plot(noisy_signal'(2,range), 'color', 'red'); xlim([-inf inf]); 
hold off;
        
%{
figure(2);
subplot(2,1,1); plot(abs(e(1,range))); 
hold on; plot(mu*sqrt(v(1,range))); hold off;

xlim([-inf inf]);
subplot(2,1,2); plot(abs(e(2,range))); 
hold on; plot(mu*sqrt(v(2,range))); hold off;
xlim([-inf inf]);

##

figure(3);
subplot(2,1,1); plot(v(1,range)); xlim([-inf inf]);
subplot(2,1,2); plot(v(2,range)); xlim([-inf inf]);

figure(4);
subplot(2,1,1); plot(d(1,range)); xlim([-inf inf]); ylim([0 1.2]);
subplot(2,1,2); plot(d(2,range)); xlim([-inf inf]); ylim([0 1.2]);
%}
>>>>>>> Stashed changes
