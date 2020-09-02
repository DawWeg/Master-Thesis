function [detection_signal_fb] = create_bidirectional_alarm(detection_signal_f, detection_signal_b)
  global model_rank max_corrupted_block_length;
  N = length(detection_signal_f);
  detection_signal_fb = zeros(size(detection_signal_f)); 
  t = 2;
  while t < N
    print_progress("Creating bidirectional alarm", t, N, N/100);
    if((detection_signal_f(t) == 1 && detection_signal_f(t-1) == 0) || (detection_signal_b(t) == 1 && detection_signal_b(t-1) == 0))
      block_start_index = t - model_rank;
      for i = 1:max_corrupted_block_length
        if(!any(detection_signal_f(t+i:t+i+model_rank-1)) && !any(detection_signal_b(t+i:t+i+model_rank-1)))
          block_end_index = t+i+model_rank - 1;
          detection_signal_fb(block_start_index:block_end_index) = analyze_block(detection_signal_f(block_start_index:block_end_index), detection_signal_b(block_start_index:block_end_index));
          t = block_end_index;
          break;
        endif
      endfor      
    endif
    t = t + 1;
  endwhile
  print_progress("Creating bidirectional alarm", N, N, N/100);
endfunction
