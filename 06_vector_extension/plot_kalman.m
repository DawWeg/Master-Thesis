%range = 19795:19805;
%range = 19771:19804;
%range = 1:N;
range = 19770:19810;
%range = 10500:10650;
%range = t0-model_rank+1:tk-17;

%{
figure(1);
subplot(2,1,1); plot(cl_error_trajectory(1,range)); grid on; hold on;
plot(cl_threshold_trajectory(1,range)); hold off;
subplot(2,1,2); plot(cl_error_trajectory(2,range)); grid on; hold on;
plot(cl_threshold_trajectory(2,range)); hold off;
%}
%{
figure(2);
subplot(2,2,1); plot(squeeze(cl_noise_variance_trajectory(1,1,range))); grid on;
subplot(2,2,2); plot(squeeze(cl_noise_variance_trajectory(1,2,range))); grid on;
subplot(2,2,3); plot(squeeze(cl_noise_variance_trajectory(2,1,range))); grid on;
subplot(2,2,4); plot(squeeze(cl_noise_variance_trajectory(2,2,range))); grid on;
%}

%range = 19780:19800;
%range = 1:N;

%figure(2);

%subplot(4,1,2); plot(squeeze(cl_noise_variance_trajectory(2,2,range))); grid on;
%subplot(4,1,4); plot(cl_final_detection(2,range)); grid on; ylim([0 1.2]);
%range = 10560:10610;
%range = 10605:10625;
%figure(3);
%subplot(4,1,1); plot(squeeze(cl_noise_variance_trajectory(1,1,range))); grid on;
%subplot(4,1,3); plot(cl_final_detection(1,range)); grid on; ylim([0 1.2]);
%subplot(4,1,2); plot(squeeze(cl_noise_variance_trajectory(2,2,range))); grid on;
%subplot(4,1,4); plot(cl_final_detection(2,range)); grid on; ylim([0 1.2]);
%}
%{
figure(3);
subplot(2,2,1); plot(squeeze(ewls_noise_variance_trajectory(1,1,range))); grid on;
subplot(2,2,2); plot(squeeze(ewls_noise_variance_trajectory(1,2,range))); grid on;
subplot(2,2,3); plot(squeeze(ewls_noise_variance_trajectory(2,1,range))); grid on;
subplot(2,2,4); plot(squeeze(ewls_noise_variance_trajectory(2,2,range))); grid on;
%}

%{
xlimits = [min(range) max(range)];
ewls_model_plot(2, ...
  input_signal,...
  ewls_detection,
  ewls_error_trajectory,...
  ewls_threshold_trajectory, ...
  ewls_noise_variance_trajectory,...
  ewls_theta_trajectory, xlimits)
  %}
  
figure(4);
subplot(4,1,1); plot(input_signal(1,range)); hold on; plot(clear_signal(1,range)); grid on;
subplot(4,1,2); plot(squeeze(cl_error_covariance_trajectory(1,1,range))); grid on;
subplot(4,1,3); plot(cl_error_trajectory(1,range)); grid on; hold on;
plot(cl_threshold_trajectory(1,range)); hold off;
subplot(4,1,4); plot(cl_final_detection(1,range)); grid on; ylim([0 1.2]);

figure(5);
subplot(4,1,1); plot(input_signal(2,range)); hold on; plot(clear_signal(2,range)); grid on;
subplot(4,1,2); plot(squeeze(cl_error_covariance_trajectory(2,2,range))); grid on;
subplot(4,1,3); plot(cl_error_trajectory(2,range)); grid on; hold on;
plot(cl_threshold_trajectory(2,range)); hold off;
subplot(4,1,4); plot(cl_final_detection(2,range)); grid on; ylim([0 1.2]);

%s = retrieve_reconstruction(state_vector);
%plot(s(1,1:end-17)); 
%hold off;
%subplot(4,1,2); plot(cl_final_detection(1,range)); ylim([0 1.2]);
%subplot(4,1,3); plot(input_signal(2,range)); hold on; plot(clear_signal(2,range));
%plot(s(2,1:end-17)); 
%hold off;

%ubplot(4,1,4); plot(cl_final_detection(2,range)); ylim([0 1.2]);

%{
figure(5);
subplot(2,1,1); plot(squeeze(kalman_gain_trajectory(:,1,t0-model_rank+1:tk-17))')
subplot(2,1,2); plot(squeeze(kalman_gain_trajectory(:,2,t0-model_rank+1:tk-17))')
%}