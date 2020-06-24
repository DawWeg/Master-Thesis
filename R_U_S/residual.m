clear all;
close all;
clc;
output_precision(9);
max_recursion_depth(10);

%%% Reading input samples
filenames = ["../input_samples/Chopin_Etiuda_Op_25_nr_8.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_9.WAV"; "../input_samples/Chopin_Etiuda_Op_25_nr_10.WAV"; "../input_samples/12.wav"]; 
[input_signal, sampling_frequency] = audioread(filenames(1,:));
input_signal = input_signal(:,1);
N=ceil(length(input_signal)/10);

% Parameters
initial_cov_matrix_value = 100;
model_rank=10;
mu=6;
lambda=0.9999;
block_size=512;
block_shift = 256;
residual_print_per_blocks = 10;
ewls_print_per_loop = 2000;

residual_errors = zeros(N,1);
threshold_1 = zeros(N,1);
threshold_2 = zeros(N,1);
detection = zeros(N,1);

input_signal = input_signal(input_start:input_start+N-1);
output_signal = input_signal;

printf("Starting residual...\n");
previous_block = zeros(block_size, 1);
block_total_count = length(1:block_shift:N);
block_counter = 0;

for i=1:block_shift:N
  tic();
  block_start = i;
  block_end = i+block_size;
  % If next block would exceed signal length then clip it 
  if block_end >= N
      block_end = N;
  endif 
  
  current_block = input_signal(block_start:block_end);
  
  [block_residual_errors] = residual_block(current_block, previous_block, model_rank, lambda);
     
  % Calculate block statistics
  block_residual_abs = abs(block_residual_errors);
  block_detection = zeros(size(block_residual_abs));
  block_local_var = 1.4*median(block_residual_errors.^2 );
  block_local_dev = sqrt(block_local_var);
  block_threshold_1 =  mu*block_local_dev;
  block_threshold_2 =  block_threshold_1/2;
  block_actual_length = length(current_block);
  
  for t = 1:block_actual_length
    if block_residual_abs(t) > block_threshold_1
      % Find alarm beginning 
      alarm_start = t;
      while (block_residual_abs(alarm_start) > block_threshold_2 && alarm_start > 1)
        alarm_start--;
      endwhile
      % Find alarm end
      alarm_end = t;
      while (block_residual_abs(alarm_end) > block_threshold_2 && alarm_end < block_actual_length)
        alarm_end++;
      endwhile
      block_detection(alarm_start:alarm_end) = 1;
    endif
  endfor
  
  residual_errors(block_start:block_end) = block_residual_errors;
  detection(block_start:block_end) = detection(block_start:block_end) + block_detection;
  threshold_1(block_start:block_end) = block_threshold_1;
  threshold_2(block_start:block_end) = block_threshold_2;
  previous_block = current_block;
  block_counter++;
  
  if mod(block_counter, residual_print_per_blocks)==0
    printf("Residual in progres %f Avg loop time %f ms\n", (block_counter/block_total_count)*100, (toc()/residual_print_per_blocks)*1000);
  endif
endfor

printf("Residual done\n", i/N);


detection = detection > 0;


covariance_estimation_errors = initial_cov_matrix_value*eye(model_rank);
coefficients = zeros(model_rank,1);
regression = zeros(model_rank, 1);
noise_variance = 0;
error = 0;
  
printf("Starting EWLS...\n");
tic();
for t = 2:N
    if (detection(t)>0) && (detection(t-1)==0) 
      
      alarm_start = t;
      alarm_end = t;
     
      while detection(alarm_end)==1
        alarm_end++;
      endwhile
      
      m = alarm_end-alarm_start;
      q = model_rank*2+m;
      if(alarm_start-q > 0)
        output_signal(alarm_start:alarm_end-1) = RecursiveInterpolation ( ...
            output_signal(alarm_start-q : alarm_end + model_rank), ...
            m, ...
            q, ...
            coefficients, ...
            noise_variance);
      endif

    endif
    
    regression = [ 0 ; regression(1:model_rank-1)];
    regression(1) = output_signal(t-1);

    error = output_signal(t) - regression' * coefficients;
    gain_vector = (covariance_estimation_errors*regression)/(lambda+regression'*covariance_estimation_errors*regression);
    covariance_estimation_errors = (1/lambda)*(eye(model_rank)-gain_vector*regression')*covariance_estimation_errors;
    coefficients = coefficients + covariance_estimation_errors*regression*error;
    noise_variance = lambda*noise_variance + (1-lambda)*error*error*(1 - gain_vector' *regression);
    
  if mod(t, ewls_print_per_loop)==0
    time = toc();
    printf("EWLS in progress %f Avg loop time: %f ms\n", (t/N)*100, (time/ewls_print_per_loop)*1000);
    tic();
  endif

endfor

printf("Done EWLS...\n");




figure(1);
subplot(3,1,1);
plot(input_signal);
subplot(3,1,2);
plot(detection);
subplot(3,1,3);
plot(output_signal);


figure(2);
plot(abs(residual_errors), 'b',"linewidth", 0.1, threshold_1,'r',"linewidth", 2, threshold_2,'r',"linewidth", 2);
xlim([-inf inf])
ylim([0.0 1.2*max(max(threshold_1), max(threshold_2))]);
