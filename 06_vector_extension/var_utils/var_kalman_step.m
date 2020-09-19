% Updates Kalman state vector and covariance_matrix for next step
% Args:
%   @theta              - EWLS model coefficients estimates
%   @state_vector       - Current Kalman state vector
%   @current_samples    - Current signal samples
%   @covariance_matrix  - Current Kalman covariance matrix
%   @noise_variance     - EWLS noise variance estimation
% Returns:
%   @theta                        - Extended for next step model coefficients 
%   @state_vector                 - New Kalman state_vector
%   @predition_error              - New prediction error
%   @prediction_error_covariance  - Prediction error covariance
%   @covariance_matrix            - New Kalman covariance matrix
function [  theta, ...
            state_vector, ...
            predition_error, ...
            prediction_error_covariance, ...
            covariance_matrix ] = var_kalman_step( theta,...
                                                   state_vector,...
                                                   current_samples,...
                                                   covariance_matrix,...
                                                   noise_variance )
  % Just to be sure round up all values according to decimal precision 
  % defined by init.m
  theta = mround(theta);
  state_vector = mround(state_vector);
  noise_variance = mround(noise_variance);
  covariance_matrix = mround(covariance_matrix);
  
  % Perform Kalman algorithm calculations
  output_prediction = mround(theta'*state_vector);
  predition_error = mround(current_samples - output_prediction);  
  state_vector = mround([ output_prediction; state_vector ]);
  
  % Due to some numerical problems, instead of calculating kalman H matrix as:
  %   H = covariance_matrix*theta
  %   Prediction_error_covariance = theta' * H;
  % We can see more stable results by grouping the calculations as:
  %   Prediction_error_covariance = theta' * covariance_matrix * theta;
  % My guess would be some Octave numerical optimalization for special cases like:
  % C = A' * B * A
  prediction_error_covariance = mround(...
      theta'*covariance_matrix*theta + noise_variance...
  );
  if(prediction_error_covariance(1,1) < 0 )
    prediction_error_covariance(1,1) = 0;
  endif
  if(prediction_error_covariance(2,2) < 0 )
    prediction_error_covariance(2,2) = 1;
  endif
  covariance_matrix = mround(...
    [...
          prediction_error_covariance,      mround(covariance_matrix*theta)';...
          mround(covariance_matrix*theta),  covariance_matrix...
    ]...
  );
    
  % Extend coefficients matrix  
  theta = [theta; zeros(2,2)];
endfunction