% Clear workspace
clear all;
%close all;
clc;
tic;

% Add dependencies
run("includes.m");

% Set workspace parameters

global output_directory="00_data/output_samples/";
global input_directory="00_data/input_samples/";
global max_corrupted_block_length = 100;
global decimal_accuracy = 11;
output_precision(decimal_accuracy);
max_recursion_depth(10);

% Algorithm parameters
%%% Signal model
global model_rank = 10;

%%% EWLS
global ewls_lambda = 0.995;
global ewls_lambda_0 = 0.993;

global ewls_noise_variance_coupled = 0; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;

%%% Detection
global mu = 4.5;
global detection_delay = 10*model_rank;

%%% Bidirectional
global alarm_expand = 3;

% Input filenames
global filenames = [ ...
                      "Chopin_Etiuda_Op_25_nr_8.WAV";...
                      "Chopin_Etiuda_Op_25_nr_9.WAV";...
                      "Chopin_Etiuda_Op_25_nr_10.WAV";...
                      "12.wav" ...
                    ]; 