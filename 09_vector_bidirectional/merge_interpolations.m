function [clear_fb] = merge_interpolations(clear_fb, d_fb, clear_fbf, var_fbf, clear_fbb, var_fbb)
    [alarms] = find_alarms(d_fb);

    for alarm=alarms
      var_f = var_fbf(1,alarm(1)-1);
      var_b = var_fbb(1,alarm(2)+1);

      wf = var_b/(var_f+var_b);
      wb = var_f/(var_f+var_b);
      clear_fb(1,alarm(1):alarm(2)) = ...
        wf.*(clear_fbf(1,alarm(1):alarm(2)))...
        +...
        wb.*(clear_fbb(1,alarm(1):alarm(2)));
    endfor
endfunction
