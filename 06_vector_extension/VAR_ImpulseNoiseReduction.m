function [ clear_signal,...
           detection,...
           error,...
           variance ] = VAR_ImpulseNoiseReduction(input_signal)
  
  global model_rank ewls_lambda mu;
  input_signal = input_signal';
  N = length(input_signal(1,:));
  Or = zeros(2*model_rank,1);
  Ir = eye(2*model_rank, 2*model_rank);

  clear_signal = input_signal;
  detection = zeros(size(input_signal));
  error = zeros(size(input_signal));
  variance = zeros(size(input_signal));
  
  ewls_covariance_matrix_current = 100*Ir;
  ewls_covariance_matrix_previous = 100*Ir;
  
  ewls_theta_current = zeros(4*model_rank,1);
  ewls_theta_previous = zeros(4*model_rank,1);
  
  ewls_error_current = zeros(2,1);
  ewls_error_previous = zeros(2,1);
  
  ewls_noise_variance_current = zeros(2,2);
  ewls_noise_variance_previous = zeros(2,2);
      
  ewls_regression = zeros(2*model_rank);
  ewls_threshold = zeros(2,1);
  ewls_detection = zeros(2,1);

  ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
  
  t = model_rank+1;
  max_alarm_length = 100;
  skip_detection = 0;
  unstable_model = 0;
  
while(t <= N);
  print_progress("Interpolation VAR", t, N, N/100);
  ewls_regression = init_regression_vector(clear_signal, model_rank, t);
  
  [ ewls_theta_current, ...
    ewls_covariance_matrix_current, ...
    ewls_error_current,  ...
    ewls_noise_variance_current ] = ewls_vector_recursive(...
          clear_signal(:,t), ...
          ewls_regression, ...
          ewls_covariance_matrix_previous, ...
          ewls_theta_previous, ...
          ewls_noise_variance_previous);

  
  if (t > 1000 && skip_detection == 0)     
    ewls_threshold(1) = mu*sqrt(ewls_noise_variance_current(1,1));
    ewls_threshold(2) = mu*sqrt(ewls_noise_variance_current(2,2));
    ewls_detection = abs(ewls_error_current) > ewls_threshold;
    detection(:, t) = ewls_detection;
    variance(1, t) = ewls_noise_variance_current(1,1);
    variance(2, t) = ewls_noise_variance_current(2,2);
    error(:,t) = ewls_error_current;
  endif

  
  if ((ewls_detection(1) || ewls_detection(2)) && skip_detection == 0 )
    t0 = t-1;
    if(check_stability_var (ewls_theta_previous) == 0)
      printf("Model ustable on: %d.\n", t0);
      ewls_theta_previous = ...
          wwr_estimation2(min([ewls_equivalent_window_length, t0]), ...
          clear_signal(:,t0-(min([ewls_equivalent_window_length, t0]))+1:t0), ...
          ewls_noise_variance_previous );
      unstable_model = unstable_model+1;
    endif 

      
    cl_covariance_matrix = zeros(2*model_rank, 2*model_rank);
    cl_theta_l = mround(ewls_theta_previous(1:2*model_rank));
    cl_theta_r = mround(ewls_theta_previous(2*model_rank+1:end));
    cl_theta = mround([cl_theta_l, cl_theta_r]);
    cl_state_vector = init_regression_vector(clear_signal, model_rank, t0+1);
    cl_noise_variance = mround(ewls_noise_variance_previous);
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
      
      detection(:,tk) = cl_detection;
      variance(1,tk) = cl_error_covariance(1,1);
      variance(2,tk) = cl_error_covariance(2,2);
      error(:,tk) = cl_error;
  endwhile
    
    [detection(:,t0:tk), false_alarm] = var_false_alarms(detection(:,t0:tk));
    
    signal_reconstruction = retrieve_reconstruction(cl_state_vector);
    if(false_alarm)
       signal_reconstruction = var_kalman_interpolator( clear_signal,...
                                                        detection,...
                                                        t0, tk,...
                                                        mround([cl_theta_l, cl_theta_r]),...
                                                        cl_noise_variance );
    endif

    clear_signal(:,t0+1:tk-correct_samples) = signal_reconstruction(:,1+model_rank:end-correct_samples);
    skip_detection = tk-t0;
    t = t0;
    
  else
    % If no alarm detected or skipping detection -> update models 
    if (skip_detection != 0)
      skip_detection = skip_detection - 1;
    endif
    ewls_theta_previous = ewls_theta_current;
    ewls_covariance_matrix_previous = ewls_covariance_matrix_current;
    ewls_error_previous = ewls_error_current;
    ewls_noise_variance_previous = ewls_noise_variance_current;
  endif
  
  t = t + 1;  
endwhile
print_progress("Interpolation VAR", N, N, N/100);

endfunction
