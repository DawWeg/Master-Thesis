run("init.m");
pkg load signal;
pkg load tsa;
page_output_immediately(1,'local');

%%% Generating autoregressive process
N = 5000;
%load("random_noise.mat");
process_poles = [0.99; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; -0.9].*ones(6, N);
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
  process_output(t) = -process_coefficients(2:end,i)'*process_regression_vector + randn;
  if(t == 2000)
    x = 5;
    process_output(t) = process_output(t);
  endif
endfor

%%% Estimating process coefficients
ewls_delta = 50;
ewls_lambda = 0.99;
ewls_regression_vector = zeros(process_rank, 1);
ewls_coefficients_estimate = zeros(process_rank, N);
ewls_error = zeros(N, 1);
ewls_covariance_matrix = ewls_delta*eye(process_rank);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));

model_regression_vector = zeros(process_rank, 1);
model_output = zeros(N, 1);
model_error = zeros(N, 1);
t = 2;

test_count = 1;
test_coeffs = zeros(process_rank, 1000);
test_acf = zeros(process_rank+1, 1000);

reference_coeffs = zeros(process_rank+1, 1000);
reference_acf = zeros(process_rank+1, 1000);
while(t <= N);
  if(test_count > 1000)
    break;
  endif 
  ewls_regression_vector = [process_output(t-1); ewls_regression_vector(1:end-1)];
  temp = ewls_regression_vector'*ewls_covariance_matrix;
  ewls_gain_vector = (ewls_covariance_matrix*ewls_regression_vector)/(ewls_lambda + temp*ewls_regression_vector);
  ewls_covariance_matrix = (1/ewls_lambda)*(ewls_covariance_matrix - ewls_gain_vector*temp);
  ewls_error(t) = process_output(t) - ewls_regression_vector'*ewls_coefficients_estimate(:,t-1);
  ewls_coefficients_estimate(:,t) = ewls_coefficients_estimate(:,t-1) + ewls_gain_vector*ewls_error(t);
  if(!check_stability(ewls_coefficients_estimate(:,t), process_rank) && t > process_rank*10) 
    printf("Model ustable on: %d.\n", t);
    printf("EWLS model coefficients:\n%f, %f, %f, %f, %f, %f\n", ewls_coefficients_estimate(1,t), ewls_coefficients_estimate(2,t), ewls_coefficients_estimate(3,t), ewls_coefficients_estimate(4,t), ewls_coefficients_estimate(5,t), ewls_coefficients_estimate(6,t));
    [ewls_coefficients_estimate(:,t), r] = ...
        levinson_durbin_estimation(min([ewls_equivalent_window_length, t]), ...
        process_output(t-(min([ewls_equivalent_window_length, t]))+1:t));
    test_acf(:,test_count) = r;
    test_coeffs(:,test_count) = ewls_coefficients_estimate(:,t);
    reference_acf(:,test_count) = acovf(flip(process_output(t-(min([ewls_equivalent_window_length, t]))+1:t))', process_rank);
    [reference_coeffs(:,test_count)] = levinson(reference_acf(:,test_count), process_rank);
    printf("Autocorrelation function estimated using self implemented method:\n%f, %f, %f, %f, %f, %f, %f\n", test_acf(1,test_count), test_acf(2,test_count), test_acf(3,test_count), test_acf(4,test_count), test_acf(5,test_count), test_acf(6,test_count), test_acf(7,test_count));
    printf("Autocorrelation function estimated using environment functions:\n%f, %f, %f, %f, %f, %f, %f\n", reference_acf(1,test_count), reference_acf(2,test_count), reference_acf(3,test_count), reference_acf(4,test_count), reference_acf(5,test_count), reference_acf(6,test_count), reference_acf(7,test_count));
    printf("Coefficients estimated using self implemented method:\n%f, %f, %f, %f, %f, %f\n", test_coeffs(1,test_count), test_coeffs(2,test_count), test_coeffs(3,test_count), test_coeffs(4,test_count), test_coeffs(5,test_count), test_coeffs(6,test_count));
    printf("Coeffficients estimated using environment functions:\n%f, %f, %f, %f, %f, %f\n\n\n", -reference_coeffs(2,test_count), -reference_coeffs(3,test_count), -reference_coeffs(4,test_count), -reference_coeffs(5,test_count), -reference_coeffs(6,test_count), -reference_coeffs(7,test_count));
    test_count = test_count + 1; 
  endif
  model_regression_vector = [model_output(t-1); model_regression_vector(1:end-1)];
  model_output(t) = ewls_coefficients_estimate(:,t)'*model_regression_vector + ewls_error(t);  
  model_error(t) = process_output(t) - model_output(t);
  t = t + 1;
endwhile

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



