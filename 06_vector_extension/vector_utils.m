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
      ro1 = mround(kalman_var(1,1));
      ro2 = mround(kalman_var(2,2));
      det_ro = mround(det(mround(kalman_var)));
      
      ok_all = det_ro > 1e-12;
      ok_1 = ro1 > 1e-12;
      ok_2 = ro2 > 1e-12;      
      ok_all = 1;
      ok_1 = 1;
      ok_2 = 1;
      
      if(detection(1) == 0 && detection(2) == 0 && ok_all)
          Ginv = mround(mround(kalman_var)\eye(2));  
      elseif (detection(1) == 0 && detection(2) != 0 && ok_1)
        Ginv = mround([1/kalman_var(1,1), 0; 0 0]);
      elseif (detection(1) != 0 && detection(2) == 0 && ok_2)
        Ginv = mround([0, 0; 0 1/kalman_var(2,2)]);
      else
        Ginv = zeros(2,2);
      endif
      
      gain_vector = mround(cov_matrix(:,1:2)*Ginv);
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

    cov_matrix = zeros(2*model_rank, 2*model_rank);
    theta = mround(theta_init);
    state_vector = mround(init_regression_vector(signal, model_rank, t0+1));
    
    tk = t0;
    correct_samples = 0;
    alarm_length = 0;

    for tk=t0+1:t_end
      kalman_output_prediction = mround(mround(theta')*mround(state_vector));
      kalman_error = mround(mround(signal(:,tk)) - mround(kalman_output_prediction));
      state_vector = mround([ kalman_output_prediction; state_vector ]);
      kalman_noise_variance = ...
        mround(...
          mround(...
            mround(theta')...
            *...
            mround(cov_matrix)...
            *...
            mround(theta)...
          )...
          + ...
          mround(noise_variance)...
        );
        
      cov_matrix = mround([...
        kalman_noise_variance,  mround(mround(cov_matrix)*mround(theta))';...
        mround(mround(cov_matrix)*mround(theta)), cov_matrix]);
      
      theta = mround([theta; zeros(2,2)]);
          
      L = mround(build_gain_vector(detection(:,tk) , kalman_noise_variance, cov_matrix));
      state_vector = mround(state_vector + mround(L*kalman_error));
      cov_matrix = mround(cov_matrix - mround(L*kalman_noise_variance*L'));
    endfor
    
    reconstructed_signal = retrieve_reconstruction(state_vector);
endfunction


      %{
      if(cl_primary_detection(1,tk) == 0 && cl_primary_detection(2,tk) == 0)
        Ginv = mround(inv(cl_noise_variance_trajectory(:,:,tk)));    
        gain_vector = mround(cov_matrix(:,1:2)*Ginv);
        state_vector = mround(state_vector + mround(gain_vector*cl_error_trajectory(:,tk)));
        cov_matrix = mround(cov_matrix - mround(gain_vector*cl_noise_variance_trajectory(:,:,tk)*gain_vector'));
      elseif (cl_primary_detection(1,tk) == 0 && cl_primary_detection(2,tk) != 0)
        gain_vector = mround(mround((1/cl_noise_variance_trajectory(1,1,tk)))*cov_matrix(:,1));
        state_vector = mround(state_vector + mround(gain_vector*cl_error_trajectory(1,tk)));
        cov_matrix = mround(cov_matrix - mround(cl_noise_variance_trajectory(1,1,tk)*gain_vector*gain_vector'));
      elseif (cl_primary_detection(1,tk) != 0 && cl_primary_detection(2,tk) == 0)
        gain_vector = mround((1/cl_noise_variance_trajectory(2,2,tk))*cov_matrix(:,2));
        state_vector = mround(state_vector + mround(gain_vector*cl_error_trajectory(2,tk)));
        cov_matrix = mround(cov_matrix - mround(cl_noise_variance_trajectory(2,2,tk)*gain_vector*gain_vector'));
      else
        Ginv = zeros(2,2);
        state_vector = state_vector;
        cov_matrix = cov_matrix;
      endif
      %}
