run("init.m");
source("06_vector_extension/vector_utils.m");
source("06_vector_extension/var_kalman.m");

current_file = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, 0.0, 0.5);
input_signal = input_signal';
N = length(input_signal(1,:));

%max_sample = max(max(abs(input_signal)));
%signal_scale_factor = 1/max_sample;
%input_signal = input_signal.*signal_scale_factor;

Or = zeros(2*model_rank,1);
Ir = eye(2*model_rank, 2*model_rank);
%xlimits = [10560 10586];
xlimits = [-inf inf];
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
cl_error_covariance_trajectory = zeros(size(ewls_noise_variance_trajectory));
cl_threshold_trajectory = zeros(size(ewls_threshold_trajectory));
cl_error_trajectory = zeros(size(ewls_threshold_trajectory));
t = model_rank+1;
max_alarm_length = 100;
skip_detection = 0;
gain_safety = 0;
unstable_model = 0;
not_symetric = 0;
not_positive_definite = 0;

kalman_gain_trajectory = zeros(110,2,N);
while(t <= N);
  print_progress("Interpolation VAR", t, N, N/100);
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

    ewls_theta_trajectory(:,t) = mround(ewls_theta_trajectory(:,t));
    ewls_covariance_matrix_trajectory(:,:,t) = mround(ewls_covariance_matrix_trajectory(:,:,t));
    ewls_error_trajectory(:,t) = mround(ewls_error_trajectory(:,t));
    ewls_noise_variance_trajectory(:,:,t) = mround(ewls_noise_variance_trajectory(:,:,t));
 
  
  if (t > 1000 && skip_detection == 0)     
    %ewls_error_trajectory(:,t) = mround(ewls_error_trajectory(:,t));
    ewls_threshold_trajectory(1,t) = mu*sqrt(ewls_noise_variance_trajectory(1,1,t));
    ewls_threshold_trajectory(2,t) = mu*sqrt(ewls_noise_variance_trajectory(2,2,t));
    ewls_detection(:,t) = abs(ewls_error_trajectory(:,t)) > ewls_threshold_trajectory(:,t);
  endif
  
  if(ewls_threshold_trajectory(1,1)>0)
    x=5;
  endif

  
  if ((ewls_detection(1,t) || ewls_detection(2,t)) && skip_detection == 0 )
    t0 = t-1;
    
    ewls_noise_variance_trajectory(:,:,t0) = mround(ewls_noise_variance_trajectory(:,:,t0));
    if(check_stability_var (ewls_theta_trajectory(:,t0)) == 0)
      printf("Model ustable on: %d.\n", t0);
      ewls_theta_trajectory(:,t0) = ...
          wwr_estimation2(min([ewls_equivalent_window_length, t0]), ...
          clear_signal(:,t0-(min([ewls_equivalent_window_length, t0]))+1:t0), ...
          ewls_noise_variance_trajectory(:,:,t0));
      unstable_model = unstable_model+1;
    endif 

      
    cl_covariance_matrix = zeros(2*model_rank, 2*model_rank);
    cl_theta_l = mround(ewls_theta_trajectory(1:2*model_rank, t0));
    cl_theta_r = mround(ewls_theta_trajectory(2*model_rank+1:end, t0));
    cl_theta = mround([cl_theta_l, cl_theta_r]);
    cl_state_vector = mround(ewls_regression(:, t0+1));
    cl_noise_variance = ewls_noise_variance_trajectory(:,:,t0);
    cl_threshold = zeros(2,1);
    tk = t0;
    correct_samples = 0;
    alarm_length = 0;

    while (correct_samples < model_rank) && (alarm_length < max_alarm_length) && (tk+1 <= N)
      tk = tk+1;

     [ cl_theta, ...
       cl_state_vector, ...
       cl_error, ...
       cl_error_covariance, ...
       cl_covariance_matrix ] = var_kalman_step( cl_theta,...
                                                 cl_state_vector,...
                                                 clear_signal(:,tk),...
                                                 cl_covariance_matrix,...
                                                 cl_noise_variance );
     
     [ cl_detection,...
       cl_threshold ]         = var_kalman_detect( cl_error,...
                                           cl_error_covariance );
     
     [ cl_state_vector,...
       cl_covariance_matrix ] = var_kalman_update( cl_detection,...
                                                   cl_state_vector,...
                                                   cl_error,...
                                                   cl_error_covariance,...
                                                   cl_covariance_matrix );
      
      if(cl_detection(1) == 0 && cl_detection(2)==0)
        correct_samples = correct_samples + 1;
      else 
        correct_samples = 0;
      endif
      
      cl_primary_detection(:,tk) = cl_detection;
      cl_error_covariance_trajectory(:,:,tk) = cl_error_covariance;
      cl_threshold_trajectory(:,tk) = cl_threshold;
      cl_error_trajectory(:,tk) = cl_error;
      
      alarm_length = tk-t0;
  endwhile
    
    [cl_final_detection(:,t0:tk), false_alarm] = var_false_alarms(cl_primary_detection(:,t0:tk));
    
    signal_reconstruction = retrieve_reconstruction(cl_state_vector);
    if(false_alarm)
       signal_reconstruction = var_kalman_interpolator( clear_signal,...
                                                        cl_final_detection,...
                                                        t0, tk,...
                                                        mround([cl_theta_l, cl_theta_r]),...
                                                        cl_noise_variance );
    endif

    clear_signal(:,t0+1:tk-correct_samples) = signal_reconstruction(:,1+model_rank:end-correct_samples);
    skip_detection = tk-t0;
    t = t0;
    
  elseif (skip_detection != 0)
    skip_detection = skip_detection - 1;
  endif
  
  t = t + 1;  
endwhile
print_progress("Interpolation VAR", N, N, N/100);


printf("Model was %d times unstable\n", unstable_model);
printf("Negative var L count %d | Max: %d\n", ...
  sum(squeeze(cl_error_covariance_trajectory(1,1,:)) < 0), ...
  min(squeeze(cl_error_covariance_trajectory(1,1,:))));
printf("Negative var R count %d | Max: %d\n", ...
  sum(squeeze(cl_error_covariance_trajectory(2,2,:)) < 0),
  min(squeeze(cl_error_covariance_trajectory(2,2,:))));

printf("Detected at L: %d from %d | %d\n",...
  sum(cl_final_detection(1,:)), length(cl_final_detection(1,:)), ...
  (sum(cl_final_detection(1,:))/length(cl_final_detection(1,:)))*100);
printf("Detected at R: %d from %d | %d\n",...
  sum(cl_final_detection(2,:)), length(cl_final_detection(2,:)), ...
  (sum(cl_final_detection(2,:))/length(cl_final_detection(2,:)))*100);
