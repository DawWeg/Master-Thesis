run("init.m");
pkg load signal;
pkg load tsa;
page_output_immediately(1,'local');

%%% Generating autoregressive process
N = 5000;
load("random_noise.mat");
process_poles = [0.989; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; -0.9].*ones(6, N);
%moving_pole = 0.2*sind(0.1*(1:N))+1;
%moving_pole = ones(1, N);
%moving_pole(1, 2000:5000) = 5*moving_pole(1, 2000:5000);
%process_poles(1,:) = process_poles(1,:).*moving_pole;
global process_rank = length(process_poles(:,1));
process_coefficients = zeros(process_rank+1, N);
for i = 1:N
  process_coefficients(:,i) = real(poly(process_poles(:,i)));
endfor
%process_coefficients = process_coefficients(:);
process_regression_vector = zeros(process_rank, 1);
process_output = zeros(N, 1);
for t = 2:N
  process_regression_vector = [process_output(t-1); process_regression_vector(1:end-1)];
  process_output(t) = -process_coefficients(2:end,i)'*process_regression_vector + random_noise(t);
  if(t == 2000)
    x = 5;
    process_output(t) = process_output(t);
  endif
endfor

%%% Estimating process coefficients
ewls_delta = 50;
ewls_lambda = 0.997;
ewls_regression_vector = zeros(process_rank, 1);
ewls_coefficients_estimate = zeros(process_rank, N);
ewls_error = zeros(N, 1);
ewls_covariance_matrix = ewls_delta*eye(process_rank);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));

model_regression_vector = zeros(process_rank, 1);
model_output = zeros(N, 1);
model_error = zeros(N, 1);
for t = 2:N
  ewls_regression_vector = [process_output(t-1); ewls_regression_vector(1:end-1)];
  temp = ewls_regression_vector'*ewls_covariance_matrix;
  ewls_gain_vector = (ewls_covariance_matrix*ewls_regression_vector)/(ewls_lambda + temp*ewls_regression_vector);
  ewls_covariance_matrix = (1/ewls_lambda)*(ewls_covariance_matrix - ewls_gain_vector*temp);
  ewls_error(t) = process_output(t) - ewls_regression_vector'*ewls_coefficients_estimate(:,t-1);
  ewls_coefficients_estimate(:,t) = ewls_coefficients_estimate(:,t-1) + ewls_gain_vector*ewls_error(t);
  if(!check_stability(ewls_coefficients_estimate(:,t), process_rank) && t > process_rank*10)    
    [ewls_coefficients_estimate(:,t), r] = ...
        levinson_durbin_estimation(min([ewls_equivalent_window_length, t]), ...
        process_output(t-(min([ewls_equivalent_window_length, t]))+1:t));
    %[test_coefficients] = levinson(r);    
    acf = acovf(flip(process_output(t-(min([ewls_equivalent_window_length, t]))+1:t))', min([ewls_equivalent_window_length, t]));
    %acf = acovf(flip(process_output(t-(min([ewls_equivalent_window_length, t]))+1:t))', process_rank+1, 'biased');
    [test_coefficients] = levinson(acf, process_rank);
    printf("Model ustable on: %d.\n", t);
    printf("Autocorrelation function estimated using self implemented method:\n%f, %f, %f, %f, %f, %f, %f\n", r(1), r(2), r(3), r(4), r(5), r(6), r(7));
    printf("Autocorrelation function estimated using environment functions:\n%f, %f, %f, %f, %f, %f, %f\n", acf(1), acf(2), acf(3), acf(4), acf(5), acf(6), acf(7));
    printf("Coefficients estimated using self implemented method:\n%f, %f, %f, %f, %f, %f\n", ewls_coefficients_estimate(1,t), ewls_coefficients_estimate(2,t), ewls_coefficients_estimate(3,t), ewls_coefficients_estimate(4,t), ewls_coefficients_estimate(5,t), ewls_coefficients_estimate(6,t));
    printf("Coeffficients estimated using environment functions:\n%f, %f, %f, %f, %f, %f\n\n\n", -test_coefficients(2), -test_coefficients(3), -test_coefficients(4), -test_coefficients(5), -test_coefficients(6), -test_coefficients(7));
    %pause(0.1);
  endif
  model_regression_vector = [model_output(t-1); model_regression_vector(1:end-1)];
  model_output(t) = ewls_coefficients_estimate(:,t)'*model_regression_vector + ewls_error(t);  
  model_error(t) = process_output(t) - model_output(t);
endfor

%%% Printing results
figure(1);
zplane([], [0.7; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; -0.9]);
%for i = 1:model_rank
%  plot(process_poles(i,:));
%  hold on;
%endfor
%hold off;

figure(2);
subplot(3,1,1);
plot(process_output);
%ylim([-15 15]);
subplot(3,1,2);
plot(model_output);
%ylim([-15 15]);
subplot(3,1,3);
plot(model_error);
%ylim([-0.3 0.3]);

figure(3);
for i = 1:process_rank
subplot(process_rank/2,2,i);
plot(ewls_coefficients_estimate(i,:));
hold on;
plot(-process_coefficients(i+1,:));
hold off;
endfor



