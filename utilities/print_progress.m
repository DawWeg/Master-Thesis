function print_progress(action, current, total, step)
  progress = (current/total)*100;
  elapsed = (toc()*1000)/step;
  if current==1 
    printf("%s starting...\n", action);
  elseif (current < total) && (mod(current, step) == 0)
    printf("%s in progress %.5f%% | Avg loop time: %.5f ms\n", action, progress, elapsed);
  elseif current == total
    printf("%s done %.5f%%\n", action, progress);
  endif
  
  tic();
endfunction
