clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(10);
addpath("utilities");

% Scrip parameters
should_plot = 1;
should_save_audio = 1;

load_audio_start_second = 0;
load_audio_end_second = -1; %-1 for whole file

global ewls_lambda = 0.999;
global ewls_lambda_0 = 0.998;
global ewls_noise_variance_coupled = 1; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;
global model_rank = 10;
global mu = 6;

%%% Reading input samples
filenames = [ ...
              "Chopin_Etiuda_Op_25_nr_8.WAV";...
              "Chopin_Etiuda_Op_25_nr_9.WAV";...
              "Chopin_Etiuda_Op_25_nr_10.WAV";...
              "12.wav" ...
            ]; 
current_file = filenames(4,:);

[input_signal, frequency, N] = load_audio(current_file, load_audio_start_second, load_audio_end_second);

[  output_signal,...
   detection_signal,...
   residual_errors,...
   activate_threshold,...
   release_threshold] = R_U_S(input_signal, 256, 128);

   
if should_plot
  plot_result(1, input_signal, detection_signal, output_signal);
  plot_error_detection(2, residual_errors, [activate_threshold, release_threshold]);
endif

if should_save_audio
  save_audio(current_file, output_signal, frequency);
endif






