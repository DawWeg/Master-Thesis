function plot_error_detection(figure_num, error, threshold)
  [rows, cols] = size(threshold);
  
  if rows==1
    threshold = ones(size(error)).*threshold;
  endif
  
  figure(figure_num);
  plot(abs(error), 'color', [0.1, 0.6, 0.8]); hold on;
  
  for i=1:cols
    plot(threshold(:,i), 'color', [0.8, 0.3, 0], 'linewidth', 2); 
  endfor
  hold off; grid on;
  xlim([-inf inf]); ylim([0.0 1.2*max(max(threshold))]);
  title("Error detection:"); xlabel("Sample"); ylabel("Value");
endfunction
