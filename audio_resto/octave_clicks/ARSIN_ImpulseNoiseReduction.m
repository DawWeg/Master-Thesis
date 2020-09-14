## This script generates audio samples in directory samps/
function [clear_signal] = ARSIN_ImpulseNoiseReduction(input_signal)
  lead_in = 1024;
  lead_out = 1024;

  p = 31;
  q = 31;
  w = 1024;

  threshold = 5;
  fatness = 4;
  interp_iters = 3;

  y_l = input_signal(:,1);
  [xl idl] = do_arsin_process(y_l, p, q, w, lead_in, lead_out, threshold, \
          fatness, interp_iters);
          
  y_r = input_signal(:,2);
  [xr idr] = do_arsin_process(y_r, p, q, w, lead_in, lead_out, threshold, \
          fatness, interp_iters);

  x = [xl, xr];

  save("-binary", get_data_save_filename("ARSIN"), "idl", "idr");
  save_audio("ARSIN", x, 0);
##
endfunction
