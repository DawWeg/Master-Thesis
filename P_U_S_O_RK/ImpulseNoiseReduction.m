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
    error = clear_signal(t) - regression_vector'*coefficients_trajectory(:,t-1);
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
      %dbstop("CheckStability");
      if(!CheckStability(coefficients_trajectory(:,t-1)))
        disp("Model unstable");     
      endif    
      detection_signal(t) = 1;
      block_start_index = t;
      block_end_index = t;
      prediction_regression_vector = regression_vector;
      end_condition = 0;
      prediction_noise_variance = noise_variance_trajectory(t-1);
      f = 0;
      for i = 1:(max_block_length-1)
        % Starting open loop detection process:
        %   * calculating i-th prediction errors
        %   * calculating i-th noise_variance prediction using Stoica algorithm
        %   * deciding if given sample is corrupted 
        prediction_regression_vector = shift(prediction_regression_vector,1);
        prediction_regression_vector(1) = clear_signal(t+i-1);
        prediction_error = clear_signal(t+i) - coefficients_trajectory(:,t-1)'*prediction_regression_vector;
        [prediction_noise_variance, f] = Stoica(prediction_noise_variance, noise_variance_trajectory(t-1), coefficients_trajectory(:,t-1), i+1, f);
        if(abs(prediction_error) > mu*sqrt(prediction_noise_variance))
          detection_signal(t+i) = 1;
        endif        
        if(max(detection_signal(t+i-AR_model_order+1:t+i)) == 0)
          % If last 5 samples are deemed uncorrupted we:
          %   * fill the whole block from beginning till the end in the detection signal with ones
          %   * interpolate corrupted fragment using Kalman filter
          %   * go back to the sample prior to the detection alarm and continue
          m = t + i - block_start_index - AR_model_order;
          q = 2*AR_model_order + m;
          detection_signal(block_start_index:block_start_index+m) = 1;
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
          m = max_block_length;
          q = 2*AR_model_order + m;
          detection_signal(block_start_index:t+max_block_length-1) = 1;
          clear_signal(block_start_index:t+max_block_length) = RecursiveInterpolation(     ...
                  clear_signal(block_start_index-q:t+max_block_length+AR_model_order), m, q, coefficients_trajectory(:,t-1), ...
                  noise_variance_trajectory(t-1));
          t = t-1;          
        endif                
      endfor 
    endif
endfor

endfunction
