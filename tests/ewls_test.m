clear all;
close all;
clc;
tic;
addpath("utilities");


samples = 1000;
coefficients_correct = [0.2 -0.3 0.4 -0.5]';
model_rank = length(coefficients_correct);
coefficients_estimated = zeros(model_rank, 1);
noise_variance = 0;

global ewls_lambda = 0.999;
global ewls_lambda_0 = 0.998;
global ewls_noise_variance_coupled = 1; % 1=coupled | other=decoupled
input_noise = randn(samples, 1);
input_signal = ar_output(input_noise, coefficients_correct);
output_signal = zeros(samples, 1);

noise_variance_trajectory = zeros(samples,1);
coefficients_estimated_trajectory = zeros(model_rank, samples);
error_trajectory = zeros(samples,1);

regression = zeros(model_rank,1);
covariance_matrix = 100*eye(model_rank);


for i=2:samples
  regression = [input_signal(i-1) ; regression(1:end-1)];

[coefficients_estimated, covariance_matrix, error, noise_variance] = ewls_step( ...
          input_signal(i), ...
          regression, ...
          covariance_matrix, ...
          coefficients_estimated, ...
          noise_variance);

  coefficients_estimated_trajectory(:, i) = coefficients_estimated;
  noise_variance_trajectory(i) = noise_variance;
  error_trajectory(i) = error;  
endfor

%output_signal = ar_output_coef_traj(randn(samples,1).*noise_variance_trajectory, coefficients_estimated_trajectory);
%output_signal = ar_output(randn(samples,1).*noise_variance_trajectory, coefficients_estimated_trajectory(:,samples));
output_signal = ar_output(randn(samples, 1).*sqrt(noise_variance_trajectory), coefficients_estimated_trajectory(:,end));
figure(1)
subplot(3,1,1); 
plot(input_signal); ylim([min(input_signal), max(input_signal)]);
title('Input Signal:');
subplot(3,1,2); 
plot(output_signal); ylim([min(input_signal), max(input_signal)]);
title('Output Signal:');
subplot(3,1,3);
plot(error_trajectory);
title('Error:');
 
 
figure(2);
plot(coefficients_estimated_trajectory'); hold on;
plot((coefficients_correct.*ones(size(coefficients_estimated_trajectory)))'); hold off; 
grid on;
ylim([min(coefficients_correct)*1.1, max(coefficients_correct)*1.1]);
title('Coefficients:');

