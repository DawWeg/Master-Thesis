 function [coefficients_trajectory, noise_variance_trajectory, detection_signal, clear_signal] = ImpulseNoiseReduction(input_signal)
%%% Preparing variables
global N AR_model_order lambda lambda0 delta mu max_block_length delay;
clear_signal = input_signal;
covariance_matrix = delta*eye(AR_model_order);
coefficients_trajectory = zeros(AR_model_order, N);
regression_vector = zeros(AR_model_order, 1);
noise_variance_trajectory = zeros(1, N);
detection_signal = zeros(1, N);
inv_lambda = 1/lambda;

%%% Corrupted samples detection loop
for t = 2:N
    % Estimating model parameters using weighted recursive least squares algorithm
    regression_vector = shift(regression_vector,1);
    regression_vector(1) = clear_signal(t-1);
    temp = regression_vector'*covariance_matrix;
    error = input_signal(t) - regression_vector'*coefficients_trajectory(:,t-1);
    gain_vector = (covariance_matrix*regression_vector)/(lambda + temp*regression_vector);
    covariance_matrix = inv_lambda*(covariance_matrix - gain_vector*temp);
    coefficients_trajectory(:,t) = coefficients_trajectory(:,t-1) + gain_vector*error;
    sigma = lambda/(lambda + temp*regression_vector);
    noise_variance_trajectory(t) = lambda0*noise_variance_trajectory(t-1) + (1-lambda0)*error*error*sigma;
    % Condition lets coefficient estimates to be more accurate before
    % deciding on quality of a sample
    if(t < delay)
      continue;
    endif
    % Checking if the sample is corrupted
    if(abs(error) > mu*sqrt(noise_variance_trajectory(t-1)))
      % If the sample is corrupted alarm is raised.
      % We check the model stability, and if it's not stable we use Levinson-Durbin
      % algorithm to make sure that it is.
      % TODO Levinson-Durbin algorithm
      if(!CheckStability(coefficients_trajectory(:,t-1)))
        disp("Model unstable");     
      endif    
      false_positive = 0;
      detection_signal(t) = 1;
      block_start_index = t;
      kalman_state_vector = clear_signal(t:-1:t-AR_model_order+1);
      kalman_covariance_matrix = zeros(AR_model_order);
      kalman_coefficients = coefficients_trajectory(:,t-1);
      for i = 1:(max_block_length-1)
        % Starting closed loop detection process:
        %   * using variable order Kalman filter to decide on whether the sample is corrupted
        kalman_output_prediction = kalman_coefficients'*kalman_state_vector;
        kalman_error = input_signal(t+i) - kalman_output_prediction;
        kalman_state_vector = [kalman_output_prediction; kalman_state_vector];
        kalman_h = kalman_covariance_matrix*kalman_coefficients;
        kalman_noise_variance = kalman_coefficients'*kalman_h + noise_variance_trajectory(t-1);
        kalman_covariance_matrix = [kalman_noise_variance, kalman_h'; kalman_h, kalman_covariance_matrix];
        kalman_coefficients = [kalman_coefficients; 0];        
        if(abs(kalman_error) > mu*sqrt(kalman_noise_variance))
          detection_signal(t+i) = 1;
          kalman_state_vector = kalman_state_vector;
          kalman_covariance_matrix = kalman_covariance_matrix;
        else
          kalman_l = (1/kalman_noise_variance)*kalman_covariance_matrix(:,1);
          kalman_state_vector = kalman_state_vector + kalman_l*kalman_error;
          kalman_covariance_matrix = kalman_covariance_matrix - kalman_noise_variance*kalman_l*kalman_l';
          if(max(detection_signal(t+i-AR_model_order+1:t+i)) != 0)
            false_positive = 1;
          endif          
        endif        
        if(max(detection_signal(t+i-AR_model_order+1:t+i)) == 0)          
          % If last 5 samples are deemed uncorrupted we:
          %   * fill the whole block from beginning till the end in the detection signal with ones
          %   * interpolate corrupted fragment using Kalman filter
          %   * go back to the sample prior to the detection alarm and continue
          m = t + i - block_start_index - AR_model_order;
          q = 2*AR_model_order + m;
          detection_signal(block_start_index:block_start_index+m) = 1;
          if(!false_positive)
            clear_signal(block_start_index:block_start_index+m-1) = flip(kalman_state_vector(AR_model_order+1:AR_model_order+m));
            t = t-1;
            disp("I did it");
            break;
          endif
          clear_signal(block_start_index:block_start_index+m-1) = RecursiveInterpolation(     ...
                  clear_signal(block_start_index-q:t+i), m, q, coefficients_trajectory(:,t-1), ...
                  noise_variance_trajectory(t-1));          
          t = t-1;
          break;
        elseif(i == max_block_length)
          % If we reached max block length we:
          %   * fill the whole block with ones in the detection signal
          %   * interpolate whole block 
          %   * go back to the sample prior to the detection alarm and continue 
          disp("I am here");
          q = 2*AR_model_order + max_block_length;
          detection_signal(block_start_index:t+i) = 1;
          clear_signal(block_start_index:t+max_block_length-1) = RecursiveInterpolation(     ...
                  clear_signal(block_start_index-q:t+max_block_length+AR_model_order), max_block_length, q, coefficients_trajectory(:,t-1), ...
                  noise_variance_trajectory(t-1));
          t = t-1;
          break;          
        endif                
      endfor 
    endif
endfor

endfunction
