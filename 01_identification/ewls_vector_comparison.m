run("init.m");


N = 500;
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
coefficients = zeros(size(theta));
covariance_matrix = 100*Ir;
noise_variance = zeros(2,2);
regression = zeros(2*model_rank, N);
regression_m = zeros(2*model_rank, N);

input_signal = y_v;
theta_trajectory_recu = zeros(16,N);
gain_trajectory_recu = zeros(2*model_rank,N);
error_trajectory_recu = zeros(size(input_signal));
noise_variance_trajectory_recu = zeros(2,2,N);


theta_trajectory_iter = zeros(16,N);
gain_trajectory_iter = zeros(2*model_rank,N);
error_trajectory_iter = zeros(size(input_signal));
noise_variance_trajectory_iter = zeros(2,2,N);

for t=2:N
  print_progress("EWLS Comparison", t, N, N/100);
  regression(:,t) = [input_signal(:,t-1); regression(1:end-2, t-1)];
  
  [coefficients, covariance_matrix, error, noise_variance] = ewls_vector_recursive(
          input_signal(:,t), ...
          regression(:,t), ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance);
 
  
  theta_trajectory_recu(:,t) = coefficients; 
  error_trajectory_recu(:,t) = error;
  noise_variance_trajectory_recu(:,:,t) = noise_variance;
  
  phi = [regression(:,t), zeros(2*model_rank, 1); zeros(2*model_rank, 1), regression(:,t)];
  
  error_trajectory_iter(:,t) = input_signal(:, t) - phi' *theta_trajectory_iter(:,t-1);
  theta_trajectory_iter(:,t) = ewls_vector_batch(input_signal, regression, t);; 
  noise_variance_trajectory_iter(:,:,t) = ewls_vector_batch_noise_variance(...
          input_signal, regression,...
          theta_trajectory_iter, error_trajectory_iter, t);
endfor
print_progress("EWLS Comparison", N, N, N/100);


figure(1);
subplot(2,1,1); plot(error_trajectory_recu(1,:)'); grid on;
subplot(2,1,2); plot(error_trajectory_iter(1,:)'); grid on;

figure(2);
subplot(2,1,1); plot(error_trajectory_recu(2,:)'); grid on;
subplot(2,1,2); plot(error_trajectory_iter(2,:)'); grid on;


figure(3);
subplot(2,1,1); plot(squeeze(noise_variance_trajectory_recu(1,1,:))'); ylim([0, 1.5]); grid on;  
subplot(2,1,2); plot(squeeze(noise_variance_trajectory_iter(1,1,:))'); ylim([0, 1.5]); grid on;

figure(4);
subplot(2,1,1); plot(squeeze(noise_variance_trajectory_recu(2,2,:))'); grid on;
subplot(2,1,2); plot(squeeze(noise_variance_trajectory_iter(2,2,:))'); grid on;

figure(5);
subplot(2,1,1); plot(abs(theta_trajectory_recu' -(ones(size(theta_trajectory_recu)).*theta)')); ylim([0, 1]); 
 grid on;
subplot(2,1,2); plot(abs(theta_trajectory_iter' -(ones(size(theta_trajectory_iter)).*theta)')); ylim([0, 1]); 
 grid on;

figure(6);
plot(abs(theta_trajectory_recu' - theta_trajectory_iter')); ylim([0, 0.1]); 
grid on;

figure(7);
subplot(2,1,1); plot(abs(error_trajectory_recu(1,:)'-error_trajectory_iter(1,:)')); ylim([0, 0.1]); grid on;
subplot(2,1,2); plot(abs(error_trajectory_recu(2,:)'-error_trajectory_iter(2,:)')); ylim([0, 0.1]); grid on;

figure(8);
a = squeeze(noise_variance_trajectory_recu(1,1,:))';
b = squeeze(noise_variance_trajectory_iter(1,1,:))';
c = squeeze(noise_variance_trajectory_recu(2,2,:))';
d = squeeze(noise_variance_trajectory_iter(2,2,:))';
subplot(2,1,1); plot(abs(a-b)); ylim([0, 0.1]); grid on;
subplot(2,1,2); plot(abs(c-d)); ylim([0, 0.1]); grid on;