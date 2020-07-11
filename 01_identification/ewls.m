clear all;
close all;
clc;
addpath("utilities")
N = 500; tic();
noise_mu = 0; noise_sigma = 0.5;
noise = noise_sigma*randn(1,N);
global ewls_lambda = 0.99999;
global ewls_lambda_0 = 0.99998;
global ewls_noise_variance_coupled = 1; % 1=coupled | other=decoupled
global ewls_initial_cov_matrix = 100;

c= poly([0.7; 0.7; 0.6; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; 0.0; -0.1; -0.6]);
ar_model = c(2:end).*(-1);
ar_model_output = zeros(size(noise));
model_rank = length(ar_model);
for i=1+model_rank:N
  ar_model_output(i) = sum(ar_model_output(i-1:-1:i-model_rank).*ar_model) + noise(i);
endfor

plot(ar_model_output);

ewls_recu_coefs = zeros(model_rank, N);
ewls_recu_cov = ewls_initial_cov_matrix.*eye(model_rank);
ewls_recu_error = zeros(size(ar_model_output));
ewls_recu_noise_variance = zeros(size(ar_model_output));
ewls_regression = zeros(model_rank, N);
for i=2:N
  print_progress("EWLS Recu", i, N, N/100);
  ewls_regression(:,i) = [ar_model_output(i-1); ewls_regression(1:end-1, i-1)];
  [ewls_recu_coefs(:,i), ewls_recu_cov, ewls_recu_error(i), ewls_recu_noise_variance(i)] = ewls_step( ...
          ar_model_output(i), ...
          ewls_regression(:,i), ...
          ewls_recu_cov, ...
          ewls_recu_coefs(:,i-1), ...
          ewls_recu_noise_variance(i-1));
endfor
print_progress("EWLS Recu", N, N, N/100);


ewls_iter_coefs = zeros(model_rank, N);
ewls_iter_error = zeros(size(ar_model_output));
ewls_iter_noise_variance = zeros(size(ar_model_output));
ewls_iter_r_inv = (1/ewls_initial_cov_matrix)*eye(model_rank);
ewls_iter_p = zeros(model_rank,1);
  
for t=1+model_rank:N
  print_progress("EWLS Iter", t, N, N/100);
  ewls_iter_error(t) = ar_model_output(t) - ewls_regression(:,t)' *ewls_iter_coefs(:,t-1);
  for i=1:t-1
    ewls_iter_r_inv += (ewls_lambda^(i-1))*ewls_regression(:,t-(i-1))*ewls_regression(:,t-(i-1))';
    ewls_iter_p += (ewls_lambda^(i-1))*ar_model_output(t-(i-1))*ewls_regression(:,t-(i-1));
  endfor
  ewls_iter_coefs(:,t) = ewls_iter_r_inv \ ewls_iter_p;
  
  ewls_iter_noise_variance(t) = 0;
  for i=2:t
    if(ewls_noise_variance_coupled==1)
      ewls_iter_noise_variance(t) += (ewls_lambda^(t-i))*(ar_model_output(i)-ewls_regression(:,i)'*ewls_iter_coefs(:,t))^2;
    else
      ewls_iter_noise_variance(t) += (ewls_lambda_0^(t-i))*ewls_iter_error(t)*ewls_iter_error(t);
    endif
  endfor
 ewls_iter_noise_variance(t) = ewls_iter_noise_variance(t)/(1/(1-ewls_lambda));
 %clear
 ewls_iter_r_inv = zeros(model_rank);
 ewls_iter_p = zeros(model_rank,1);
endfor
print_progress("EWLS Iter", N, N, N/100);
%plot(ar_model_output);

color_model = [0.0, 0.0, 0.0];
color_recu = [0.7 0.3, 0.1];
color_iter = [0.1 0.3, 0.7];

figure(1);
h_model = plot( (ones(model_rank,2).*[0, N])', [ar_model; ar_model], 'color', color_model);
hold on;
h_ewls_recu_coefs = plot(ewls_recu_coefs', 'color', color_recu, ':');
h_ewls_iter_coefs = plot(ewls_iter_coefs', 'color', color_iter, '--');
hold off;

xlim([-inf inf]); ylim([ 1.5*min(ar_model), 1.5*max(ar_model)]); grid on;
title("Model coefficients:");
legend([h_model, h_ewls_recu_coefs, h_ewls_iter_coefs]',  {"Model", "EWLS Recu", "EWLS Iter"});


figure(2);
subplot(2,1,1);
abs_recu = abs(ewls_recu_error);
abs_iter = abs(ewls_iter_error);
h_ewls_recu_coefs = plot(abs_recu, 'color', color_recu, ':');
hold on;
h_ewls_iter_coefs = plot(abs_iter, 'color', color_iter, '--');
hold off;
xlim([-inf inf]); ylim([ 0, noise_sigma*4 ]); grid on;
title("Absolute one step prediction errors:");
legend([h_ewls_recu_coefs, h_ewls_iter_coefs]',  {"EWLS Recu", "EWLS Iter"});

subplot(2,1,2);
h_ewls_recu_coefs = plot(ewls_recu_noise_variance, 'color', color_recu, ':');
hold on;
h_ewls_iter_coefs = plot(ewls_iter_noise_variance, 'color', color_iter, '--');
hold off;
xlim([-inf inf]); ylim([ min(min([ewls_iter_noise_variance; ewls_recu_noise_variance])), max(max([ewls_iter_noise_variance; ewls_recu_noise_variance])) ]); grid on;
title("Noise variance:");
legend([h_ewls_recu_coefs, h_ewls_iter_coefs]',  {"EWLS Recu", "EWLS Iter"});


figure(3);
subplot(3,1,1);
plot(abs(ewls_recu_coefs' - ewls_iter_coefs'), 'color', color_recu); 
xlim([-inf inf]); ylim([0 noise_sigma*2]); grid on;
title("Coefficients trajectory absolute difference");

subplot(3,1,2);
plot(abs(ewls_recu_error - ewls_iter_error), 'color', color_recu); 
xlim([-inf inf]); ylim([0 noise_sigma*2]); grid on;
title("One step prediction error trajectory absolute difference");

subplot(3,1,3);
plot(abs(ewls_recu_noise_variance - ewls_iter_noise_variance), 'color', color_recu); 
xlim([-inf inf]); ylim([0 noise_sigma*2]); grid on;
title("Noise variance absolute difference");
