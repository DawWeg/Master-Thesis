 function [coefficients_trajectory, noise_variance_trajectory, detection_signal, clear_signal, error_trajectory, error_threshold] = ImpulseNoiseReduction(input_signal)
%%% Preparing variables
global N AR_model_order lambda lambda0 delta mu max_block_length delay;
clear_signal = input_signal;
covariance_matrix = delta*eye(AR_model_order);
coefficients_trajectory = zeros(AR_model_order, N);
regression_vector = zeros(AR_model_order, 1);
noise_variance_trajectory = zeros(1, N);
detection_signal = zeros(1, N);
inv_lambda = 1/lambda;
error_trajectory = zeros(1, N);
error_threshold = zeros(1, N);

%%% Corrupted samples detection loop
for t = 2:N
    % Estimating model parameters using weighted recursive least squares algorithm
    regression_vector = [clear_signal(t-1); regression_vector(1:end-1)];
    [coefficients_trajectory(:,t), noise_variance_trajectory(t), error_trajectory(t), covariance_matrix] = ...
      EWLS_Step(regression_vector, covariance_matrix, clear_signal(t), coefficients_trajectory(:,t-1), noise_variance_trajectory(t-1));
    error_threshold(t) = mu*sqrt(noise_variance_trajectory(t-1)); 
    if(t < delay)
      continue;
    endif
    % Checking if the sample is corrupted
    if(abs(error_trajectory(t)) > error_threshold(t))
      % If the sample is corrupted alarm is raised.
      % We check the model stability, and if it's not stable we use Levinson-Durbin
      % algorithm to make sure that it is.
      %dbstop("CheckStability");
      if(!CheckStability(coefficients_trajectory(:,t-1)))
        disp("Model unstable");     
      endif    
      detection_signal(t) = 1;
      block_start_index = t;
      prediction_regression_vector = clear_signal(t+1:-1:t-AR_model_order+2);
      end_condition = 0;
      prediction_noise_variance = noise_variance_trajectory(t-1);
      f = 0;
      for i = 1:(max_block_length+AR_model_order-1)
        % Starting open loop detection process:
        %   * calculating i-th prediction errors
        %   * calculating i-th noise_variance prediction using Stoica algorithm
        %   * deciding if given sample is corrupted 
        prediction_regression_vector = shift(prediction_regression_vector,1);
        prediction_regression_vector(1) = clear_signal(t+i-1);
        prediction_error = input_signal(t+i) - coefficients_trajectory(:,t-1)'*prediction_regression_vector;
        [prediction_noise_variance, f] = Stoica(prediction_noise_variance, noise_variance_trajectory(t-1), coefficients_trajectory(:,t-1), i+1, f);
        if(abs(prediction_error) > mu*sqrt(prediction_noise_variance))
          detection_signal(t+i) = 1;
        endif        
        if(max(detection_signal(t+i-AR_model_order+1:1:t+i)) == 0)
          % If last 5 samples are deemed uncorrupted we:
          %   * fill the whole block from beginning till the end in the detection signal with ones
          %   * interpolate corrupted fragment using Kalman filter
          %   * go back to the sample prior to the detection alarm and continue
          m = t + i - block_start_index - AR_model_order;
          detection_signal(block_start_index:block_start_index+m-1) = 1;
          clear_signal(block_start_index:block_start_index+m-1) = VariableInterpolation(     ...
                  clear_signal(block_start_index-AR_model_order:block_start_index+m+AR_model_order-1), m, ...
                  coefficients_trajectory(:,t-1), noise_variance_trajectory(t-1));          
          t = t-1;
          break;
        elseif(i >= max_block_length)
          % If we reached max block length we:
          %   * fill the whole block with ones in the detection signal
          %   * interpolate whole block 
          %   * go back to the sample prior to the detection alarm and continue 
          detection_signal(block_start_index:block_start_index+max_block_length-1) = 1;
          clear_signal(block_start_index:block_start_index+max_block_length-1) = VariableInterpolation(     ...
                  clear_signal(block_start_index-AR_model_order:block_start_index+max_block_length+AR_model_order-1), ...
                  max_block_length, coefficients_trajectory(:,t-1), noise_variance_trajectory(t-1));
          t = t-1;          
        endif                
      endfor 
    endif
    if(mod(t,1000) == 0)
      printf("[%*d|100]\n", 3, round((t/N)*100));
    endif
endfor
disp("[100|100]");
endfunction