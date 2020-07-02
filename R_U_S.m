function [  output_signal,...
            detection_signal,...
            residual_errors,...
            activate_threshold,...
            release_threshold] = R_U_S(input_signal, block_size, block_shift)
  global model_rank mu;
  
  output_signal = input_signal;
  N = length(input_signal);
  
  % Other parameters
  residual_print_per_blocks = 10;
  ewls_print_per_loop = 2000;
  
  % Allocate memory
  residual_errors = zeros(N,1);
  activate_threshold = zeros(N,1);
  release_threshold = zeros(N,1);
  detection_signal = zeros(N,1);
  previous_block = zeros(block_size, 1);
  covariance_matrix = 100*eye(model_rank);
  coefficients = zeros(model_rank,1);
  regression = zeros(model_rank, 1);
  noise_variance = 0;
  error = 0;
  
  
  block_total_count = length(1:block_shift:N);
  block_counter = 1;
  
  
  for i=1:block_shift:N
    print_progress("Residual", block_counter, block_total_count, residual_print_per_blocks);  
    block_start = i;
    block_end = i+block_size;
    % If next block would exceed signal length then clip it 
    if block_end >= N
        block_end = N;
    endif 
    current_block = input_signal(block_start:block_end);
    
    %Calculate residual errors for next block
    block_residual_errors = abs(residual_errors_for_block(current_block, previous_block));
       
    % Calculate block statistics
    block_detection = zeros(size(block_residual_errors));
    block_activate_threshold =  mu*sqrt( 1.4*median(block_residual_errors.^2 ) );
    block_release_threshold =  block_activate_threshold/2;
  
    % Find upper and lower boundries for detected alarms
    for t = 1:length(current_block)
      if block_residual_errors(t) > block_activate_threshold
        [alarm_start, alarm_end] = alarm_boundries(block_residual_errors, t, block_release_threshold);
        block_detection(alarm_start:alarm_end) = 1;
      endif
    endfor
  
    % Fill signals/trajectories;
    residual_errors(block_start:block_end) = block_residual_errors;
    detection_signal(block_start:block_end) = detection_signal(block_start:block_end) + block_detection;
    activate_threshold(block_start:block_end) = block_activate_threshold;
    release_threshold(block_start:block_end) = block_release_threshold;
    previous_block = current_block;
    block_counter++;
  endfor
  print_progress("Residual", block_counter, block_total_count, residual_print_per_blocks);  

  % Make sure detection signal is binary
  detection_signal = detection_signal > 0;

  for t = 2:N
    print_progress("EWLS", t, N, ewls_print_per_loop);  
    if (detection_signal(t)>0) && (detection_signal(t-1)==0) 
      
      alarm_start = t;
      alarm_end = t;
     
      while detection_signal(alarm_end)==1
        alarm_end++;
      endwhile
      
      m = alarm_end-alarm_start;
      q = model_rank*2+m;
      if(alarm_start-q > 0)
        output_signal(alarm_start:alarm_end-1) = recursive_interpolation ( ...
            output_signal(alarm_start-q : alarm_end + model_rank), ...
            m, ...
            q, ...
            coefficients, ...
            noise_variance);
      endif
    endif
    
    regression = [ output_signal(t-1) ; regression(1:end-1)];

    [coefficients, covariance_matrix, error, noise_variance] = ewls_step( ...
          output_signal(t), ...
          regression, ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance);     
  endfor
  print_progress("EWLS", N, N, ewls_print_per_loop);   
endfunction
