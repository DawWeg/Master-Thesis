run("init.m");
pkg load signal;
page_output_immediately(1);
load('random_noise.mat');
%%% Generating autoregressive process
N = 10000;
process_poles = [0.9; 0.7; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; 0.0; 0.7+0.1i; 0.7-0.1i; -0.9];

process_rank = length(process_poles(:,1));
process_coefficients = zeros(process_rank+1, N);
process_coefficients = real(poly(process_poles));

process_regression_vector = zeros(process_rank, 1);
process_output = zeros(N, 1);

for t = 2:N
  process_regression_vector = [process_output(t-1); process_regression_vector(1:end-1)];
  process_output(t) = -process_coefficients(2:end)*process_regression_vector + 0.1*random_noise(t);
  if(t == 2000)
    x = 5;
    process_output(t) = process_output(t);
  endif
endfor
%%% Test 1
%{
corrupted_block_start1 = 6001;
corrupted_block_end1 = 6002;
process_output(corrupted_block_start1:corrupted_block_end1) = 10;

corrupted_block_start2 = 6002;
corrupted_block_end2 = 6005;
process_output(corrupted_block_start2:corrupted_block_end2) = 10;
%}

%%% Test 2

corrupted_block_start1 = 6001;
corrupted_block_end1 = 6009;
process_output(corrupted_block_start1:corrupted_block_end1) = 25;

corrupted_block_start2 = 6011;
corrupted_block_end2 = 6012;
process_output(corrupted_block_start2:corrupted_block_end2) = 25;
%}

%%% Test 3
%{
corrupted_block_start1 = 6001;
corrupted_block_end1 = 6005;
process_output(corrupted_block_start1:corrupted_block_end1) = 25;

corrupted_block_start2 = 6008;
corrupted_block_end2 = 6010;
process_output(corrupted_block_start2:corrupted_block_end2) = 25;
%}

%%% Test 4
%{
corrupted_block_start1 = 6001;
corrupted_block_end1 = 6020;
process_output(corrupted_block_start1:2:corrupted_block_end1) = 25;

corrupted_block_start2 = 6001;
corrupted_block_end2 = 6020;
%}

cl_clear_signal = process_output;
ol_clear_signal = process_output;

%dbstop("open_loop_test.m");
%dbstop("closed_loop_test.m");
run("open_loop_test.m");
run("closed_loop_test.m");

figure(1);
clf;
subplot(4,1,1);
title('Wygenerowany proces AR');
hold on;
plot(process_output, 'k');
plot(ol_clear_signal, 'b');
legend('wyjscie procesu', 'interpolacja');
plot(process_output, 'k.', 'markersize', 15);
plot(ol_clear_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('y(t), \sim{y(t)}');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(4,1,2);
title('Bledy i progi detekcyjne');
hold on;
plot(abs(ol_error_trajectory), 'b');
plot(ol_threshold_trajectory, 'g');
plot(abs(cl_error_trajectory), 'r');
plot(cl_threshold_trajectory, 'm');
legend('blad OL', 'pr�g detekcyjny OL', 'blad CL', 'pr�g detekcyjny CL');
plot(abs(ol_error_trajectory), 'b.', 'markersize', 15);
plot(ol_threshold_trajectory, 'g.', 'markersize', 15);
plot(abs(cl_error_trajectory), 'r.', 'markersize', 15);
plot(cl_threshold_trajectory, 'm.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('e(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(4,1,3);
title('Pierwotne decyzje detektor�w');
hold on;
stairs(ol1_detection_signal, 'b');
stairs(cl1_detection_signal, 'r');
legend('detektor OL', 'detektor CL');
plot(ol1_detection_signal, 'b.', 'markersize', 15);
plot(cl1_detection_signal, 'r.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('d_0(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(4,1,4);
title('Koncowe sygnaly detekcyjne');
hold on;
stairs(ol_detection_signal, 'b');
stairs(cl_detection_signal, 'r');
legend('sygnal detekcyjny OL', 'sygnal detekcyjny CL');
plot(ol_detection_signal, 'b.', 'markersize', 15);
plot(cl_detection_signal, 'r.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('d(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
 
figure(2);
clf;
subplot(3,1,1);
title('Final detection signals');
hold on;
stairs(ol_detection_signal, 'b');
stairs(cl_detection_signal, 'r');
legend('ol detection', 'cl detection');
plot(ol_detection_signal, 'b.', 'markersize', 15);
plot(cl_detection_signal, 'r.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('d(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(3,1,2);
title('Differences in error thresholds');
hold on;
plot(abs(cl_threshold_trajectory-ol_threshold_trajectory), 'k');
legend('|cl threshold - ol threshold|');
plot(abs(cl_threshold_trajectory-ol_threshold_trajectory), 'k.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(3,1,3);
title('Differences in errors');
hold on;
plot(abs(cl_error_trajectory-ol_error_trajectory), 'k');
legend('|cl error - ol error|');
plot(abs(cl_error_trajectory-ol_error_trajectory), 'k.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
 
figure(3);
clf;
subplot(4,1,1);
title('Wygenerowany proces AR');
hold on;
plot(process_output, 'k');
plot(cl_clear_signal, 'b');
legend('wyjscie procesu', 'interpolowany sygnal');
plot(process_output, 'k.', 'markersize', 15);
plot(cl_clear_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('y(t), \sim{y(t)}');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(4,1,2);
title('Bledy predykcji i progi detekcyjne');
hold on;
plot(abs(cl_error_trajectory), 'b');
plot(cl_threshold_trajectory, 'g');
legend('blad predykcji', 'pr�g detekcyjny');
plot(abs(cl_error_trajectory), 'b.', 'markersize', 15);
plot(cl_threshold_trajectory, 'g.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('e(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(4,1,3);
title('Pierwotne decyzje detektora');
hold on;
stairs(cl1_detection_signal, 'b');
legend('detekcja w petli zamknietej');
plot(cl1_detection_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('d_0(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);
subplot(4,1,4);
title('Koncowy sygnal detekcyjny');
hold on;
stairs(cl_detection_signal, 'b');
legend('sygnal detekcyjny');
plot(cl_detection_signal, 'b.', 'markersize', 15);
hold off;
grid on;
xlabel('t');
ylabel('d(t)');
xlim([corrupted_block_start1-model_rank corrupted_block_end2+2*model_rank]);

