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
