function [detection_signal_fb] = merge_alarms(detection_signal_f, detection_signal_b)
  %%% detection_signal_b ALREADY FLIPPED!
  global alarm_expand model_rank max_corrupted_block_length;
  N = length(detection_signal_f);
  detection_signal_fb = zeros(1,N);
  detection_signal_f = expand_alarms_2(detection_signal_f);
  detection_signal_b = expand_alarms_2(detection_signal_b);
  t = 2;
  while t < N
    print_progress("Creating bidirectional alarm", t, N, N/100);
    if((detection_signal_f(t) == 1 && detection_signal_f(t-1) == 0) || (detection_signal_b(t) == 1 && detection_signal_b(t-1) == 0))
      block_start = t - model_rank;
      
      for i = 1:max_corrupted_block_length
        if(!any(detection_signal_f(t+i:t+i+model_rank-1)) && !any(detection_signal_b(t+i:t+i+model_rank-1)))
          block_end = t+i+model_rank-1;
          alarm_indices_f = find(detection_signal_f(block_start:block_end));
          alarm_indices_b = find(detection_signal_b(block_start:block_end));
          
          %%% Configurations C
          if(isempty(alarm_indices_f))
            detection_signal_fb(block_start+alarm_indices_b(1)-1) = 1;           
            alarm_length = alarm_indices_b(end)-alarm_indices_b(1);
            if(alarm_length >= alarm_expand)
              detection_signal_fb(block_start+alarm_indices_b(1):block_start+alarm_indices_b(1)+alarm_expand+1) = 1;
            else
              for i = alarm_expand:-1:1
                if(!any(detection_signal_b(alarm_indices_b(end)+1:alarm_indices_b(end)+model_rank+i-alarm_length-1)))
                  detection_signal_fb(block_start+alarm_indices_b(1):block_start+alarm_indices_b(1)+i+1) = 1;
                  break;
                endif
              endfor  
            endif
            t = block_end;
            break;         
          elseif(isempty(alarm_indices_b))
            detection_signal_fb(block_start+alarm_indices_f(1)-1) = 1;           
            alarm_length = alarm_indices_f(end)-alarm_indices_f(1);
            if(alarm_length >= alarm_expand)
              detection_signal_fb(block_start+alarm_indices_f(1):block_start+alarm_indices_f(1)+alarm_expand+1) = 1;
            else
              for i = alarm_expand:-1:1
                if(!any(detection_signal_f(alarm_indices_f(end)+1:alarm_indices_f(end)+model_rank+i-alarm_length-1)))
                  detection_signal_fb(block_start+alarm_indices_f(1):block_start+alarm_indices_f(1)+i+1) = 1;
                  break;
                endif
              endfor  
            endif
            t = block_end;
            break;
          %%% Configurations A
          elseif(alarm_indices_f(1) < alarm_indices_b(end) && alarm_indices_b(1) < alarm_indices_f(end))          
            detection_signal_fb(block_start+alarm_indices_f(1)-1:block_start+alarm_indices_b(end)-1) = 1;
            t = block_end;
            break;
          %%% Configurations B
          elseif(alarm_indices_f(1) > alarm_indices_b(end) || alarm_indices_b(1) > alarm_indices_f(end))
            detection_signal_fb(block_start+min([alarm_indices_f(1), alarm_indices_b(1)])-1:block_start+max([alarm_indices_f(end), alarm_indices_b(end)])-1) = 1;
            t = block_end;
            break;
          %%% Configurations D
          else
            detection_signal_fb(block_start+alarm_indices_f(1)-1:block_start+alarm_indices_b(end)-1) = 1;
            t = block_end;
            break;
          endif          
        endif
      endfor      
    endif    
    t = t + 1;
  endwhile
  print_progress("Creating bidirectional alarm", N, N, N/100);
endfunction
