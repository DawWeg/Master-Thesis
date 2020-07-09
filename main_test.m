%%% Preparing workspace
clear all;
close all;
clc;
tic;

output_precision(12);
max_recursion_depth(10);
addpath("utilities");
addpath("methods");

%%% Script parameters
% Common parameters
should_plot = 1;
should_save_audio = 1;
load_audio_start_second = 0;
load_audio_end_second = 3; %-1 for whole file
global output_directory="output_samples/";
global ewls_lambda = 0.999;
global ewls_lambda_0 = 0.998;
global ewls_noise_variance_coupled = 1; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;
global model_rank = 10;
global mu = 4;

% Prediction methods exclusive parameters
global max_corrupted_block_length = 50;
global detection_delay = 10*model_rank;
global decimal_accuracy = 12;

%%% Reading input samples
filenames = [ ...
              "Chopin_Etiuda_Op_25_nr_8.WAV";...
              "Chopin_Etiuda_Op_25_nr_9.WAV";...
              "Chopin_Etiuda_Op_25_nr_10.WAV";...
              "12.wav" ...
            ]; 
current_file = filenames(1,:);

[input_signal, frequency] = load_audio(current_file, load_audio_start_second, load_audio_end_second);
input_signal = input_signal';

dbstop("P_U_V_C_VK");
[coefficients_trajectory, error_trajectory, model_output] = P_U_V_C_VK(input_signal); 

figure(1);
subplot(2,2,1);
plot(input_signal(1,:));
subplot(2,2,2);
plot(input_signal(2,:));
subplot(2,2,3);
plot(model_output(1,:));
subplot(2,2,4);
plot(model_output(2,:));

save_audio(current_file, "modeling", model_output', frequency, 1);