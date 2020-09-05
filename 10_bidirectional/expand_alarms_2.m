function [new_detection] = expand_alarms_2(old_detection)
  global alarm_expand model_rank;
  delta = alarm_expand;
  new_detection = old_detection;
  detected_samples = find(old_detection);
  N = length(detected_samples);
  for i=1:N
    % Calculate distance between corrupted samples
    current_corrupt = detected_samples(i);
    % If this is first alarm, treat begining of the signal as boundry
    % Should not happen on real life example
    last_corrupt = 0;
    if (i==1)
      last_corrupt = [1 1];
    else
      last_corrupt = detected_samples(i-1);
    endif
    detection_distance = current_corrupt - last_corrupt;
    
    % If distance is greater than 0
    if detection_distance > 0
      
      % Check if alarm separation will be kept for delta
      if detection_distance > model_rank + delta
        % If yes, expand it
        new_detection(current_corrupt-delta:current_corrupt) = 1;
      else  
        % If no, calculate if there still is available space to expand
        available_space = detection_distance - model_rank - 1;
        if available_space > 0
          % if it is possible to expand, then expand
          new_detection(current_corrupt-available_space:current_corrupt) = 1;
        endif
      endif
    
    endif
  endfor
endfunction