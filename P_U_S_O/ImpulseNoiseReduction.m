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
    % Estimating model parameters
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
      % TODO Check the stability of a model
      % If the sample is corrupted alarm is raised      
      detection_signal(t) = 1;
      block_start_index = t;
      block_end_index = t;
      prediction_regression_vector = clear_signal(t+1:-1:t-AR_model_order+2);
      end_condition = 0;
      prediction_noise_variance = noise_variance_trajectory(t-1);
      f = 0;
      for i = 1:max_block_length
        % Starting open loop detection process
        prediction_regression_vector = shift(prediction_regression_vector,1);
        prediction_regression_vector(1) = clear_signal(t+i-1);
        prediction_error = input_signal(t+i) - coefficients_trajectory(:,t)'*prediction_regression_vector;
        [prediction_noise_variance, f] = Stoica(prediction_noise_variance, noise_variance_trajectory(t-1), coefficients_trajectory(:,t), i+1, f);
        % just for debugging, delete this after
        if(i == max_block_length)
          disp("Full block");
        endif
        if(i == max_block_length-AR_model_order)
          disp("Block almost full");
        endif
        if(abs(prediction_error) > mu*sqrt(prediction_noise_variance))
          detection_signal(t+i) = 1;
        elseif(max(detection_signal(t+i-AR_model_order+1:1:t+i)) == 0)
        
          block_end_index = t+i;
          m = block_end_index - block_start_index - AR_model_order;
          q = 2*AR_model_order + m;
          detection_signal(block_start_index:block_end_index-AR_model_order) = 1;
          %dbstop("RecursiveInterpolation");
          clear_signal(block_start_index:t+i-AR_model_order-1) = RecursiveInterpolation(clear_signal(block_start_index-q:block_end_index), m, q, coefficients_trajectory(:,t), noise_variance_trajectory(t-1));
          t = t+i+1;
          break; 
        endif                
      endfor 
    endif
endfor

endfunction
