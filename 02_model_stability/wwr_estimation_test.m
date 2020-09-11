run("init.m");

N = 1000;
noise_l = randn(N,1);
noise_r = randn(N,1); 
y_l = zeros(N,1);
y_r = zeros(N,1);

model_output = [y_l, y_r]';
noise_v = [noise_l, noise_r]';

model_rank = 4;
alfa_11 = [1.23, 0.0]'; 
alfa_12 = [-0.3, 0.4]';
alfa_13 = [0.1, -0.2]';
alfa_14 = [-0.3, 0.4]';

alfa_21 = [0.0, 1.15]'; 
alfa_22 = [0.3, -0.3]';
alfa_23 = [-0.3, 0.1]';
alfa_24 = [0.1, -0.2]';

theta_l = [alfa_11', alfa_12', alfa_13', alfa_14']';
theta_r = [alfa_21', alfa_22', alfa_23', alfa_24']';
theta = [theta_l; theta_r];

%theta = [4.223850835785;   0.284038735959;   -1.036971850054;   -0.390519494800;   -0.476784076334;   -0.218477701166;    0.181325451208;    0.346561290843;   -1.419096365827;    0.331781229037;    2.381136616167;   -0.421502439359;    0.232208187353;   -0.339261416431;   -0.903503297563;    1.328130808858;   -0.855931539222;   -1.525116584129;    0.668776307813;    0.614222243321;   -3.152883872054;    0.806798187490;    4.671944327633;    1.216544148792;    1.252835602018;   -0.409149082132;   -4.692615223895;   -1.652839288239;    6.344380575752;    1.880512449200;   -8.208313647956;    3.030549399673;    3.626222736456;  -11.632082522918;   -0.556307404066;    6.651468380890;    1.566911666577;    5.443934574413;   -0.860994638762;   -4.371409223741];
%model_rank = 10;

Or = zeros(2*model_rank,1);
Ir = eye(2*model_rank, 2*model_rank);
regression = zeros(2*model_rank, 1);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));



for t=5:N
  regression = [model_output(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  model_output(:,t) = phi'*theta + noise_v(:,t);
endfor

coefficients = zeros(size(theta));
covariance_matrix = 100*Ir;
noise_variance = zeros(2,2);
regression = zeros(2*model_rank, N);

theta_trajectory_recu = zeros(model_rank*4,N);
gain_trajectory_recu = zeros(2*model_rank,N);
error_trajectory_recu = zeros(size(model_output));
noise_variance_trajectory_recu = zeros(2,2,N);

for t=2:N
  print_progress("EWLS Comparison", t, N, N/100);
  regression(:,t) = [model_output(:,t-1); regression(1:end-2, t-1)];
  
  [coefficients, covariance_matrix, error, noise_variance] = ewls_vector_recursive(
          model_output(:,t), ...
          regression(:,t), ...
          covariance_matrix, ...
          coefficients, ...
          noise_variance);  
  theta_trajectory_recu(:,t) = coefficients; 
  error_trajectory_recu(:,t) = error;
  noise_variance_trajectory_recu(:,:,t) = noise_variance;
  
  if(!check_stability_var(theta_trajectory_recu(:,t)) && t > 50) 
    printf("Model ustable on: %d.\n", t);
    printf("EWLS model coefficients:\n");
    disp(theta_trajectory_recu(:,t));
    [theta_trajectory_recu(:,t)] = ...
        wwr_estimation3(min([ewls_equivalent_window_length, t]), ...
        model_output(:,t-(min([ewls_equivalent_window_length, t]))+1:t));    
    printf("Reestimated coefficients:\n");
    disp(theta_trajectory_recu(:,t));
  endif
  
  phi = [regression(:,t), zeros(2*model_rank, 1); zeros(2*model_rank, 1), regression(:,t)];
endfor

estimation_output = zeros(size(model_output));
estimation_regression = zeros(2*model_rank, 1);
for t = 2:N
  estimation_regression = [estimation_output(:,t-1); estimation_regression(1:end-2)];
  phi = [ estimation_regression, Or; Or, estimation_regression];
  estimation_output(:,t) = phi'*theta_trajectory_recu(:,t) + error_trajectory_recu(:,t);
endfor


figure(1);
clf;
subplot(2,1,1);
plot(model_output(1,:));
hold on;
plot(estimation_output(1,:));
hold off;
subplot(2,1,2);
plot(model_output(2,:));
hold on;
plot(estimation_output(2,:));