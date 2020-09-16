function [ clear_signal,...
           detection,...
           error,...
           variance ] = VAR_ImpulseNoiseReduction(input_signal, input_detection)
  
  global model_rank ewls_lambda mu max_corrupted_block_length;
  check_stability = 1; # put 1 if check for stability should run
  use_external_detection = 0;
  if (nargin > 1)
    use_external_detection = 1;
    detection = input_detection;
  end
  
  input_signal = input_signal';
  if !use_external_detection
    detection = zeros(size(input_signal));
  endif
  N = length(input_signal(1,:));
  Or = zeros(2*model_rank,1);
  Ir = eye(2*model_rank, 2*model_rank);

  clear_signal = input_signal;
  
  error = zeros(size(input_signal));
  variance = zeros(size(input_signal));
  
  ewls_covariance_matrix_current = 100*Ir;
  ewls_covariance_matrix_previous = 100*Ir;
  
  ewls_theta_current = zeros(4*model_rank,1);
  ewls_theta_previous = zeros(4*model_rank,1);
  
  ewls_error_current = zeros(2,1);
  ewls_error_previous = zeros(2,1);
  ewls_error_trajectory = zeros(size(input_signal));
  
  ewls_noise_variance_current = zeros(2,2);
  ewls_noise_variance_previous = zeros(2,2);
      
  ewls_regression = zeros(2*model_rank);
  ewls_threshold = zeros(2,1);
  ewls_detection = zeros(2,1);

  ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
  
  t = model_rank+1;
  max_alarm_length = max_corrupted_block_length;
  if use_external_detection
    max_alarm_length = max_alarm_length*3;
  endif
  skip_detection = 0;
  unstable_model = 0;
  do_init_regression = 1;
  regrssion_time = 0;
  ewls_time = 0;
  kalman_time = 0;
  iter = 0;

