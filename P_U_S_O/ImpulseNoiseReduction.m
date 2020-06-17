clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(5);

%%% Reading input samples
filenames = ["../input_samples/Chopin_Etiuda_Op_25_nr_8.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_9.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_10.WAV"]; 
[input_signal, sampling_frequency] = audioread(filenames(1,:));

%%% Preparing variables
global N = ceil(length(input_signal)/20);
global AR_model_order = 5;
global eps = 1e-9;
lambda = 1;
delta = 100;

%%% Estimating model coefficients

