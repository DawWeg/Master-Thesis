function [clear_signal_fb] = bidirectional_interpolation(detection_signal_fb, ...
                                                clear_signal_fbf, ...
                                                clear_signal_fbb, ...
                                                input_signal, ...
                                                noise_variance_f, ...
                                                noise_variance_b);
  N = length(detection_signal_fb); 
  clear_signal_fb = input_signal;
  global model_rank;  
  
  %%% Bidirectional reconstruction
  t = 1;
  while t <= N
    print_progress("Bidirectional reconstruction", t, N, N/100);
    if(detection_signal_fb(t) == 1 && detection_signal_fb(t-1) == 0)
      block_start = t;
      i = 1;
      while(detection_signal_fb(block_start+i))
        i = i+1;
      endwhile
      block_end = t+i-1;
      wf = noise_variance_b(block_end+1)/(noise_variance_f(block_start-1)+noise_variance_b(block_end+1));
      wb = noise_variance_f(block_start-1)/(noise_variance_f(block_start-1)+noise_variance_b(block_end+1));
      for i = block_start:block_end
        clear_signal_fb(i) = wf*clear_signal_fbf(i) + wb*clear_signal_fbb(i);
      endfor
      t = block_end;                                                               
    endif
    t = t + 1;
  endwhile 
  print_progress("Bidirectional reconstruction", N, N, N/100);
    
endfunction
