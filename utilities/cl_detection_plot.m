function [] = cl_detection_plot(figure_num, ...
  ewls_detection, ...
  cl_primary_detection, ...
  cl_final_detection, ...
  xlimits)
  
  figure(figure_num);
  subplot(3,2,1);
  plot(ewls_detection(1,:)); grid on; ylim([0 1.5]); title("EWLS Detection L"); xlim(xlimits);
  subplot(3,2,2);
  plot(ewls_detection(2,:)); grid on; ylim([0 1.5]); title("EWLS Detection R"); xlim(xlimits);
  subplot(3,2,3);
  plot(cl_primary_detection(1,:)); grid on; ylim([0 1.5]); title("CL Primary Detection L"); xlim(xlimits);
  subplot(3,2,4);
  plot(cl_primary_detection(2,:)); grid on; ylim([0 1.5]); title("CL Primary Detection R"); xlim(xlimits);
  subplot(3,2,5);
  plot(cl_final_detection(1,:)); grid on; ylim([0 1.5]); title("CL Final Detection L"); xlim(xlimits);
  subplot(3,2,6);
  plot(cl_final_detection(2,:)); grid on; ylim([0 1.5]); title("CL Final Detection R"); xlim(xlimits);
endfunction