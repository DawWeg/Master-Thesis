function [detection_fb] = dual_merge_alarms(detection_f, detection_b)
  [d_fb_l] = merge_alarms_testx(detection_f(1,:), detection_b(1,:));
  [d_fb_r] = merge_alarms_testx(detection_f(2,:), detection_b(2,:));
  detection_fb = [d_fb_l; d_fb_r];
endfunction
