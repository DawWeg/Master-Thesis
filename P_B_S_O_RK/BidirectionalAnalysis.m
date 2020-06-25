function [lr_detection_signal, lr_clear_signal, lrl_clear_signal, lrr_clear_signal] = BidirectionalAnalysis(l_detection_signal, r_detection_signal)
%%% Preparing variables
global N alarm_expand AR_model_order;
lr_detection_signal = zeros(1, N);
lr_clear_signal = zeros(1, N);
lrl_clear_signal = zeros(1, N);
lrr_clear_signal = zeros(1, N);

%%% Expanding alarms
disp("Expanding alarms");
for t = 2:N
  if(l_detection_signal(t) == 1 && l_detection_signal(t-1) == 0 && !any(l_detection_signal(t-AR_model_order-alarm_expand:t-1)))
    l_detection_signal(t-alarm_expand:t-1) = 1;
  endif
  if(r_detection_signal(t) == 0 && r_detection_signal(t-1) == 0 && !any(r_detection_signal(t+AR_model_order+alarm_expand:t+1)))
    r_detection_signal(t+alarm_expand:t+1) = 1;
  endif
  if(mod(t,1000) == 0)
      printf("[%3.1f|100]\n", (t/N)*100);
  endif
endfor
disp("[100|100]");

%%% Creating bidirectional alarm_expand
disp("Creating bidirectional alarm");
disp("[100|100]");
endfunction
