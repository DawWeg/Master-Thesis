%%% Generating auto-regressive process signal
N = 1000;
process_poles = [0.9; ...
                 0.7; ...
                 -0.4+0.4i; ...
                 -0.4-0.4i; ...
                 0.3+0.4i; ...
                 0.3-0.4i; ...
                 0.0; ...
                 0.7+0.1i; ...
                 0.7-0.1i; ...
                 -0.9];
process_rank = length(process_poles);
process_coefficients = real(poly(process_poles));
process_regression_vector = zeros(process_rank, 2);
process_output = zeros(N, 2);
for t = 2:N
  process_regression_vector(:,1) = [process_output(t-1,1); process_regression_vector(1:end-1,1)];
  process_output(t,1) = -process_coefficients(2:end)*process_regression_vector(:,1) + 0.1*randn;
  process_regression_vector(:,2) = [process_output(t-1,2); process_regression_vector(1:end-1,2)];
  process_output(t,2) = -process_coefficients(2:end)*process_regression_vector(:,2) + 0.1*randn;
endfor
process_output(:,2) = process_output(:,1);

%%% Adding impulse noise
impulse_noise_value = 3*mean(
m=randi(2,8)-1;
m(~m)=-1;

figure(1);
subplot(2,1,1);
plot(process_output(:,1));
subplot(2,1,2);
plot(process_output(:,2));