function [alarm_start, alarm_end] = alarm_boundries(error, time, release_threshold)
    alarm_start = time;
    alarm_end = time;
    
    % Find alarm beginning 
    while (error(alarm_start) > release_threshold && alarm_start > 1)
      alarm_start--;
    endwhile
    
    % Find alarm end
    while (error(alarm_end) > release_threshold && alarm_end < length(error))
      alarm_end++;
    endwhile
endfunction
