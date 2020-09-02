function [detection_signal_fb] = analyze_block (detection_signal_f, detection_signal_b)
  global AR_model_order alarm_expand BIDI_MODE;
  block_length = length(detection_signal_f);
  alarm_length = block_length - 2*AR_model_order;
  detection_signal_fb = zeros(size(detection_signal_f));
  alarm_indices_f = find(detection_signal_f);
  alarm_indices_b = find(detection_signal_b);

  % Configurations C
  if(isempty(alarm_indices_f))
    if(BIDI_MODE(3) == 0)
      detection_signal_fb(alarm_indices_b(1):alarm_indices_b(end)) = 1;
      return;
    elseif(BIDI_MODE(3) == 1)
      return;
    elseif(BIDI_MODE(3) == 2)
      % TODO meanwhile logic sum
      detection_signal_fb(alarm_indices_b(1):alarm_indices_b(end)) = 1;      
      return;
    endif
  elseif(isempty(alarm_indices_b))
    if(BIDI_MODE(3) == 0)
      detection_signal_fb(alarm_indices_f(1):alarm_indices_f(end)) = 1;
      return;
    elseif(BIDI_MODE(3) == 1)
      return;
    elseif(BIDI_MODE(3) == 2)
      % TODO
      detection_signal_fb(alarm_indices_f(1):alarm_indices_f(end)) = 1;      
      return;
    endif
  endif

  % Configurations A
  if(alarm_indices_f(1) < alarm_indices_b(end) && alarm_indices_b(1) < alarm_indices_f(end))
    if(BIDI_MODE(1) == 0)
      detection_signal_fb(min([alarm_indices_f(1), alarm_indices_b(1)]):max([alarm_indices_f(end), alarm_indices_b(end)])) = 1;
      return;
    elseif(BIDI_MODE(1) == 1)
      detection_signal_fb(max([alarm_indices_f(1), alarm_indices_b(1)]):min([alarm_indices_f(end), alarm_indices_b(end)])) = 1;
      return;
    elseif(BIDI_MODE(1) == 2)      
      detection_signal_fb(alarm_indices_f(1):alarm_indices_f(end)) = 1;      
      return;
    endif
  endif
  
  % Configurations B
  if(alarm_indices_f(1) > alarm_indices_b(end) || alarm_indices_b(1) > alarm_indices_f(end))
    if(BIDI_MODE(2) == 0)
      detection_signal_fb(min([alarm_indices_f(1), alarm_indices_b(1)]):max([alarm_indices_f(end), alarm_indices_b(end)])) = 1;
      return;
    elseif(BIDI_MODE(2) == 1)      
      return;
    endif
  endif
  
  % Configurations D
  if(BIDI_MODE(1) == 0)
    detection_signal_fb(min([alarm_indices_f(1), alarm_indices_b(1)]):max([alarm_indices_f(end), alarm_indices_b(end)])) = 1;
    return;
  elseif(BIDI_MODE(1) == 1)
    detection_signal_fb(max([alarm_indices_f(1), alarm_indices_b(1)]):min([alarm_indices_f(end), alarm_indices_b(end)])) = bitand(detection_signal_f, detection_signal_b);
    return;
  elseif(BIDI_MODE(1) == 2)      
    detection_signal_fb(alarm_indices_f(1):alarm_indices_f(end)) = 1;      
    return;
  endif
endfunction
