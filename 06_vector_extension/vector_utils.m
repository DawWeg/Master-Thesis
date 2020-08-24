1;

function [state_vector] = init_state_vector(signal, r, t0);
  state_vector = zeros(2*r,1);
  
  for n=1:2:2*r
    state_vector(n:n+1) = signal(:, t0 - ((n-1)/2) )';
  endfor
  
endfunction

function [regression] = init_regression_vector(signal, r, t0);
  %ewls_regression(:,t) = [clear_signal(:,t-1); ewls_regression(1:end-2, t-1)]; 
  regression = signal(:,t0-r);
  for n=r-1:-1:1
    regression = [signal(:,t0-n); regression];
  endfor
endfunction

function [gain_vector] = build_gain_vector(detection, kalman_var, cov_matrix)
      if(detection(1) == 0 && detection(2) == 0)
        Ginv = inv(kalman_var);    
      elseif (detection(1) == 0 && detection(2) != 0)
        Ginv = [1/kalman_var(1,1), 0; 0 0];
      elseif (detection(1) != 0 && detection(2) == 0)
        Ginv = [0, 0; 0 1/kalman_var(2,2)];
      else
        Ginv = zeros(2,2);
      endif
      
      gain_vector = cov_matrix(:,1:2)*Ginv;
endfunction

function [signal_reconstruction] = retrieve_reconstruction(state_vector)
  reconstruction_l = state_vector(1:2:end)';
  reconstruction_r = state_vector(2:2:end)';
  
  signal_reconstruction = [flip(reconstruction_l); flip(reconstruction_r)]; 
endfunction


function [filled_detection, false] = fill_detection(detection, model_rank)
  correct_counter = 0;
  filled_detection = detection;
  detected_samples = find(detection);
  for i=1:length(detected_samples)-1
    if(detected_samples(i+1)-detected_samples(i) < model_rank)
      filled_detection(detected_samples(i):detected_samples(i+1)) = 1;
    endif
  endfor
  
  false = sum(filled_detection) != sum(detection);
endfunction


function [reconstructed_signal] = var_interpolator(...
    theta_init,...
    signal,...
    detection,...
    model_rank,...
    t_start,...
    t_end,...
    noise_variance...
  )
    t0 = t_start;
    
    init_cov_matrix = zeros(2*model_rank, 2*model_rank);
    theta = theta_init;
    tk = t0;
    state_vector = init_state_vector(signal, model_rank, t0);
    cov_matrix = init_cov_matrix;

    for tk=t_start+1:t_end
      kalman_output_prediction = theta'*state_vector;
      kalman_error = signal(:,tk) - kalman_output_prediction;
      state_vector = [ kalman_output_prediction; state_vector ];
      kalman_h = cov_matrix*theta;
      kalman_var = theta'*kalman_h + noise_variance;
      cov_matrix = [kalman_var, kalman_h'; kalman_h, cov_matrix];
      
      theta = [theta; zeros(2,2)];
      
      L = build_gain_vector(detection(:,tk) , kalman_var, cov_matrix);
      state_vector = state_vector + L*kalman_error;
      cov_matrix = cov_matrix - L*kalman_var*L';
    endfor

    
    reconstructed_signal = retrieve_reconstruction(state_vector);
endfunction


