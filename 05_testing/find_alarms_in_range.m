function [alarms] = find_alarms_in_range(detection, range_start, range_end)
  alarms = zeros(2,range_end-range_start);
  alarm_pos = 1;
  pointer = range_start;
  
  while (pointer <= range_end)
    
    if detection(pointer)
      
      % find alarm beginning
      tmp_pointer = pointer;
      while ( (tmp_pointer > 1) && detection(tmp_pointer-1) )
        tmp_pointer--;
      endwhile
      alarms(1, alarm_pos) = tmp_pointer;
      
      % find alarm end
      tmp_pointer = pointer;
      while ( (tmp_pointer < length(detection)) && detection(tmp_pointer+1) )
        tmp_pointer++;
      endwhile
      alarms(2, alarm_pos) = tmp_pointer;
      alarm_pos++;
      pointer = tmp_pointer; % update to end
    endif
  
    pointer++;
  endwhile
  
  alarms = alarms(:,1:alarm_pos-1);
endfunction
