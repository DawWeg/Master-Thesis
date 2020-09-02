function [detection_signal_f, detection_signal_b] = expand_alarms(detection_signal_f, detection_signal_b)
  global alarm_expand model_rank;
  if(alarm_expand > 0)
    N = length(detection_signal_f);
    t = 2;
    while t <= N-model_rank-alarm_expand
      print_progress("Expanding alarms", t, N, N/100);
      if(detection_signal_f(t) == 1 && detection_signal_f(t-1) == 0 && !any(detection_signal_f(t-model_rank-alarm_expand:t-1)))
        detection_signal_f(t-alarm_expand:t-1) = 1;
      endif
      if(detection_signal_b(t) == 0 && detection_signal_b(t-1) == 1 && !any(detection_signal_b(t:t+model_rank+alarm_expand-1)))
        detection_signal_b(t:t+alarm_expand-1) = 1;
        t = t+model_rank+alarm_expand-1;
      endif
      t = t + 1;
    endwhile
    print_progress("Expanding alarms", N, N, N/100);    
  else
    return;
  endif  
endfunction
