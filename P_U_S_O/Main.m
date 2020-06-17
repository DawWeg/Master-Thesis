clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(5);

%%% Reading input samples
filenames = ["../input_samples/Chopin_Etiuda_Op_25_nr_8.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_9.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_10.WAV"; "../input_samples/12.wav"]; 
[input_signal, sampling_frequency] = audioread(filenames(4,:));

%%% Preparing variables
global N = ceil(length(input_signal)/5);
global AR_model_order = 10;
global eps = 1e-9;
global lambda = 0.999;
global delta = 100;
global lambda0 = 0.998;

%%% Reducing impulse noise
%dbstop("ImpulseNoiseReduction");
[coefficients_trajectory, noise_variance_trajectory, detection_signal] = ImpulseNoiseReduction(input_signal(1:N));

%%% Printing results
figure(1);
subplot(5,2,1);
plot(coefficients_trajectory(1,:));
subplot(5,2,2);
plot(coefficients_trajectory(2,:));
subplot(5,2,3);
plot(coefficients_trajectory(3,:));
subplot(5,2,4);
plot(coefficients_trajectory(4,:));
subplot(5,2,5);
plot(coefficients_trajectory(5,:));
subplot(5,2,6);
plot(coefficients_trajectory(6,:));
subplot(5,2,7);
plot(coefficients_trajectory(7,:));
subplot(5,2,8);
plot(coefficients_trajectory(8,:));
subplot(5,2,9);
plot(coefficients_trajectory(9,:));
subplot(5,2,10);
plot(coefficients_trajectory(10,:));

figure(2);
plot(noise_variance_trajectory);
