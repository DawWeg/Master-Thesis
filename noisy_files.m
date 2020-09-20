run("init.m");
global input_filename;
global frequency;
org_input_directory = input_directory;

do_peaq = 1;
do_peaq_process = 1;
do_peaq_analysis = 0;

do_normal = 0;
do_normal_process = 1;
execution_error_log = [];

filenames_excludes = [ ...
  "chopin_gavrilov_1.wav";...
  "chopin_gavrilov_2.wav";...
  "chopin_gavrilov_3.wav";...
  "classical_1.wav";...
  "clearday.wav";...
  "energy.wav";...
  "funnysong.wav";...
  "guitar_1.wav";...
  "guitar_2.wav";...
  "hipjazz.wav";...
  "inspire.wav";...
  "theelevatorbossanova.wav";...
  "thejazzpiano.wav";
];
exclude_length = size(filenames_excludes,1);
input_directory = [input_directory, 'clear/' ];
energy = [];
for i=1:exclude_length
  seconds_start = 0; seconds_end = 10;
  input_filename = filenames_excludes(i,:);
  [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
  samples = length(input_signal);
  energy = [energy; sum(input_signal.^2)./(length(input_signal))];
  
  printf("%s : %d : %d : %d\n", input_filename, samples, energy(i,1), energy(i, 2) );
  
endfor

printf("===============\n");

mean_energy = mean(mean(energy))
new_energy = [];

printf("===============\n");
for i=1:exclude_length
  seconds_start = 0; seconds_end = 10;
  input_filename = filenames_excludes(i,:);
  [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
  samples = length(input_signal);
  energy = sum(input_signal.^2)./(length(input_signal));
  max_file_energy = max(energy)
  norm_factor = sqrt(mean_energy/max_file_energy)
  input_signal = input_signal.*norm_factor;
  new_energy = [new_energy; sum(input_signal.^2)./(length(input_signal))];
  printf("%s : %d : %d : %d\n", input_filename, samples, new_energy(i,1), new_energy(i, 2) );
  save_audio("CLEAR_", input_signal, 0, 1);
endfor



noise_start = 1000;
noise_min_spacing = 10; 
noise_max_spacing = 400;  
[noise, detection_ideal] =  generate_dual_artificial_noise( length(input_signal),... 
                                                            noise_start,...
                                                            noise_min_spacing,... 
                                                            noise_max_spacing);
                   
noise = noise.*0.8;                   
avg_energy = ((sum(noise.^2)./(length(noise)))./mean_energy).*100
total_noise_samples = sum(abs(noise) > 0 );
(total_noise_samples./480000).*100

input_directory = [ '00_data/output_samples/audio/' ];
for i=1:exclude_length
  seconds_start = 0; seconds_end = 10;
  input_filename = filenames_excludes(i,:);
  [input_signal, frequency] = load_audio(['CLEAR__', input_filename], seconds_start, seconds_end);
  save_audio("CLEAR_SHORT", input_signal( 48000:48000+48000, :), 0, 1);
  input_signal = input_signal + noise;
  save_audio("NOISY_", input_signal, 0, 1);
  
  save_audio("NOISY_SHORT", input_signal( 48000:48000+48000, :), 0, 1);
endfor


for i=1:exclude_length
  seconds_start = 0; seconds_end = 10;
  input_filename = filenames_excludes(i,:);

  f_noisy     = strtrim([ output_directory 'audio/NOISY_SHORT_' input_filename]);
  f_clear     = strtrim([ output_directory 'audio/CLEAR_SHORT_' input_filename]);

  odg.noisy    = PQevalAudio (f_clear, f_noisy);
  disp(odg)
endfor

