 function [lr_detection_signal, lr_clear_signal, lrl_clear_signal, lrr_clear_signal] = bidirectional_analysis(l_detection_signal, r_detection_signal)
%%% Preparing variables
global alarm_expand model_rank max_corrupted_block_length;
N = length(l_detection_signal);
lr_detection_signal = zeros(1, N);

%%% Expanding alarms
disp("Expanding alarms");
for t = 2:N
  if(l_detection_signal(t) == 1 && l_detection_signal(t-1) == 0 && !any(l_detection_signal(t-model_rank-alarm_expand:t-1)))
    l_detection_signal(t-alarm_expand:t-1) = 1;
  endif
  if(r_detection_signal(t) == 0 && r_detection_signal(t-1) == 0 && !any(r_detection_signal(t+model_rank+alarm_expand:t+1)))
    r_detection_signal(t+alarm_expand:t+1) = 1;
  endif
  if(mod(t,1000) == 0)
      printf("[%3.1f|100]\n", (t/N)*100);
  endif
endfor
disp("[100|100]");

%%% Creating bidirectional alarm
disp("Creating bidirectional alarm");
for t = 2:N
  if((l_detection_signal(t) == 1 && l_detection_signal(t-1) == 0) || (r_detection_signal(t) == 1 && r_detection_signal(t-1) == 0))
    block_start_index = t - model_rank;
    for i = 1:max_corrupted_block_length
      if(!any(l_detection_signal(t+i:t+i+model_rank-1)) && !any(r_detection_signal(t+i:t+i+model_rank-1)))
        block_end_index = t+i+model_rank - 1;
        lr_detection_signal(block_start_index:block_end_index) = analyze_block(l_detection_signal(block_start_index:block_end_index), r_detection_signal(block_start_index:block_end_index));
        t = block_end_index + 1;
        break;
      endif
    endfor      
  endif
  if(mod(t,1000) == 0)
      printf("[%3.1f|100]\n", (t/N)*100);
  endif
endfor
disp("[100|100]");

endfunction
