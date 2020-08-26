run("init.m");
source("06_vector_extension/vector_utils.m");

current_file = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, 0, 0.3);
input_signal = input_signal';
N = length(input_signal(1,:));

Or = zeros(2*model_rank,1);
Ir = eye(2*model_rank, 2*model_rank);

%ewls

ewls_covariance_matrix_trajectory = zeros(2*model_rank,2*model_rank,N);
for i=1:model_rank+1
  ewls_covariance_matrix_trajectory(:,:,i) = 100*Ir;
endfor


ewls_regression = zeros(2*model_rank, N);
ewls_theta_trajectory = zeros(4*model_rank,N);
ewls_error_trajectory = zeros(size(input_signal));
ewls_threshold_trajectory = zeros(size(input_signal));
ewls_noise_variance_trajectory = zeros(2,2,N);
ewls_detection = zeros(size(input_signal));
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
clear_signal = input_signal;

cl_primary_detection = zeros(size(input_signal));
cl_final_detection = zeros(size(input_signal));
cl_noise_variance_trajectory = zeros(size(ewls_noise_variance_trajectory));
cl_threshold_trajectory = zeros(size(ewls_threshold_trajectory));
cl_error_trajectory = zeros(size(ewls_threshold_trajectory));
t = model_rank+1;
max_alarm_length = 100;
skip_detection = 0;
unstable_model = 0;
while(t <= N);
  print_progress("Interpolation VAR", t, N, N/100);
  %ewls_regression(:,t) = [clear_signal(:,t-1); ewls_regression(1:end-2, t-1)];
  ewls_regression(:,t) = init_regression_vector(clear_signal, model_rank, t);
  
  [ ewls_theta_trajectory(:,t), ...
    ewls_covariance_matrix_trajectory(:,:,t), ...
    ewls_error_trajectory(:,t),  ...
    ewls_noise_variance_trajectory(:,:,t) ] = ewls_vector_recursive(...
          clear_signal(:,t), ...
          ewls_regression(:,t), ...
          ewls_covariance_matrix_trajectory(:,:,t-1), ...
          ewls_theta_trajectory(:,t-1), ...
          ewls_noise_variance_trajectory(:,:,t-1));
 
 
  
  if (t > 1000) 
    ewls_threshold_trajectory(1,t) = mu*sqrt(ewls_noise_variance_trajectory(1,1,t));
    ewls_threshold_trajectory(2,t) = mu*sqrt(ewls_noise_variance_trajectory(2,2,t));
    ewls_detection(:,t) = abs(ewls_error_trajectory(:,t)) > ewls_threshold_trajectory(:,t);
  endif
  

  
  if ((ewls_detection(1,t) || ewls_detection(2,t)) && skip_detection == 0 )
    t0 = t-1;
    
    if(check_stability_var (ewls_theta_trajectory(:,t0)) == 0)
      printf("Model ustable on: %d.\n", t0);
      ewls_theta_trajectory(:,t0) = ...
          wwr_estimation(min([ewls_equivalent_window_length, t0]), ...
          clear_signal(:,t0-(min([ewls_equivalent_window_length, t0]))+1:t0), ...
          ewls_noise_variance_trajectory(:,:,t0-1));
    endif
      
    cov_matrix = zeros(2*model_rank, 2*model_rank);
    theta_l = ewls_theta_trajectory(1:2*model_rank, t0);
    theta_r = ewls_theta_trajectory(2*model_rank+1:end, t0);
    theta = [theta_l, theta_r];
    state_vector = ewls_regression(:, t0+1);
    
    tk = t0;
    correct_samples = 0;
    alarm_length = 0;

    while (correct_samples < model_rank) && (alarm_length < max_alarm_length) && (tk+1 <= N)
      tk = tk+1;

      kalman_output_prediction = mround(theta'*state_vector);
      cl_error_trajectory(:,tk) = clear_signal(:,tk) - kalman_output_prediction;
      state_vector = [ kalman_output_prediction; state_vector ];
      kalman_h = mround(cov_matrix*theta);
      cl_noise_variance_trajectory(:,:,tk) = mround(theta'*kalman_h + ewls_noise_variance_trajectory(:,:,t0));
      cov_matrix = [cl_noise_variance_trajectory(:,:,tk), kalman_h'; kalman_h, cov_matrix];
      
      theta = [theta; zeros(2,2)];
      
      if(cl_noise_variance_trajectory(1,1,tk) < 0)
        printf("Oops, I should not be here! Negative var L: %d\n", cl_noise_variance_trajectory(1,1,tk));
      endif
      
      if(cl_noise_variance_trajectory(2,2,tk) < 0)
        printf("Oops, I should not be here! Negative var R: %d\n", cl_noise_variance_trajectory(2,2,tk));
      endif
      
      cl_threshold_trajectory(1,tk) = mround(mu*sqrt(cl_noise_variance_trajectory(1,1,tk)));
      cl_threshold_trajectory(2,tk) = mround(mu*sqrt(cl_noise_variance_trajectory(2,2,tk)));
      cl_primary_detection(:,tk) = cl_primary_detection(:,tk) + abs(cl_error_trajectory(:,tk)) > cl_threshold_trajectory(:,tk);
      
      
      L = mround(build_gain_vector(cl_primary_detection(:,tk) , cl_noise_variance_trajectory(:,:,tk), cov_matrix));
      state_vector = state_vector + mround(L*cl_error_trajectory(:,tk));
      cov_matrix = cov_matrix - mround(L*cl_noise_variance_trajectory(:,:,tk)*L');
        
      if(mround(cl_error_trajectory(:,tk)'*inv(cl_noise_variance_trajectory(:,:,tk))*cl_error_trajectory(:,tk)) <= mu^2)
        correct_samples = correct_samples + 1;
      else 
        correct_samples = 0;
      endif
    
      alarm_length = tk-t0;
  endwhile
    
    [new_detection_l, false_l] =  fill_detection(cl_primary_detection(1,t0:tk), model_rank);
    [new_detection_r, false_r] =  fill_detection(cl_primary_detection(2,t0:tk), model_rank);
    
    if(false_l == 1)
      printf("False positive at L\n");
      cl_final_detection(1,t0:tk) = new_detection_l;
    endif
    
    if(false_r)
      printf("False positive at L\n");
      cl_final_detection(2,t0:tk) = new_detection_r;
    endif
    
    cl_final_detection = (cl_primary_detection + cl_final_detection) > 0;
    
    %if(false_l || false_r)
    %   variable_clear_signal(:,t0-model_rank+1:tk) = var_interpolator(...
    %     [theta_l, theta_r],...
    %      variable_clear_signal,...
    %      d,...
    %      model_rank,...
    %      t0,...
    %      tk,...
    %      noise_variance_trajectory(:,:,t0)...
    %    );
    %else 
      reconstruction_l = state_vector(1:2:end)';
      reconstruction_r = state_vector(2:2:end)';  
      signal_reconstruction = [flip(reconstruction_l); flip(reconstruction_r)]; 
      clear_signal(:,t0-model_rank+1:tk) = signal_reconstruction;
    %endif
    skip_detection = tk-t0;
    t = t0;
    
  elseif (skip_detection != 0)
    skip_detection = skip_detection - 1;
  endif
  
  t = t + 1;  
endwhile
print_progress("Interpolation VAR", N, N, N/100);



ewls_model_plot(1, ...
  input_signal,...
  ewls_detection,
  ewls_error_trajectory,...
  ewls_threshold_trajectory, ...
  ewls_noise_variance_trajectory,...
  ewls_theta_trajectory)

  
cl_detection_plot(2, ...
  ewls_detection,...
  cl_primary_detection, ...
  cl_final_detection);

  
ewls_model_plot(3, ...
  input_signal,...
  cl_primary_detection,
  cl_error_trajectory,...
  cl_threshold_trajectory, ...
  cl_noise_variance_trajectory,...
  ewls_theta_trajectory)
  
%{
figure(1);
subplot(3,2,1);
plot(y_v(1,:)); grid on;  
subplot(3,2,2);
plot(y_v(2,:)); grid on; 
subplot(3,2,3);
plot(abs(error_trajectory(1,:))); hold on;
plot(threshold_trajectory(1,:)); hold off; grid on; 
subplot(3,2,4);
plot(abs(error_trajectory(2,:))); hold on;  
plot(threshold_trajectory(2,:)); hold off; grid on; 
subplot(3,2,5);
plot(d(1,:)); grid on; ylim([0 1.5]);
subplot(3,2,6);
plot(d(2,:)); grid on; ylim([0 1.5]);

figure(3);
subplot(4,1,1);
plot(y_v(1,:)); hold on;
%plot(secondary_clear_signal(1,:));
plot(variable_clear_signal(1,:)); grid on; hold off;
subplot(4,1,2);
plot(y_v(1,:) - variable_clear_signal(1,:)); grid on;
subplot(4,1,3);
plot(y_v(2,:)); hold on;
%plot(secondary_clear_signal(2,:));
plot(variable_clear_signal(2,:)); grid on; hold off;
subplot(4,1,4);
plot(y_v(2,:) - variable_clear_signal(2,:)); grid on;

%save_audio(current_file, variable_clear_signal', frequency, 1);
$}