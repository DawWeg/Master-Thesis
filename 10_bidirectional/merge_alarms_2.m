function [detection_signal_fb] = merge_alarms_2(detection_signal_f, detection_signal_b)
  
  global alarm_expand model_rank max_corrupted_block_length;
  N = length(detection_signal_f);
  alarm_start_f = [];
  ex_alarm_start_f = [];
  alarm_end_f = [];
  alarm_start_b = [];
  alarm_end_b = [];
  ex_alarm_end_b = [];

  for i = 2:N
    if(detection_signal_f(i) == 1 && detection_signal_f(i-1) == 0)
      alarm_start_f = [alarm_start_f, i];
    endif
    if(detection_signal_f(i) == 0 && detection_signal_f(i-1) == 1)
      alarm_end_f = [alarm_end_f, i-1];
    endif
    if(detection_signal_b(i) == 1 && detection_signal_b(i-1) == 0)
      alarm_start_b = [alarm_start_b, i];
    endif
    if(detection_signal_b(i) == 0 && detection_signal_b(i-1) == 1)
      alarm_end_b = [alarm_end_b, i-1];
    endif
  endfor 
  
  detection_signal_fb = zeros(1,N);
  detection_signal_f = expand_alarms_2(detection_signal_f);
  detection_signal_b = flip(expand_alarms_2(flip(detection_signal_b)));
  
  for i = 2:N
    if(detection_signal_f(i) == 1 && detection_signal_f(i-1) == 0)
      ex_alarm_start_f = [ex_alarm_start_f, i];
    endif
    if(detection_signal_b(i) == 0 && detection_signal_b(i-1) == 1)
      ex_alarm_end_b = [ex_alarm_end_b, i-1];
    endif
  endfor 
  
  t = 2;
  while t < N - max_corrupted_block_length
    print_progress("Creating bidirectional alarm", t, N, N/100);
    if((detection_signal_f(t) == 1 && detection_signal_f(t-1) == 0) || (detection_signal_b(t) == 1 && detection_signal_b(t-1) == 0))
      block_start = t - model_rank;
      
      for i = 1:max_corrupted_block_length      %%% jak to ma byc odkomentowane to musi byc tez ten elseif na dole
      %for i = 1:N-max_corrupted_block_length-t   %%% jak to ma byc odkomentowane to tamto nie musi byc
        if(!any(detection_signal_f(t+i:t+i+model_rank-1)) && !any(detection_signal_b(t+i:t+i+model_rank-1)))
          block_end = t+i+model_rank-1;
          alarm_indices_f = find(detection_signal_f(block_start:block_end));
          alarm_indices_b = find(detection_signal_b(block_start:block_end));
          
          %%% Configurations C
          if(isempty(alarm_indices_f))
            detection_signal_fb(alarm_end_b(1):alarm_end_b(1)+alarm_expand) = detection_signal_b(alarm_end_b(1):alarm_end_b(1)+alarm_expand);
            alarm_length = alarm_end_b(1) - alarm_start_b(1);    
            if(alarm_length >= alarm_expand)
              detection_signal_fb(alarm_end_b(1)-alarm_expand:alarm_end_b(1)-1) = 1;
            else
              for i = alarm_expand:-1:1
                if(!any(detection_signal_fb(alarm_end_b(1)-i-model_rank:alarm_start_b(1)-1)))
                  detection_signal_fb(alarm_end_b(1)-i:alarm_end_b(1)-1) = 1;
                  break;
                 endif
              endfor
            endif     
            if(length(ex_alarm_start_f) > 1 && t == ex_alarm_start_f(1))              
              alarm_start_f = alarm_start_f(2:end);
              ex_alarm_start_f = ex_alarm_start_f(2:end);
              alarm_end_f = alarm_end_f(2:end);
            endif
            if(length(ex_alarm_end_b) > 1 && t+i-1 == ex_alarm_end_b(1))
              alarm_end_b = alarm_end_b(2:end);
              ex_alarm_end_b = ex_alarm_end_b(2:end);
              alarm_start_b = alarm_start_b(2:end);
            endif 
            t = block_end;
            break;         
          elseif(isempty(alarm_indices_b))
            detection_signal_fb(alarm_start_f(1)-alarm_expand:alarm_start_f(1)) = detection_signal_f(alarm_start_f(1)-alarm_expand:alarm_start_f(1));           
            alarm_length = alarm_end_f(1) - alarm_start_f(1);
            if(alarm_length >= alarm_expand)
              detection_signal_fb(alarm_start_f(1)+1:alarm_start_f(1)+alarm_expand) = 1;
            else
              for i = alarm_expand:-1:1
                if(!any(detection_signal_fb(alarm_end_f(1)+1:alarm_start_f(1)+i+model_rank)))
                  detection_signal_fb(alarm_start_f(1)+1:alarm_start_f(1)+i) = 1;
                  break;
                endif
              endfor  
            endif
            if(length(ex_alarm_start_f) > 1 && t == ex_alarm_start_f(1))              
              alarm_start_f = alarm_start_f(2:end);
              ex_alarm_start_f = ex_alarm_start_f(2:end);
              alarm_end_f = alarm_end_f(2:end);
            endif
            if(length(ex_alarm_end_b) > 1 && t+i-1 == ex_alarm_end_b(1))
              alarm_end_b = alarm_end_b(2:end);
              ex_alarm_end_b = ex_alarm_end_b(2:end);
              alarm_start_b = alarm_start_b(2:end);
            endif   
            t = block_end;
            break;
          %%% Configurations A
          elseif(alarm_indices_f(1) < alarm_indices_b(end) && alarm_indices_b(1) < alarm_indices_f(end))          
            detection_signal_fb(block_start+alarm_indices_f(1)-1:block_start+alarm_indices_b(end)-1) = 1;
            if(length(ex_alarm_start_f) > 1 && t == ex_alarm_start_f(1))              
              alarm_start_f = alarm_start_f(2:end);
              ex_alarm_start_f = ex_alarm_start_f(2:end);
              alarm_end_f = alarm_end_f(2:end);
            endif
            if(length(ex_alarm_end_b) > 1 && t+i-1 == ex_alarm_end_b(1))
              alarm_end_b = alarm_end_b(2:end);
              ex_alarm_end_b = ex_alarm_end_b(2:end);
              alarm_start_b = alarm_start_b(2:end);
            endif  
            t = block_end;
            break;
          %%% Configurations B
          elseif(alarm_indices_f(1) > alarm_indices_b(end) || alarm_indices_b(1) > alarm_indices_f(end))
            detection_signal_fb(block_start+min([alarm_indices_f(1), alarm_indices_b(1)])-1:block_start+max([alarm_indices_f(end), alarm_indices_b(end)])-1) = 1;
            if(length(ex_alarm_start_f) > 1 && t == ex_alarm_start_f(1))              
              alarm_start_f = alarm_start_f(2:end);
              ex_alarm_start_f = ex_alarm_start_f(2:end);
              alarm_end_f = alarm_end_f(2:end);
            endif
            if(length(ex_alarm_end_b) > 1 && t+i-1 == ex_alarm_end_b(1))
              alarm_end_b = alarm_end_b(2:end);
              ex_alarm_end_b = ex_alarm_end_b(2:end);
              alarm_start_b = alarm_start_b(2:end);
            endif  
            t = block_end;
            break;
          %%% Configurations D
          else
            detection_signal_fb(block_start+alarm_indices_f(1)-1:block_start+alarm_indices_b(end)-1) = 1;
            if(length(ex_alarm_start_f) > 1 && t == ex_alarm_start_f(1))              
              alarm_start_f = alarm_start_f(2:end);
              ex_alarm_start_f = ex_alarm_start_f(2:end);
              alarm_end_f = alarm_end_f(2:end);
            endif
            if(length(ex_alarm_end_b) > 1 && t+i-1 == ex_alarm_end_b(1))
              alarm_end_b = alarm_end_b(2:end);
              ex_alarm_end_b = ex_alarm_end_b(2:end);
              alarm_start_b = alarm_start_b(2:end);
            endif  
            t = block_end;
            break;
          endif 
        elseif(i == max_corrupted_block_length)
        disp("hiya");
          block_end = t+i;
          alarm_indices_f = find(detection_signal_f(block_start:block_end));
          alarm_indices_b = find(detection_signal_b(block_start:block_end));
          if(!any(alarm_indices_f))
            detection_signal_fb(block_start+alarm_indices_b(1)-1:block_start+alarm_indices_b(end)-1) = 1;
          elseif(!any(alarm_indices_b))
            detection_signal_fb(block_start+alarm_indices_f(1)-1:block_start+alarm_indices_f(end)-1) = 1;
          else
            detection_signal_fb(block_start+alarm_indices_f(1)-1:block_start+alarm_indices_b(end)-1) = 1;
          endif          
          if(length(ex_alarm_start_f) > 1 && t == ex_alarm_start_f(1))              
            alarm_start_f = alarm_start_f(2:end);
            ex_alarm_start_f = ex_alarm_start_f(2:end);
            alarm_end_f = alarm_end_f(2:end);
          endif
           if(length(ex_alarm_end_b) > 1 && t+i-1 == ex_alarm_end_b(1))
            alarm_end_b = alarm_end_b(2:end);
            ex_alarm_end_b = ex_alarm_end_b(2:end);
            alarm_start_b = alarm_start_b(2:end);
          endif   
          t = block_end;
          break;          
        endif
      endfor      
    endif    
    t = t + 1;
  endwhile
  print_progress("Creating bidirectional alarm", N, N, N/100);
  
  
  
  
  
  
%  i = 1; 
%  while(i < max([n_alarms_f, n_alarms_b]))
%    if(i <= length(n_alarms_f))    
%      if(i <= length(n_alarms_b))
%      %%% there are more alarms in both side analysis
%        block_start = min([ex_alarm_start_f(i), alarm_start_b(i)]);
%        while(1)
%          
%        endwhile
%      else
%      %%% there are more alarms ONLY in frontside analysis
%      
%      
%      endif
%    elseif(i <= length(n_alarms_b)) 
%      %%% there are more alarms ONLY in backside analysis
%      
%    
%    else
%      %%% there are NO MORE alarms
%      
%      
%    endif
%  endwhile
  
endfunction
