function [lr_detection_signal] = analyze_block (l_detection_signal, r_detection_signal)
global AR_model_order alarm_expand;
block_length = length(l_detection_signal );
alarm_length = block_length - 2*AR_model_order;
lr_detection_signal = zeros(size(l_detection_signal));
l_alarm_indices = find(l_detection_signal);
r_alarm_indices = find(r_detection_signal);

% Class C - logic sum(alarm unchanged)
if(isempty(l_alarm_indices))  
  lr_detection_signal(r_alarm_indices(1):r_alarm_indices(end)) = 1;
  return;
elseif(isempty(r_alarm_indices))
  lr_detection_signal(l_alarm_indices(1):l_alarm_indices(end)) = 1;
  return;
endif

% Class A - "front slope - front slope"
if((l_alarm_indices(end) <= r_alarm_indices(end)) || (r_alarm_indices(end) <= l_alarm_indices(end)))
  lr_detection_signal(l_alarm_indices(1):r_alarm_indices(end)) = 1;
  return;
endif
endfunction
