clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(5);

%%% Reading input samples
filenames = ["input_samples/Chopin_Etiuda_Op_25_nr_8.WAV"; "input_samples/Chopin_Etiuda_Op_25_nr_9.WAV"; "input_samples/Chopin_Etiuda_Op_25_nr_10.WAV"]; 
[input_signal, sampling_frequency] = audioread(filenames(1,:));

%%% Preparing variables
global N = ceil(length(input_signal)/20);
global AR_model_order = 5;
global eps = 1e-9;
lambda = 1;
delta = 100;

%%% Estimating model coefficients
%dbstop("BatchEstimate");
%[batch_estimate] = BatchEstimate(input_signal(1:N,:), lambda);   % takes too much time
%dbstop("RecursiveEstimate");
[recursive_estimate, noise_variance] = RecursiveEstimate(input_signal(1:N,:), lambda, delta);

%%% Plotting the results
figure(1);
subplot(5,1,1);
plot(recursive_estimate(1,:,1));
subplot(5,1,2);
plot(recursive_estimate(3,:,1));
subplot(5,1,3);
plot(recursive_estimate(5,:,1));
subplot(5,1,4);
plot(recursive_estimate(7,:,1));
subplot(5,1,5);
plot(recursive_estimate(9,:,1));

figure(2);
subplot(5,1,1);
plot(recursive_estimate(1,:,2));
subplot(5,1,2);
plot(recursive_estimate(3,:,2));
subplot(5,1,3);
plot(recursive_estimate(5,:,2));
subplot(5,1,4);
plot(recursive_estimate(7,:,2));
subplot(5,1,5);
plot(recursive_estimate(9,:,2));

figure(3);
subplot(2,1,1);
plot(noise_variance(:,1));
subplot(2,1,2);
plot(noise_variance(:,2));