while(t <= N);
  print_progress("VAR Impulse noise reduction", t, N, N/100);
  
  if(do_init_regression)
    ewls_regression = init_regression_vector(clear_signal, model_rank, t);
    do_init_regression = 0;
  else
    ewls_regression = [clear_signal(:,t-1); ewls_regression(1:end-2)];
  endif

  % EWLS VAR model 
  [ ewls_theta_current, ...
    ewls_covariance_matrix_current, ...
    ewls_error_current,  ...
    ewls_noise_variance_current ] = ewls_vector_recursive(...
          clear_signal(:,t), ...
          ewls_regression, ...
          ewls_covariance_matrix_previous, ...
          ewls_theta_previous, ...
          ewls_noise_variance_previous);
  ewls_error_trajectory(:,t) = ewls_error_current;
  % If model is in steady state (whole window is populated)
  % And number of samples marked by closed loop detection as cleared is zeros
  % Perform EWLS based detection
  if (t > ewls_equivalent_window_length && skip_detection == 0)     

    if(use_external_detection)
      ewls_detection = detection(:,t);
    else
      ewls_threshold(1) = mu*sqrt(ewls_noise_variance_current(1,1));
      ewls_threshold(2) = mu*sqrt(ewls_noise_variance_current(2,2));
      ewls_detection = abs(ewls_error_current) > ewls_threshold;
      detection(:, t) = ewls_detection;
    endif
    
   
    variance(1, t) = ewls_noise_variance_current(1,1);
    variance(2, t) = ewls_noise_variance_current(2,2);
    error(:,t) = ewls_error_current;
  endif

  % If any of two channels is marked as corrupted
  % And number of samples marked by closed loop detection as cleared is zeros
  % Perform kalman detection from time t = t-1
  if ((ewls_detection(1) || ewls_detection(2)) && skip_detection == 0 )
    t0 = t-1;
    
    % Check model stability and in case it is unstable reestimate coefficients
    % using WWR algorithm
    
    if(check_stability && (check_stability_var (ewls_theta_previous) == 0))
      printf("Model ustable on: %d.\n", t0);

      %[cl_theta_l, cl_theta_r, qqx] = wwr_estimation3(...
      %   min([ewls_equivalent_window_length, t0]),...
      %    clear_signal(:,t0-(min([ewls_equivalent_window_length, t0-1])):t0));
      %noise_variance_kalman = mround(noise_variance_kalman);
      %save('-binary','wwr3data.dat', ...
      %  'theta_kalman', 'ewls_equivalent_window_length', 't0', 'clear_signal',...
      %  'ewls_theta_previous', 'ewls_error_trajectory');
      
      %unstable_model++;
      %cl_theta = mround([cl_theta_l, cl_theta_r]);
      %cl_noise_variance = mround(qqx./ewls_equivalent_window_length);
      
      %cl_noise_variance = mround(qqx);
      %ewls_theta_previous = ...
      %    wwr_estimation2(min([ewls_equivalent_window_length, t0]), ...
      %    clear_signal(:,t0-(min([ewls_equivalent_window_length, t0]))+1:t0), ...
      %    ewls_noise_variance_previous );
      cl_theta_l = mround(ewls_theta_previous(1:2*model_rank));
      cl_theta_r = mround(ewls_theta_previous(2*model_rank+1:end));
      cl_theta = mround([cl_theta_l, cl_theta_r]);
      cl_noise_variance = mround(ewls_noise_variance_previous);
    else
      
      cl_theta_l = mround(ewls_theta_previous(1:2*model_rank));
      cl_theta_r = mround(ewls_theta_previous(2*model_rank+1:end));
      cl_theta = mround([cl_theta_l, cl_theta_r]);
      cl_noise_variance = mround(ewls_noise_variance_previous);
    endif 

    % Set up initial conditions for Kalman closed loop detection
    cl_covariance_matrix = zeros(2*model_rank, 2*model_rank);
    cl_state_vector = init_regression_vector(clear_signal, model_rank, t0+1);
    
    cl_threshold = zeros(2,1);
    tk = t0;
    correct_samples = 0;
    alarm_length = 0;

    % Perform detection until
    % -> Number of correct samples in a row is equal to model rank
    % -> Maximum alarm length is reached
    % -> End of signal is rached
    while (correct_samples < model_rank) && (tk+1 <= N)
      tk = tk+1;
     
     % Perform calculations for one step of kalman algorithm
     [ cl_theta, ...
       cl_state_vector, ...
       cl_error, ...
       cl_error_covariance, ...
       cl_covariance_matrix ] = var_kalman_step( cl_theta,...
                                                 cl_state_vector,...
                                                 clear_signal(:,tk),...
                                                 cl_covariance_matrix,...
                                                 cl_noise_variance );
    
     % Make decision on whether samples are corrupted or not
     [ cl_detection,...
       cl_threshold ]         = var_kalman_detect( cl_error,...
                                           cl_error_covariance );
      if ((alarm_length >= max_alarm_length))
        cl_detection(1) = 0;
        cl_detection(2) = 0;
      endif
      
      if(use_external_detection)
        cl_detection = detection(:,tk);
      endif 
     
      if ((alarm_length >= max_alarm_length))
       cl_detection(1) = 0;
       cl_detection(2) = 0;
        if use_external_detection
          detection(:,tk) = cl_detection;
        endif 
      endif
      
     % Update kalman state vector and covariance matrix 
     [ cl_state_vector,...
       cl_covariance_matrix ] = var_kalman_update( cl_detection,...
                                                   cl_state_vector,...
                                                   cl_error,...
                                                   cl_error_covariance,...
                                                   cl_covariance_matrix );
      
      % Samples on both channels are clear, mark this run as correct
      % If not clear correct run counter
      if(cl_detection(1) == 0 && cl_detection(2)==0)
        correct_samples = correct_samples + 1;
      else 
        correct_samples = 0;
      endif
      
      % Update trajectory vectors
      if !use_external_detection
        detection(:,tk) = cl_detection;
      endif
      variance(1,tk) = cl_error_covariance(1,1);
      variance(2,tk) = cl_error_covariance(2,2);
      error(:,tk) = cl_error;
      alarm_length = tk - t0;
  endwhile
    
    % Retrieve interpolation from Kalman state vector
    signal_reconstruction = retrieve_reconstruction(cl_state_vector);
    
    if(!use_external_detection)
        % Check if there were any false alarms during detection
        % And fill extend detection signal
        [detection(:,t0:tk), false_alarm] = var_false_alarms(detection(:,t0:tk));
       
        % If false alarm was detected run Kalman algorithm again
        % but with defined detection signal
        if(false_alarm)
           signal_reconstruction = var_kalman_interpolator( clear_signal,...
                                                            detection,...
                                                            t0, tk,...
                                                            mround([cl_theta_l, cl_theta_r]),...
                                                            cl_noise_variance );
        endif
    endif


    % Replace corrupted samples with their reconstruction
    clear_signal(:,t0+1:tk-correct_samples) = signal_reconstruction(:,1+model_rank:end-correct_samples);
    
    % Mark samples analyzed by Kalman algorithm as correct
    skip_detection = tk-t0;
    t = t0;
    do_init_regression = 1;
  else
    % If no alarm detected or skipping detection -> update models 
    if (skip_detection != 0)
      % Decrease number of correct samples
      skip_detection = skip_detection - 1;
    endif
    
    % Prepare next step of EWLS algorithm
    ewls_theta_previous = ewls_theta_current;
    ewls_covariance_matrix_previous = ewls_covariance_matrix_current;
    ewls_error_previous = ewls_error_current;
    ewls_noise_variance_previous = ewls_noise_variance_current;
  endif
  t = t + 1;  
endwhile
print_progress("VAR Impulse noise reduction", N, N, N/100);

endfunction
