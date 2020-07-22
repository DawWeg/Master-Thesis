run("init.m");
pkg load signal;
page_output_immediately(1);

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
  process_output(t) = -process_coefficients(2:end)*process_regression_vector + 0.1*randn;
  if(t == 2000)
    x = 5;
    process_output(t) = process_output(t);
  endif
endfor

corrupted_block_start = 6001;
corrupted_block_end = 6030;

%%% Allocating memory
ewls_regression_vector = zeros(process_rank, 1);
ewls_coefficients_estimate = zeros(process_rank, N);
ewls_covariance_matrix = ewls_initial_cov_matrix*eye(process_rank);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));
ewls_noise_variance = zeros(N, 1);
detection_delay = 10*process_rank;

batch_clear_signal = process_output;
recursive_clear_signal = process_output;
variable_clear_signal = process_output;

t = 2;
while(t <= N);
  %%% Estimation 
  ewls_regression_vector = [batch_clear_signal(t-1); ewls_regression_vector(1:end-1)];
  [ewls_coefficients_estimate(:,t), ewls_covariance_matrix, ewls_error, ewls_noise_variance(t)] = ewls_recursive( ...
          batch_clear_signal(t), ...
          ewls_regression_vector, ...
          ewls_covariance_matrix, ...
          ewls_coefficients_estimate(:,t-1), ...
          ewls_noise_variance(t-1)); 

  %%% Interpolation
  if(t == corrupted_block_start)
    batch_clear_signal(corrupted_block_start:corrupted_block_end) = batch_interpolation( ...
      batch_clear_signal(corrupted_block_start-process_rank:corrupted_block_end+process_rank), ...
      ewls_coefficients_estimate(:,corrupted_block_start-1));
      
    m = corrupted_block_end-corrupted_block_start+1;
    q = 2*process_rank+m;
    recursive_clear_signal(corrupted_block_start:corrupted_block_end) = recursive_interpolation( ...
      recursive_clear_signal(corrupted_block_start-q:corrupted_block_end+process_rank), ...
      ewls_coefficients_estimate(:,corrupted_block_start-1), ...
      ewls_noise_variance(corrupted_block_start-1), m, q);

    variable_clear_signal(corrupted_block_start:corrupted_block_end) = variable_interpolation( ...
      variable_clear_signal(corrupted_block_start-process_rank:corrupted_block_end+process_rank), ...
      ewls_coefficients_estimate(:,corrupted_block_start-1), ...
      ewls_noise_variance(corrupted_block_start-1), m);      
    for i = corrupted_block_start:corrupted_block_end                                                                  
      ewls_coefficients_estimate(:,i) = ewls_coefficients_estimate(:,corrupted_block_start-1);  
    endfor
    t = corrupted_block_end;    
  endif          
  t = t + 1;  
endwhile

%%% Printing results
figure(1);
for i = 1:process_rank
subplot(process_rank/2,2,i);
plot(ewls_coefficients_estimate(i,:));
hold on;
plot(-process_coefficients(i+1)*ones(N,1));
hold off;
endfor

figure(2);
subplot(3,1,1);
plot(process_output);
legend('AR process output');
xlim([corrupted_block_start-model_rank corrupted_block_end+model_rank]);
grid on;
subplot(3,1,2);
hold on;
plot(batch_clear_signal, 'b');
plot(recursive_clear_signal, 'r');
plot(variable_clear_signal, 'g');
legend('batch interpolation', 'recursive interpolation', 'variable rank recursive interpolation');
plot(batch_clear_signal, 'b.', 'markersize', 15);
plot(recursive_clear_signal, 'r.', 'markersize', 15);
plot(variable_clear_signal, 'g.', 'markersize', 15);
xlim([corrupted_block_start-model_rank corrupted_block_end+model_rank]);
grid on;
hold off;
subplot(3,1,3);
hold on;
plot(abs(process_output-batch_clear_signal), 'b');
plot(abs(process_output-recursive_clear_signal), 'r');
plot(abs(process_output-variable_clear_signal), 'g');
legend('batch interpolation error', 'recursive interpolation error', 'variable rank recursive interpolation error');
plot(abs(process_output-batch_clear_signal), 'b.', 'markersize', 15);
plot(abs(process_output-recursive_clear_signal), 'r.', 'markersize', 15);
plot(abs(process_output-variable_clear_signal), 'g.', 'markersize', 15);
xlim([corrupted_block_start-model_rank corrupted_block_end+model_rank]);
grid on;
hold off;

