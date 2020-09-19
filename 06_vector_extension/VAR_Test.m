run("init.m");

N = 20000;
noise_v = randn(2,N);
y_v = zeros(2,N);

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

corrupted_block_start = 4001;
corrupted_block_pause_start = corrupted_block_start + 10;
corrupted_block_pause_end = corrupted_block_pause_start + model_rank - 1;
corrupted_block_end = corrupted_block_pause_end + 5;


for t=5:N
  regression = [y_v(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  y_v(:,t) = phi'*theta + noise_v(:,t);
endfor

clear_signal = y_v;
y_v(1,corrupted_block_start:corrupted_block_pause_start) = 10;
y_v(1,corrupted_block_pause_end:corrupted_block_end) = 10;

input_signal = y_v;

profile off;
profile clear;
profile on;

[ var_clear_signal,...
  detection,...
  error,...
  variance ] = VAR_ImpulseNoiseReduction(input_signal');
  
profile off;



x_limits = [corrupted_block_start-20 corrupted_block_end+20];
%x_limits = [-inf inf];

figure(1);
subplot(3,2,1);
plot(y_v(1,:)); grid on;  xlim(x_limits);
subplot(3,2,2);
plot(y_v(2,:)); grid on;  xlim(x_limits);
subplot(3,2,3);
plot(abs(error(1,:))); hold on;
plot(abs(error(1,:)) > mu*sqrt(variance(1,:))); hold off; grid on; 
xlim(x_limits);
subplot(3,2,4);
plot(abs(error(2,:))); hold on;
plot(abs(error(2,:)) > mu*sqrt(variance(2,:))); hold off; grid on; 
xlim(x_limits);

subplot(3,2,5);
plot(detection(1,:)); grid on; xlim(x_limits); ylim([0 1.5]);
subplot(3,2,6);
plot(detection(2,:)); grid on; xlim(x_limits); ylim([0 1.5]);

figure(2);
subplot(2,1,1);
plot(clear_signal(1,:)); hold on;
plot(var_clear_signal(1,:)); grid on; hold off;
xlim(x_limits);
subplot(2,1,2);
plot(clear_signal(2,:)); hold on;
plot(var_clear_signal(2,:)); grid on; hold off;
xlim(x_limits);
