%%% Preparing workspace
clear all;
close all;
clc;
tic;
output_precision(12);
max_recursion_depth(10);
pkg load signal;

%%% Generating autoregressive process
N = 10000;
load("random_noise.mat");
process_poles = [0.7; 0.7; 0.6; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; 0.0; -0.1; -0.6];
process_rank = length(process_poles);
process_coefficients = real(poly(process_poles));
process_coefficients = process_coefficients(:);
process_regression_vector = zeros(process_rank, 1);
process_output = zeros(N, 1);
for t = 2:N
  process_regression_vector = [process_output(t-1); process_regression_vector(1:end-1)];
  process_output(t) = -process_coefficients(2:end)'*process_regression_vector + random_noise(t);
endfor

%%% Estimating process coefficients
ewls_delta = 100;
ewls_lambda = 1;
ewls_regression_vector = zeros(process_rank, 1);
ewls_coefficients_estimate = zeros(process_rank, N);
ewls_error = zeros(N, 1);
ewls_covariance_matrix = ewls_delta*eye(process_rank);

model_regression_vector = zeros(process_rank, 1);
model_output = zeros(N, 1);
model_error = zeros(N, 1);
for t = 2:N
  ewls_regression_vector = [process_output(t-1); ewls_regression_vector(1:end-1)];
  temp = ewls_regression_vector'*ewls_covariance_matrix;
  ewls_gain_vector = (ewls_covariance_matrix*ewls_regression_vector)/(ewls_lambda + temp*ewls_regression_vector);
  ewls_covariance_matrix = (1/ewls_lambda)*(ewls_covariance_matrix - ewls_gain_vector*temp);
  ewls_error(t) = process_output(t) - ewls_regression_vector'*ewls_coefficients_estimate(:,t-1);
  ewls_coefficients_estimate(:,t) = ewls_coefficients_estimate(:,t-1) + ewls_gain_vector*ewls_error(t);
  if(!check_stability(ewls_coefficients_estimate(:,t), process_rank) && t > process_rank*10)
    printf("Yikes on: %d\n", t);
  endif
  model_regression_vector = [model_output(t-1); model_regression_vector(1:end-1)];
  model_output(t) = ewls_coefficients_estimate(:,t)'*model_regression_vector + ewls_error(t);  
  model_error(t) = process_output(t) - model_output(t);
endfor

%%% Printing results
figure(1);
zplane([], process_poles);

figure(2);
subplot(3,1,1);
plot(process_output);
subplot(3,1,2);
plot(model_output);
subplot(3,1,3);
plot(model_error);

figure(3);
for i = 1:10
subplot(5,2,i);
plot(ewls_coefficients_estimate(i,:));
hold on;
plot(-process_coefficients(i+1)*ones(N,1));
hold off;
endfor



