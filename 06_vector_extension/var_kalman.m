1;

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

% Updates Kalman state vector and covariance_matrix for next step
% Args:
%   @error              - Current Kalman prediction error
%   @error_covariance   - Current Kalman prediction error covariance
% Returns:
%   @detection          - Detection decisions
%   @threshold          - Threshold used in detection 
function [detection, threshold] = var_kalman_detect(error, error_covariance)
     global mu;
     % Taking absolute value of error covariances (just to be sure it won't 
     % fail during some edgecase
     threshold = zeros(2,1);
     threshold(1) = mround(mu*sqrt(abs(error_covariance(1,1))));
     threshold(2) = mround(mu*sqrt(abs(error_covariance(2,2))));
     detection = abs(error) > threshold;
endfunction


% Updates Kalman state vector and covariance_matrix for next step
% Args:
%   @detection          - Current detection decisions
%   @state_vector       - Current Kalman state vector
%   @error              - Current Kalman prediction error
%   @error_covariance   - Current Kalman prediction error covariance
%   @covariance_matrix  - Current Kalman covariance matrix
% Returns:
%   @state_vector       - Updated Kalman state vector 
%   @covariance_matrix  - Updated Kalman covariance matrix
function [ state_vector,...
           covariance_matrix ] = var_kalman_update( detection,...
                                                    state_vector,...
                                                    error,...
                                                    error_covariance,...
                                                    covariance_matrix )
     L = mround(...
            build_gain_vector(...
                detection,... 
                error_covariance,...
                covariance_matrix...
            )...
        );
          
     state_vector = mround(state_vector + mround(L*error));
     covariance_matrix = mround(covariance_matrix - mround(L*error_covariance*L'));
endfunction


% Create gain vector based on current Kalman algorithm results
% Args:
%   @detection    - Current detection
%   @kalman_var   - Current prediction error covariance
%   @cov_matrix   - Current covariance matrix
% Returns:
%   @gain_vector  - Calculated gain vector
function [gain_vector] = build_gain_vector(detection, kalman_var, cov_matrix)
      % Round up, again to be sure
      ro1 = mround(kalman_var(1,1));
      ro2 = mround(kalman_var(2,2));
      % Check  if matrix is invertible 
      det_ro = mround(det(mround(kalman_var)));
      ok_all = det_ro > 1e-12;
      
      % Check if variance is greater than precision
      ok_1 = ro1 > 1e-12;
      ok_2 = ro2 > 1e-12;      
      
      % Currently we override this protection as after changing the way of 
      % calculating H matrix it does not seem to help at all
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
      
      if(gain_vector(1,1) > 1)
        gain_vector = 1;
      endif
      if(gain_vector(2,2) > 1)
        gain_vector = 1;
      endif
endfunction


% 2 channel variant of false alarms detection
% Args:
%   @detection      - Detection signal to analyze
%   @t0             - Start sample number
%   @tk             - End sample number
% Returns:
%   @new_detection  - New detection signal (if no alarms raised, same as initial one)
%   @false_alarm    - Flag if false alarms were found
function [new_detection, false_alarm] = var_false_alarms(detection, t0, tk)
    global model_rank;
    false_alarm = 0; 
    new_detection = detection;
    [new_detection_l, false_l] =  fill_detection(detection(1,:), model_rank);
    [new_detection_r, false_r] =  fill_detection(detection(2,:), model_rank);
    
    if(false_l)
      new_detection(1,:) = new_detection_l;
      false_alarm = 1;
    endif
    
    if(false_r)
      new_detection(2,:) = new_detection_r;
      false_alarm = 1;
    endif
    
    new_detection = (detection + new_detection) > 0;
endfunction


% Fills false alarms in detection signal with ones. Returns flag whether any
% false alarms were found.
% Args:
%   @detection        - Detection signal to analyze
%   @model_rank       - Rank of the model
% Returns:
%   @filled_detection - New detection signal (if no alarms raised, same as initial one)
%   @false            - Flag if false alarms were found
function [filled_detection, false] = fill_detection(detection, model_rank)
  correct_counter = 0;
  filled_detection = detection;
  % Find indices of all non zero values in detection signal
  detected_samples = find(detection);
  
  for i=1:length(detected_samples)-1
    % If difference between index of current corrupted sample
    % and next corrupted sample is less than model rank
    % Mark all samples inbetween as corruptedm
    if(detected_samples(i+1)-detected_samples(i) < model_rank)
      filled_detection(detected_samples(i):detected_samples(i+1)) = 1;
    endif
  endfor
  % If control sums of initial detection and filled detection are not the same
  % Raise false alarms flag
  false = sum(filled_detection) != sum(detection);
endfunction


% Perform Kalman VAR model algorithm with defined detection signal
% Args:
%   @signal                 - 2 Channel input signal
%   @detection              - 2 Channel predefined detection signal
%   @t_start                - Algorithm starting sample
%   @t_end                  - Algorithm end sample
%   @theta                  - EWLS model coefficients
%   @noise_variance         - Noise variance estimated by EWLS algorithm
% Returns;
%   @signal_reconstruction  - Reconstructed signal
function [signal_reconstruction] = var_kalman_interpolator( signal,...
                                                            detection,...
                                                            t_start,...
                                                            t_end,...
                                                            theta,...
                                                            noise_variance )
    global model_rank;
    
    covariance_matrix = zeros(2*model_rank, 2*model_rank);
    state_vector = mround(init_regression_vector(signal, model_rank, t_start+1));

    for tk=t_start+1:t_end;
      [ theta, ...
        state_vector, ...
        error, ...
        error_covariance, ...
        covariance_matrix ] = var_kalman_step( theta,...
                                               state_vector,...
                                               signal(:,tk),...
                                               covariance_matrix,...
                                               noise_variance );
     
     [ state_vector,...
       covariance_matrix ] = var_kalman_update( detection(:,tk),...
                                                state_vector,...
                                                error,...
                                                error_covariance,...
                                                covariance_matrix );
    endfor

    signal_reconstruction = retrieve_reconstruction(state_vector);
endfunction


% Retrieves reconstructed signal from VAR model Kalman state vector
% Args:
%   @state_vector           - Kalman state vector containing interpolation
% Returns:
%   @signal_reconstruction  - Reconstructed signal retrieved from state vector
function [signal_reconstruction] = retrieve_reconstruction(state_vector)
      reconstruction_l = state_vector(1:2:end)';
      reconstruction_r = state_vector(2:2:end)';  
      signal_reconstruction = [flip(reconstruction_l); flip(reconstruction_r)];   
endfunction


% Initializes regression vector based on input signal
% Args:
%   @signal       - Signal to create regression vector from
%   @r            - Model rank
% Returns:
%   @regression   - Regression vector
function [regression] = init_regression_vector(signal, r, t0);
  %ewls_regression(:,t) = [clear_signal(:,t-1); ewls_regression(1:end-2, t-1)]; 
  regression = signal(:,t0-r);
  for n=r-1:-1:1
    regression = [signal(:,t0-n); regression];
  endfor
endfunction


