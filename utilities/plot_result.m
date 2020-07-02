function plot_result(figure_num, input_signal, detection, output_signal)
  
  corrupted_input_samples = input_signal.*detection;
  interpolated_output_samples = output_signal.*detection;

  figure(figure_num);
  subplot(2,1,1);
  plot(input_signal, 'color', [0.1, 0.6, 0.8]); hold on;
  plot(corrupted_input_samples, 'color', [0.8, 0.3, 0]); hold off; grid on;
  input_max = max(abs(input_signal))*1.1;
  xlim([-inf inf]); ylim( [-input_max, input_max]);
  title("Input signal:"); xlabel("Sample"); ylabel("Value");

  subplot(2,1,2);
  plot(output_signal, 'color', [0.1, 0.6, 0.8]); hold on;
  plot(interpolated_output_samples, 'color', [0.8, 0.3, 0]); hold off; grid on;
  xlim([-inf inf]); ylim( [-input_max, input_max]);
  title("Output signal:");  xlabel("Sample"); ylabel("Value");
endfunction
