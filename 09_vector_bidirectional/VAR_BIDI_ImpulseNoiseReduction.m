function [clear_fb, clear_f, clear_b] = VAR_BIDI_ImpulseNoiseReduction(input_signal)
  % ================
  % Forward analysis
  % ================
  [ clear_f, d_f, err_f, var_f ] = VAR_ImpulseNoiseReduction(input_signal);
  save("-binary", get_data_save_filename("VAR_F"), "clear_f", "d_f", "err_f", "var_f");
  save_audio("VAR_F", clear_f', 0);
  clear err_f var_f;
  
  % =================
  % Backward analysis
  % =================
  [ clear_b, d_b, err_b, var_b ] = VAR_ImpulseNoiseReduction(flip(input_signal)) ;
  % Flip backward detection
  clear_b = flip(clear_b')';
  d_b = flip(d_b')';
  err_b = flip(err_b')';
  var_b = flip(var_b')';
  save("-binary", get_data_save_filename("VAR_B"), "clear_b", "d_b", "err_b", "var_b");
  save_audio("VAR_B", clear_b', 0);
  clear err_b var_b;

  % ==========================================
  % Merge and expand alarms from both analysis
  % ==========================================
  d_fb = dual_merge_alarms(d_f, d_b);
  %clear d_f d_b;
  
  % ===================================================
  % Forward analysis with provided new detection signal
  % ===================================================
  [ clear_fbf, d_fbf, err_fbf, var_fbf ] = VAR_ImpulseNoiseReduction(input_signal, d_fb);
  save("-binary", get_data_save_filename("VAR_FBF"), "clear_fbf", "d_fbf", "err_fbf", "var_fbf");
  save_audio("VAR_FBF", clear_fbf', 0);
  clear err_fbf d_fbf;
  
  % ====================================================
  % Backward analysis with provided new detection signal
  % ====================================================  
  [ clear_fbb, d_fbb, err_fbb, var_fbb ] = VAR_ImpulseNoiseReduction(flip(input_signal), flip(d_fb')');
  % Flip backward results
  clear_fbb = flip(clear_fbb')';
  var_fbb = flip(var_fbb')';
  d_fbb = flip(d_fbb')';
  save("-binary", get_data_save_filename("VAR_FBB"), "clear_fbb", "d_fbb", "err_fbb", "var_fbb");
  save_audio("VAR_FBB", clear_fbb', 0);
  clear err_fbb;
  

  % ====================================
  % Forward-Backward merge interpolation
  % ====================================
  % Initialize result signal with original one
  clear_fb = input_signal';

  % Merge interpolations of forward and backward analysis
  [clear_fb(1,:)] = merge_interpolations( clear_fb(1,:), d_fb(1,:),...
                                          clear_fbf(1,:), var_fbf(1,:),...
                                          clear_fbb(1,:), var_fbb(1,:));
                                          
  [clear_fb(2,:)] = merge_interpolations( clear_fb(2,:), d_fb(2,:),...
                                          clear_fbf(2,:), var_fbf(2,:),...
                                          clear_fbb(2,:), var_fbb(2,:));
  save_audio("VAR_FB", clear_fb', 0);
  
  clear_f = clear_f';
  clear_b = clear_b';
  clear_fb = clear_fb';
  
endfunction
