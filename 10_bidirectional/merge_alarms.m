function [d_fb] = merge_alarms(d_f, d_b)
  global alarm_expand model_rank;
  ex_d_f = expand_alarms_2(d_f);
  ex_d_b = expand_alarms_2(d_b);
  d_b = flip(d_b);
  ex_d_b = flip(ex_d_b);
  
  
  d_fb = zeros(size(d_f));
endfunction
