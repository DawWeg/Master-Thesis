% Detects whether sample is corrupted or not based on error and prediction error covariance
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
