clear all;
close all;
clc;
output_precision(15);
max_recursion_depth(10);

%%% Reading input samples
filenames = ["../input_samples/Chopin_Etiuda_Op_25_nr_8.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_9.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_10.WAV"; "../input_samples/12.wav"]; 
[input_signal, sampling_frequency] = audioread(filenames(4,:));
%input_signal = input_signal(:,1);
%%% Preparing variables
global N = ceil(length(input_signal)/10);
global AR_model_order = 10;
global eps = 1e-12;
global lambda = 0.999;
global delta = 100;
global lambda0 = 0.998;
global mu = 4;
global max_block_length = 60;
global delay = 100;
global decimal_place = 12;

%%% Reducing impulse noise
dbstop("ImpulseNoiseReduction");
[coefficients_trajectory, noise_variance_trajectory, detection_signal, clear_signal, error_trajectory, error_threshold] = ImpulseNoiseReduction(input_signal(1:N));

%%% Writing output file
audiowrite("../output_samples/P_U_S_C_RK.wav", clear_signal, sampling_frequency);

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

figure(3);
subplot(3,1,1);
plot(input_signal(1:N));
%axis([33660 33700]);
subplot(3,1,2);
plot(detection_signal);
%axis([33660 33700]);subplot(2,1,2);
subplot(3,1,3);
plot(clear_signal);
%axis([33660 33700]);

figure(4);
subplot(3,1,1);
plot(input_signal(1:N));
axis([0 N-1]);
subplot(3,1,2);
plot(error_trajectory);
axis([0 N-1]);
hold on;
plot(error_threshold);
plot(-error_threshold);
axis([0 N-1 -0.5 0.5]);
hold off;
subplot(3,1,3);
plot(detection_signal);
axis([0 N-1]);


