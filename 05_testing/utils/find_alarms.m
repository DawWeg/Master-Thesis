function [alarms] = find_alarms(detection)
  alarms = zeros(2,length(detection));
  alarm_pos = 1;
  N = length(detection)-1;
  for i = 2:N
    if( (detection(i-1) == 0) && (detection(i) == 1))
      alarms(1,alarm_pos) = i;
    endif 
    
    if( (detection(i) == 1) && (detection(i+1) == 0))
      alarms(2,alarm_pos) = i;
      alarm_pos++;
    endif 
  endfor
  alarms = alarms(:,1:alarm_pos-1);
endfunction
