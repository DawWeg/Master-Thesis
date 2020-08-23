% Clear workspace
clear all;
%close all;
clc;
tic;

% Add dependencies
addpath("utilities");
addpath("methods");
addpath("01_identification");
addpath("02_model_stability");
addpath("03_detection");
addpath("04_interpolation");

% Set workspace parameters

global output_directory="00_data/output_samples/";
global input_directory="00_data/input_samples/";
global max_corrupted_block_length = 100;
global decimal_accuracy = 12;
output_precision(decimal_accuracy);
max_recursion_depth(10);

% Algorithm parameters
%%% Signal model
global model_rank = 10;

%%% EWLS
global ewls_lambda = 0.997;
global ewls_lambda_0 = 0.996;
global ewls_noise_variance_coupled = 0; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;

%%% Detection
global mu = 4.5;
global detection_delay = 10*model_rank;


% Input filenames
global filenames = [ ...
                      "Chopin_Etiuda_Op_25_nr_8.WAV";...
                      "Chopin_Etiuda_Op_25_nr_9.WAV";...
                      "Chopin_Etiuda_Op_25_nr_10.WAV";...
                      "12.wav" ...
                    ]; 