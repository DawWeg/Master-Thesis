%%% Preparing workspace
clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(10);
addpath("utilities");
addpath("methods");

%%% Script parameters
% Common parameters
should_plot = 1;
should_save_audio = 1;
load_audio_start_second = 0;
load_audio_end_second = 5; %-1 for whole file
global ewls_lambda = 0.999;
global ewls_lambda_0 = 0.998;
global ewls_noise_variance_coupled = 1; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;
global model_rank = 10;
global mu = 6;

% Residual methods exclusive parameters
block_size = 256;
block_shift = 128;

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
current_file = filenames(4,:);

[input_signal, frequency] = load_audio(current_file, load_audio_start_second, load_audio_end_second);

%%% Executing alogorithms
%[  R_U_S_T_RK_output_signal,...
%   R_U_S_T_RK_detection_signal,...
%   R_U_S_T_RK_residual_errors,...
%   R_U_S_T_RK_activate_threshold,...
%   R_U_S_T_RK_release_threshold  ] = R_U_S_T_RK(input_signal, block_size, block_shift);
%R_U_S_T_RK_threshold = [R_U_S_T_RK_activate_threshold, R_U_S_T_RK_release_threshold];
  
[  P_U_S_O_RK_output_signal,...
   P_U_S_O_RK_detection_signal,...
   P_U_S_O_RK_prediction_errors,...
   P_U_S_O_RK_activate_threshold  ] = P_U_S_O_RK(input_signal);   
%%% Plotting results 
if should_plot
  %plot_result(1, input_signal, R_U_S_T_RK_detection_signal, R_U_S_T_RK_output_signal);
  %plot_error_detection(2, R_U_S_T_RK_residual_errors, R_U_S_T_RK_threshold);

  plot_result(3, input_signal, P_U_S_O_RK_detection_signal, P_U_S_O_RK_output_signal);
  plot_error_detection(4, P_U_S_O_RK_prediction_errors, P_U_S_O_RK_activate_threshold);
endif

%%% Saving audio files
if should_save_audio
  %save_audio(current_file, R_U_S_T_RK_output_signal, frequency);
  save_audio(current_file, P_U_S_O_RK_output_signal, frequency);
endif






