run("init.m");
N = 5000;
noise_mu = 0; noise_sigma = 1;
noise = noise_sigma*randn(1,N);

%c= poly([0.7; 0.7; 0.6; -0.4+0.4i; -0.4-0.4i; 0.3+0.4i; 0.3-0.4i; 0.0; -0.1; -0.6]);
%ar_model = c(2:end).*(-1);
ar_model = [0.1 -0.2 0.3 -0.4 0.4 -0.3 0.2 -0.1];
ar_model_output = zeros(size(noise));
model_rank = length(ar_model);
for i=1+model_rank:N
  ar_model_output(i) = sum(ar_model_output(i-1:-1:i-model_rank).*ar_model) + noise(i);
endfor


testing_lambdas = [0.990, 0.993, 0.995, 0.997, 0.999, 0.9999, 1];
for l=1:length(testing_lambdas)
  
ewls_lambda_0 = testing_lambdas(l);
ewls_recu_coefs = zeros(model_rank, N);
ewls_recu_cov = ewls_initial_cov_matrix.*eye(model_rank);
ewls_recu_error = zeros(size(ar_model_output));
ewls_recu_noise_variance = zeros(size(ar_model_output));

ewls_iter_coefs = zeros(model_rank, N);
ewls_iter_error = zeros(size(ar_model_output));
ewls_iter_noise_variance = zeros(size(ar_model_output));

    
  ewls_regression = zeros(model_rank, N);
  for i=2:N
    print_progress("EWLS Comparison", i, N, N/100);
    ewls_regression(:,i) = [ar_model_output(i-1); ewls_regression(1:end-1, i-1)];
    [ewls_recu_coefs(:,i), ewls_recu_cov, ewls_recu_error(i), ewls_recu_noise_variance(i)] = ewls_step( ...
            ar_model_output(i), ...
            ewls_regression(:,i), ...
            ewls_recu_cov, ...
            ewls_recu_coefs(:,i-1), ...
            ewls_recu_noise_variance(i-1));
        
      
      ewls_iter_error(i) = ar_model_output(i) - ewls_regression(:,i)' *ewls_iter_coefs(:,i-1);
      [ewls_iter_coefs(:,i)] = ewls_batch(ar_model_output, ewls_regression, i);
      [ewls_iter_noise_variance(i)] =  ewls_batch_noise_variance(...
          ar_model_output, ewls_regression,...
          ewls_iter_coefs, ewls_iter_error, i);

  endfor
  print_progress("EWLS Comparison", N, N, N/100);
  
  filename = sprintf("01_identification/ewls_comparison_results/ewls_lambda0_%.0f.dat", testing_lambdas(l)*10000);
  save("-binary", filename, "ar_model", "ar_model_output",...
      "ewls_recu_coefs", "ewls_recu_error", "ewls_recu_noise_variance", ...
      "ewls_iter_coefs", "ewls_iter_error", "ewls_iter_noise_variance");
endfor

%run("ewls_comparison_plot.m");