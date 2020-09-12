function [clear_signal_fb,clear_signal_fbf,clear_signal_fbb] = bidirectional_interpolation(detection_signal_fb, ...
                                                clear_signal_f, ...
                                                clear_signal_b, ...
                                                coefficients_f, ...
                                                coefficients_b, ...
                                                noise_variance_f, ...
                                                noise_variance_b);
  N = length(detection_signal_fb);
  clear_signal_fbf = clear_signal_f;
  clear_signal_fbb = clear_signal_b;
  clear_signal_fb = clear_signal_f;
  global model_rank;
  %%% Left-side reconstruction
  t = 1;
  while t <= N
    print_progress("Left-side reconstruction", t, N, N/100);
    if(detection_signal_fb(t) == 1 && detection_signal_fb(t-1) == 0)
      block_start = t;
      i = 1;
      while(detection_signal_fb(block_start+i))
        i = i+1;
      endwhile
      block_end = t+i-1;
      clear_signal_fbf(block_start:block_end) = batch_interpolation([clear_signal_f(block_start-model_rank:block_end); ...
                                                                     clear_signal_b(block_end+1:block_end+model_rank)], ...
                                                                     coefficients_f(:,block_start-1));
      t = block_end;                                                               
    endif
    t = t + 1;
  endwhile
  print_progress("Left-side reconstruction", N, N, N/100); 
 
  %%% Right-side reconstruction 
  t = 1;
  while t <= N
    print_progress("Right-side reconstruction", t, N, N/100);
    if(detection_signal_fb(t) == 1 && detection_signal_fb(t-1) == 0)
      block_start = t;
      i = 1;
      while(detection_signal_fb(block_start+i))
        i = i+1;
      endwhile
      block_end = t+i-1;
      clear_signal_fbb(block_start:block_end) = batch_interpolation([clear_signal_f(block_start-model_rank:block_end); ...
                                                                     clear_signal_b(block_end+1:block_end+model_rank)], ...
                                                                     coefficients_b(:,block_end+1));
      t = block_end;                                                               
    endif
    t = t + 1;
  endwhile 
  print_progress("Right-side reconstruction", N, N, N/100);
  
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
