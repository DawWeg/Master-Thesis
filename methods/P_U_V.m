clear all;
close all;
clc;
tic;
addpath("utilities");
global model_rank = 10; 
global ewls_lambda = 0.999;
global ewls_lambda_0 = 0.998;
global ewls_noise_variance_coupled = 1;
global mu = 4;

% Vector AR model
[input_signal, frequency] = load_audio("Chopin_Etiuda_Op_25_nr_8.WAV", 0, 0.5);
N = length(input_signal(:,1));
input_signal = input_signal';
output_signal = input_signal;
detection_signal = zeros(size(input_signal));
theta_l = zeros(2*model_rank,1);
theta_r = zeros(2*model_rank,1);
theta = [theta_l; theta_r];

Or = zeros(2*model_rank,1);
Ir = eye(2*model_rank, 2*model_rank);
regression = zeros(2*model_rank, 1);

%ewls

coefficients = zeros(size(theta));
covariance_matrix = 100*Ir;
noise_variance = zeros(2,2);
regression = zeros(2*model_rank, 1);

theta_trajectory = zeros(length(theta),N);
gain_trajectory = zeros(2*model_rank,N);
error_trajectory = zeros(size(input_signal));
noise_variance_trajectory = zeros(2,2,N);


for t=2:N
  print_progress("Vector ", t, N, 2000);
  regression = [input_signal(:,t-1); regression(1:end-2)];
  
  [coefficients, covariance_matrix, error, noise_variance] = ewls_step_vector(
          input_signal(:,t), ...
          regression, ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance);
  
  theta_trajectory(:,t) = coefficients; 
  error_trajectory(:,t) = error;
  noise_variance_trajectory(:,:,t) = noise_variance;
  
  noise_variance_l = sqrt(noise_variance(1,1));
  noise_variance_r = sqrt(noise_variance(2,2));
  
  detection_signal(1,t) = abs(error(1)) > mu*noise_variance_l ;
  detection_signal(2,t) = abs(error(2)) > mu*noise_variance_r ;
  
  if (detection_signal(1,t))
  
  q = 2*model_rank + m;
  x_q = output_signal(:,t:-1:t-q+1);
  Oi = zeros(2*q, 2);
  Ii = eye(2,2);
%  theta_l = theta(1:2*model_rank);
%  theta_r = theta(2*model_rank+1:end);
  [Aq, Cq] = vector_generate_aq_cq(theta, q, model_rank);
endfor
print_progress("Vector EWLS", N, N, 2000);

plot_result(1, input_signal(1,:), detection_signal(1,:), output_signal(1,:));
plot_result(2, input_signal(2,:), detection_signal(2,:), output_signal(2,:));
%{
output_signal = zeros(size(input_signal));
regression = zeros(2*model_rank, 1);
for t=2:N
  print_progress("Generating output Vector EWLS", t, N, 2000);
  noise = noise_variance_trajectory(:,:,t);
  noise(1,1) = sqrt(noise(1,1));
  noise(2,2) = sqrt(noise(2,2));
  noise = noise*randn(2,1);
  regression = [output_signal(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  output_signal(:,t) = phi'*theta_trajectory(:,t) + noise;
endfor
print_progress("Generating output Vector EWLS", N, N, 2000);
%}
