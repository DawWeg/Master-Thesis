clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(10);

%%% Reading input samples
filenames = ["../input_samples/Chopin_Etiuda_Op_25_nr_8.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_9.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_10.WAV"; "../input_samples/12.wav"]; 
[input_signal, sampling_frequency] = audioread(filenames(4,:));
%input_signal = input_signal(:,1);

%%% Preparing variables
global N = ceil(length(input_signal)/10);
global AR_model_order = 10;
global eps = 1e-9;
global lambda = 0.999;
global delta = 1000;
global lambda0 = 0.998;
global mu = 4;
global max_block_length = 50;
global delay = 10*AR_model_order;
global decimal_place = 12;
global alarm_expand = 2;

%%% Reducing impulse noise
%dbstop("ImpulseNoiseReduction");
tic;
disp("Left-side analysis");
[l_coefficients_trajectory, l_noise_variance_trajectory, l_detection_signal, l_clear_signal, l_error_trajectory, ...
  l_error_threshold] = ImpulseNoiseReduction(input_signal(1:N));
disp("Right-side analysis");
[r_coefficients_trajectory, r_noise_variance_trajectory, r_detection_signal, r_clear_signal, r_error_trajectory, ...
  r_error_threshold] = ImpulseNoiseReduction(flip(input_signal(1:N)));
time = toc;
disp("Bidirectional analysis");
[lr_detection_signal, lr_clear_signal, lrl_clear_signal, lrr_clear_signal] = BidirectionalAnalysis(l_detection_signal, r_detection_signal);
printf("Procedure time: %d s.", time);

%%% Writing output file
audiowrite("../output_samples/P_B_S_O_RK_LEFT.wav", l_clear_signal, sampling_frequency);
audiowrite("../output_samples/P_B_S_O_RK_RIGHT.wav", flip(r_clear_signal), sampling_frequency);
audiowrite("../output_samples/P_B_S_O_RK_BI.wav", lr_clear_signal, sampling_frequency);
audiowrite("../output_samples/P_B_S_O_RK_BI_LEFT.wav", lrl_clear_signal, sampling_frequency);
audiowrite("../output_samples/P_B_S_O_RK_BI_RIGHT.wav", lrr_clear_signal, sampling_frequency);


%%% Printing results
figure(1);
subplot(5,2,1);
plot(l_coefficients_trajectory(1,:));
subplot(5,2,2);
plot(l_coefficients_trajectory(2,:));
subplot(5,2,3);
plot(l_coefficients_trajectory(3,:));
subplot(5,2,4);
plot(l_coefficients_trajectory(4,:));
subplot(5,2,5);
plot(l_coefficients_trajectory(5,:));
subplot(5,2,6);
plot(l_coefficients_trajectory(6,:));
subplot(5,2,7);
plot(l_coefficients_trajectory(7,:));
subplot(5,2,8);
plot(l_coefficients_trajectory(8,:));
subplot(5,2,9);
plot(l_coefficients_trajectory(9,:));
subplot(5,2,10);
plot(l_coefficients_trajectory(10,:));

figure(2);
subplot(5,2,1);
plot(flip(r_coefficients_trajectory(1,:)));
subplot(5,2,2);
plot(flip(r_coefficients_trajectory(2,:)));
subplot(5,2,3);
plot(flip(r_coefficients_trajectory(3,:)));
subplot(5,2,4);
plot(flip(r_coefficients_trajectory(4,:)));
subplot(5,2,5);
plot(flip(r_coefficients_trajectory(5,:)));
subplot(5,2,6);
plot(flip(r_coefficients_trajectory(6,:)));
subplot(5,2,7);
plot(flip(r_coefficients_trajectory(7,:)));
subplot(5,2,8);
plot(flip(r_coefficients_trajectory(8,:)));
subplot(5,2,9);
plot(flip(r_coefficients_trajectory(9,:)));
subplot(5,2,10);
plot(flip(r_coefficients_trajectory(10,:)));

figure(3);
subplot(3,2,1);
plot(abs(l_error_trajectory));
hold on;
plot(l_error_threshold, 'r');
hold off;
subplot(3,2,3);
plot(l_detection_signal);
subplot(3,2,5);
plot(l_noise_variance_trajectory);
subplot(3,2,2);
plot(abs(flip(r_error_trajectory)));
hold on;
plot(flip(r_error_threshold), 'r');
hold off;
subplot(3,2,4);
plot(flip(r_detection_signal));
subplot(3,2,6);
plot(flip(r_noise_variance_trajectory));

figure(4);
subplot(3,2,1);
plot(input_signal(1:N));
subplot(3,2,3);
plot(l_detection_signal);
subplot(3,2,5);
plot(l_clear_signal);
subplot(3,2,2);
plot(input_signal(1:N));
subplot(3,2,4);
plot(flip(r_detection_signal));
subplot(3,2,6);
plot(flip(r_clear_signal));

