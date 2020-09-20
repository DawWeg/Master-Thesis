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
     
  cov_matrix_length = length(covariance_matrix);
  if(detection(1) == 0 && detection(2) == 0)
    % Both OK
    %Inversion of 2x2 matrix
    error_cov_inv = (1/det(error_covariance))*[  error_covariance(2,2) -error_covariance(1,2); ...
                                                -error_covariance(2,1)  error_covariance(1,1) ];
           
    gain_vector  = covariance_matrix(:,1:2)*error_cov_inv;
                        
    % For numerical error prevention -> force ones
    gain_vector(1:2,1:2) = eye(2,2);
    gain_vector = mround(gain_vector);
    state_vector = state_vector + gain_vector*error;    
                        
   % For numerical error prevention -> force positiver definite
   CCx = [eye(2,2) zeros(2, cov_matrix_length - 2)];
   ZZ = ( eye(cov_matrix_length) - gain_vector*CCx);
   covariance_matrix = ZZ*covariance_matrix*ZZ';     
   covariance_matrix(1:2,1:2) = zeros(2);
  elseif (detection(1) == 0 && detection(2) != 0)
    % Right not ok
    if error_covariance(1,1) == 0
      error_covariance(1,1) = 1e-12;
    endif
    gain_vector  = (1/error_covariance(1,1))*(covariance_matrix(:,1));

    % For numerical error prevention -> force one
    gain_vector(1) = 1;
    gain_vector = mround(gain_vector);
    state_vector = state_vector + gain_vector*error(1);
    
    % For numerical error prevention -> force positiver definite
    CCx = [1 0 zeros(1,cov_matrix_length-2)];    
    ZZ  = (eye(cov_matrix_length) - gain_vector*CCx);
    covariance_matrix = ZZ*covariance_matrix*ZZ';     
    covariance_matrix(1,1) = 0;  
  elseif (detection(1) != 0 && detection(2) == 0 )
    % Left not ok
    if error_covariance(2,2) == 0
      error_covariance(2,2) = 1e-12;
    endif
    gain_vector   = (1/error_covariance(2,2))*(covariance_matrix(:,2));

    % For numerical error prevention -> force one
    gain_vector(2) = 1;
    gain_vector = mround(gain_vector);
    state_vector = state_vector + gain_vector*error(2);
    
    % For numerical error prevention -> force positiver definite
    CCx = [0 1 zeros(1,cov_matrix_length-2)];    
    ZZ  = (eye(cov_matrix_length) - gain_vector*CCx);
    covariance_matrix = ZZ*covariance_matrix*ZZ';     
    covariance_matrix(2,2) = 0;
  else
    % Both not ok
    % NoOp
  endif
  
  state_vector = mround(state_vector);
  covariance_matrix = mround(covariance_matrix);
endfunction
