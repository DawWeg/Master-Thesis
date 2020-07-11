clear all;
close all;
clc;
tic;
% Vector AR model

addpath("utilities");

global model_rank = 4;  % do not change
global ewls_lambda = 1;
global ewls_lambda_0 = 0.999;



N = 10000;
noise_l = randn(N,1);
noise_r = randn(N,1); 
y_l = zeros(N,1);
y_r = zeros(N,1);

y_v = [y_l, y_r]';
noise_v = [noise_l, noise_r]';

model_rank = 4;
alfa_11 = [0.1, -0.2]'; 
alfa_12 = [-0.3, 0.4]';
alfa_13 = [0.1, -0.2]';
alfa_14 = [-0.3, 0.4]';

alfa_21 = [-0.1, 0.2]'; 
alfa_22 = [0.3, -0.3]';
alfa_23 = [-0.3, 0.1]';
alfa_24 = [0.1, -0.2]';

theta_l = [alfa_11', alfa_12', alfa_13', alfa_14']';
theta_r = [alfa_21', alfa_22', alfa_23', alfa_24']';
theta = [theta_l; theta_r];

Or = zeros(2*model_rank,1);
Ir = eye(2*model_rank, 2*model_rank);
regression = zeros(2*model_rank, 1);

for t=5:N
  regression = [y_v(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  y_v(:,t) = phi'*theta + noise_v(:,t);
endfor

%ewls
ewls_noise_variance_coupled=1;
coefficients = zeros(size(theta));
covariance_matrix = 100*Ir;
noise_variance = zeros(2,2);
regression = zeros(2*model_rank, 1);

input_signal = y_v;
theta_trajectory = zeros(16,N);
gain_trajectory = zeros(2*model_rank,N);
error_trajectory = zeros(size(input_signal));
noise_variance_trajectory = zeros(2,2,N);


for t=2:N
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
endfor


output_signal = zeros(size(input_signal));
regression = zeros(2*model_rank, 1);
for t=2:N
  %noise = noise_v(:,t);
  noise = noise_variance_trajectory(:,:,t);
  noise(1,1) = sqrt(noise(1,1));
  noise(2,2) = sqrt(noise(2,2));
  noise = noise*randn(2,1);
  regression = [output_signal(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  output_signal(:,t) = phi'*theta_trajectory(:,t) + noise;
endfor


figure(1);
subplot(3,1,1); plot(y_v(1,:)');
subplot(3,1,2); plot(error_trajectory(1,:)');
subplot(3,1,3); plot(output_signal(1,:)');

figure(2);
subplot(3,1,1); plot(y_v(2,:)');
subplot(3,1,2); plot(error_trajectory(2,:)');
subplot(3,1,3); plot(output_signal(2,:)');

figure(3);
plot(abs(theta_trajectory' -(ones(size(theta_trajectory)).*theta)'));
ylim([0, 1]); 

figure(4);
subplot(2,1,1);
plot(abs(input_signal(1,:)-output_signal(1,:))');
subplot(2,1,2);
plot(abs(input_signal(2,:)-output_signal(2,:))');