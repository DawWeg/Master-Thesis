%%% Preparing workspace
clear all;
close all;
clc; tic(); %hack
output_precision(12);
max_recursion_depth(10);
addpath("utilities");
addpath("methods");

%%% Script parameters
% Common parameters
load_audio_start_second = 0;
load_audio_end_second = -1; %-1 for whole file
global output_directory="results/";
global ewls_lambda = 0.999;
global ewls_lambda_0 = 0.998;
global ewls_noise_variance_coupled = 1; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;
global model_rank = 10;
global mu = 4;

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


for i=1:length(filenames)

  current_file = filenames(i,:);

  [input_signal, frequency] = load_audio(current_file, load_audio_start_second, load_audio_end_second);
  input_signal = input_signal(:,1);
  %%% Executing alogorithms
  mu=6;
  [  R_U_S_T_RK_output_signal,...
     R_U_S_T_RK_detection_signal,...
     R_U_S_T_RK_residual_errors,...
     R_U_S_T_RK_activate_threshold,...
     R_U_S_T_RK_release_threshold  ] = R_U_S_T_RK(input_signal, block_size, block_shift);
  R_U_S_T_RK_threshold = [R_U_S_T_RK_activate_threshold, R_U_S_T_RK_release_threshold];
     
  mu=4;
  [  P_U_S_O_RK_output_signal,...
     P_U_S_O_RK_detection_signal,...
     P_U_S_O_RK_prediction_errors,...
     P_U_S_O_RK_activate_threshold  ] = P_U_S_O_RK(input_signal);   
  %%% Save data
  save_data(current_file, "R_U_S_T_RK",...
         [ input_signal,...
           R_U_S_T_RK_output_signal,...
           R_U_S_T_RK_detection_signal,...
           R_U_S_T_RK_residual_errors,...
           R_U_S_T_RK_activate_threshold,...
           R_U_S_T_RK_release_threshold ], 0);
         
  save_data(current_file, "P_U_S_O_RK",...
         [ input_signal,...
           P_U_S_O_RK_output_signal,...
           P_U_S_O_RK_detection_signal,...
           P_U_S_O_RK_prediction_errors,...
           P_U_S_O_RK_activate_threshold ], 0);

  %%% Saving audio files
  save_audio(current_file,"R_U_S_T_RK", R_U_S_T_RK_output_signal, frequency, 0);
  save_audio(current_file,"P_U_S_O_RK", P_U_S_O_RK_output_signal, frequency, 0);
endfor
