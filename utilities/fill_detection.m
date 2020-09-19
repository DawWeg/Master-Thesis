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
