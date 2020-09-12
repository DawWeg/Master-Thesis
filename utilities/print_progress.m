function print_progress(action, current, total, step)

  if current==1 
    printf("%s starting...\n", action);
    tic();
  elseif (current < total) && (mod(current, step) == 0)
    progress = (current/total)*100;
    elapsed = (toc()*1000);
    avg = elapsed/step;
    printf("%s in progress %.5f%% | Elapsed %.5f ms | Avg loop time: %.5f ms\n", action, progress, elapsed, avg);
    tic();
  elseif current == total
    toc();
    printf("%s done %.5f%%\n", action, 100);
  endif
  

endfunction
