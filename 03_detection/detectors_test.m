run("init.m");
pkg load signal;
page_output_immediately(1);

%%% Generating autoregressive process
N = 5100;
process_poles = [0.9; 0.7; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; 0.0; 0.7+0.1i; 0.7-0.1i; -0.9];

global process_rank = length(process_poles(:,1));
process_coefficients = zeros(process_rank+1, N);
process_coefficients = real(poly(process_poles));

process_regression_vector = zeros(process_rank, 1);
process_output = zeros(N, 1);

for t = 2:N
  process_regression_vector = [process_output(t-1); process_regression_vector(1:end-1)];
  process_output(t) = -process_coefficients(2:end)*process_regression_vector + 0.1*randn;
  if(t == 2000)
    x = 5;
    process_output(t) = process_output(t);
  endif
endfor
process_output(5001:5005) = 25;
dbstop("open_loop_test.m");
dbstop("closed_loop_test.m");
run("open_loop_test.m");
run("closed_loop_test.m");

%%% Printing results
figure(1);
zplane([], process_poles);
%for i = 1:model_rank
%  plot(process_poles(i,:));
%  hold on;
%endfor
%hold off;

figure(2);
subplot(4,1,1);
plot(process_output, 'b');
hold on;
plot(process_output, 'b.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);
subplot(4,1,2);
plot(abs(ol_error_trajectory), 'b');
hold on;
plot(abs(ol_error_trajectory), 'b.', 'markersize', 15);
plot(ol_threshold_trajectory, 'r');
plot(ol_threshold_trajectory, 'r.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);
subplot(4,1,3);
stairs(ol1_detection_signal, 'b');
hold on;
plot(ol1_detection_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);
subplot(4,1,4);
stairs(ol_detection_signal, 'b');
hold on;
plot(ol_detection_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);

figure(3);
subplot(4,1,1);
plot(process_output, 'b');
hold on;
plot(process_output, 'b.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);
subplot(4,1,2);
plot(abs(cl_error_trajectory), 'b');
hold on;
plot(abs(cl_error_trajectory), 'b.', 'markersize', 15);
plot(cl_threshold_trajectory, 'r');
plot(cl_threshold_trajectory, 'r.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);
subplot(4,1,3);
stairs(cl1_detection_signal, 'b');
hold on;
plot(cl1_detection_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);
subplot(4,1,4);
stairs(cl_detection_signal, 'b');
hold on;
plot(cl_detection_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlim([4995 5030]);

figure(4);
for i = 1:process_rank
subplot(process_rank/2,2,i);
plot(ewls_coefficients_estimate(i,:));
hold on;
plot(-process_coefficients(i+1)*ones(N,1));
hold off;
endfor
