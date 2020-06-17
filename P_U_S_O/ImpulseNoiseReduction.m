function [coefficients_trajectory, noise_variance_trajectory, detection_signal] = ImpulseNoiseReduction(input_signal)
%%% Preparing variables
global N AR_model_order lambda lambda0 delta mu;
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
    regression_vector(1) = input_signal(t-1);
    temp = regression_vector'*covariance_matrix;
    error = input_signal(t) - regression_vector'*coefficients_trajectory(:,t-1);
    gain_vector = (covariance_matrix*regression_vector)/(lambda + temp*regression_vector);
    covariance_matrix = inv_lambda*(covariance_matrix - gain_vector*temp);
    coefficients_trajectory(:,t) = coefficients_trajectory(:,t-1) + gain_vector*error;
    sigma = lambda/(lambda + temp*regression_vector);
    noise_variance_trajectory(t) = lambda0*noise_variance_trajectory(t-1) + (1-lambda0)*error*error*sigma;
    % Checking if the sample is corrupted
    if(abs(error) > mu*sqrt(noise_variance_trajectory(t)))
      % TODO Check the stability of a model
      % If the sample is corrupted alarm is raised
      % TODO Open loop detection
    endif
endfor

endfunction
