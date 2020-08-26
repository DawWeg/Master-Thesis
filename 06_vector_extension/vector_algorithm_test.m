run("init.m");
source("06_vector_extension/vector_utils.m");



N = 5000;
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

corrupted_block_start = 4001;
corrupted_block_pause_start = corrupted_block_start + 10;
corrupted_block_pause_end = corrupted_block_pause_start + model_rank - 1;
corrupted_block_end = corrupted_block_pause_end + 5;


for t=5:N
  regression = [y_v(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  y_v(:,t) = phi'*theta + noise_v(:,t);
endfor

clear_signals = y_v;
y_v(1,corrupted_block_start:corrupted_block_pause_start) = 10;
y_v(1,corrupted_block_pause_end:corrupted_block_end) = 10;
%ewls
coefficients = zeros(size(theta));
covariance_matrix = 100*Ir;
noise_variance = zeros(2,2);
regression = zeros(2*model_rank, N);
regression_m = zeros(2*model_rank, N);

input_signal = y_v;
theta_trajectory = zeros(16,N);
gain_trajectory = zeros(2*model_rank,N);
error_trajectory = zeros(size(input_signal));
threshold_trajectory = zeros(size(input_signal));
noise_variance_trajectory = zeros(2,2,N);

variable_clear_signal = y_v;
secondary_clear_signal = y_v;

mu = 4;
d = zeros(size(input_signal));
t = 2;
max_alarm_length = 100;


while(t <= N);
  print_progress("Interpolation VAR", t, N, N/100);
  regression(:,t) = [variable_clear_signal(:,t-1); regression(1:end-2, t-1)];
  
  [coefficients, covariance_matrix, error, noise_variance] = ewls_vector_recursive(
          variable_clear_signal(:,t), ...
          regression(:,t), ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance);
 
  theta_trajectory(:,t) = coefficients; 
  error_trajectory(:,t) = error;
  noise_variance_trajectory(:,:,t) = noise_variance;
     
  if (t > 100) 
    threshold_trajectory(1,t) = mu*sqrt(noise_variance(1,1));
    threshold_trajectory(2,t) = mu*sqrt(noise_variance(2,2));
    d(1,t) = abs(error(1)) > mu*sqrt(noise_variance(1,1));
    d(2,t) = abs(error(2)) > mu*sqrt(noise_variance(2,2));
  endif
  
  if (d(1,t) || d(2,t))
    t0 = t-1;
      
    init_cov_matrix = zeros(2*model_rank, 2*model_rank);
    theta_l = theta_trajectory(1:2*model_rank, t0);
    theta_r = theta_trajectory(2*model_rank+1:end, t0);
    theta = [theta_l, theta_r];
    tk = t0;
    state_vector = init_state_vector(variable_clear_signal, model_rank, t0);
    cov_matrix = init_cov_matrix;
    correct_samples = 0;
    alarm_length = 0;

    while (correct_samples < model_rank) && (alarm_length < max_alarm_length)
      tk = tk+1;
      
      kalman_output_prediction = theta'*state_vector;
      kalman_error = variable_clear_signal(:,tk) - kalman_output_prediction;
      state_vector = [ kalman_output_prediction; state_vector ];
      kalman_h = cov_matrix*theta;
      kalman_var = theta'*kalman_h + noise_variance_trajectory(:,:,t0);
      cov_matrix = [kalman_var, kalman_h'; kalman_h, cov_matrix];
      
      theta = [theta; zeros(2,2)];
      
      d(1,tk) = abs(kalman_error(1)) > mu*sqrt(kalman_var(1,1));
      d(2,tk) = abs(kalman_error(2)) > mu*sqrt(kalman_var(2,2));
      
      L = build_gain_vector(d(:,tk) , kalman_var, cov_matrix);
      state_vector = state_vector + L*kalman_error;
      cov_matrix = cov_matrix - L*kalman_var*L';
        
      if(d(1,tk) == 0 && d(2,tk) == 0)
        correct_samples = correct_samples + 1;
      else 
        correct_samples = 0;
      endif
      
      alarm_length = tk-t0;
      
      error_trajectory(:,tk) = kalman_error;
      threshold_trajectory(1,tk) = mu*sqrt(kalman_var(1,1));
      threshold_trajectory(2,tk) = mu*sqrt(kalman_var(2,2));
  endwhile
    [new_detection_l, false_l] =  fill_detection(d(1,t0:tk), model_rank);
    [new_detection_r, false_r] =  fill_detection(d(2,t0:tk), model_rank);
    
    if(false_l == 1)
      printf("False positive at L\n");
      d(1,t0:tk) = new_detection_l;
    endif
    
    if(false_r)
      printf("False positive at L\n");
      d(1,t0:tk) = new_detection_r;
    endif
    
    
    %{
    secondary_clear_signal(:,t0-model_rank+1:tk) = var_interpolator(...
      [theta_l, theta_r],...
      variable_clear_signal,...
      d,...
      model_rank,...
      t0,...
      tk,...
      noise_variance_trajectory(:,:,t0)...
    );
    %}
    %variable_clear_signal(:,t0-model_rank+1:tk) = retrieve_reconstruction(state_vector);
    variable_clear_signal(:,t0-model_rank+1:tk) = var_interpolator(...
      [theta_l, theta_r],...
      variable_clear_signal,...
      d,...
      model_rank,...
      t0,...
      tk,...
      noise_variance_trajectory(:,:,t0)...
    );
    
    for l=t0:tk
    theta_trajectory(:, l) = theta_trajectory(:,t0);
    endfor
    regression(:,tk) = [variable_clear_signal(:,tk)', variable_clear_signal(:,tk-1)', variable_clear_signal(:,tk-2)', variable_clear_signal(:,tk-3)']';
    t = tk;
  endif
  
  t = t + 1;  
endwhile
print_progress("Interpolation VAR", N, N, N/100);

x_limits = [corrupted_block_start-20 corrupted_block_end+20];
%x_limits = [-inf inf];

figure(1);
subplot(3,2,1);
plot(y_v(1,:)); grid on;  xlim(x_limits);
subplot(3,2,2);
plot(y_v(2,:)); grid on;  xlim(x_limits);
subplot(3,2,3);
plot(abs(error_trajectory(1,:))); hold on;
plot(threshold_trajectory(1,:)); hold off; grid on; 
xlim(x_limits);
subplot(3,2,4);
plot(abs(error_trajectory(2,:))); hold on;  
plot(threshold_trajectory(2,:)); hold off; grid on; 
xlim(x_limits);
subplot(3,2,5);
plot(d(1,:)); grid on; xlim(x_limits); ylim([0 1.5]);
subplot(3,2,6);
plot(d(2,:)); grid on; xlim(x_limits); ylim([0 1.5]);

figure(2);
subplot(2,1,1);
plot(abs(clear_signals(1,:)-variable_clear_signal(1,:))); grid on;
xlim(x_limits);
subplot(2,1,2);
plot(abs(clear_signals(2,:)-variable_clear_signal(2,:))); grid on;
xlim(x_limits);

figure(3);
subplot(2,1,1);
plot(clear_signals(1,:)); hold on;
%plot(secondary_clear_signal(1,:));
plot(variable_clear_signal(1,:)); grid on; hold off;
xlim(x_limits);
subplot(2,1,2);
plot(clear_signals(2,:)); hold on;
%plot(secondary_clear_signal(2,:));
plot(variable_clear_signal(2,:)); grid on; hold off;
xlim(x_limits);

%{
figure(1);
subplot(2,2,1);
plot(y_v(1,:)); grid on; xlim(x_limits);
subplot(2,2,2);
plot(y_v(2,:)); grid on;  xlim(x_limits);
subplot(2,2,3);
plot(variable_clear_signal(1,:)); grid on;  xlim(x_limits);
subplot(2,2,4);
plot(variable_clear_signal(2,:)); grid on;  xlim(x_limits);

figure(2);
subplot(2,1,1);
plot(abs(y_v(1,:)-variable_clear_signal(1,:))); grid on;  xlim(x_limits);
subplot(2,1,2);
plot(abs(y_v(2,:)-variable_clear_signal(2,:))); grid on;  xlim(x_limits);
%}