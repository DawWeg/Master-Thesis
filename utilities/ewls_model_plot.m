function [] = ewls_model_plot(figure_num, ...
  input_signal,...
  ewls_detection,...
  ewls_error_trajectory,...
  ewls_threshold_trajectory, ...
  ewls_noise_variance_trajectory,...
  ewls_theta_trajectory)
  global model_rank;
  %% EWLS MODEL Plotting 
  figure(figure_num);
  subplot(4,2,1);
  plot(input_signal(1,:)); hold on;
  plot(input_signal(1,:).*ewls_detection(1,:)); hold off; grid on; title("Signal L");
  subplot(4,2,2);
  plot(input_signal(2,:)); hold on; 
  plot(input_signal(2,:).*ewls_detection(2,:)); hold off; grid on; title("Signal R");

  subplot(4,2,3);
  plot(abs(ewls_error_trajectory(1,:))); hold on; 
  plot(ewls_threshold_trajectory(1,:)); grid on; hold off;
  title("Error vs Threshold L");
  subplot(4,2,4);
  plot(abs(ewls_error_trajectory(2,:))); hold on; 
  plot(ewls_threshold_trajectory(2,:)); grid on; hold off;
  title("Error vs Threshold R");

  subplot(4,2,5)
  plot(squeeze(ewls_noise_variance_trajectory(1,1,:))); grid on; title("Noise variance L");
  subplot(4,2,6)
  plot(squeeze(ewls_noise_variance_trajectory(2,2,:))); grid on; title("Noise variance R");

  ewls_theta_l = ewls_theta_trajectory(1:2*model_rank, :);
  ewls_theta_r = ewls_theta_trajectory(2*model_rank+1:end, :);
  subplot(4,2,7);
  plot(ewls_theta_l'); grid on; title("Model Coefs L");
  subplot(4,2,8);
  plot(ewls_theta_r'); grid on; title("Model Coefs R");
endfunction
