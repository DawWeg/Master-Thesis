%run("init.m");

N = 5000;
noise_l = randn(N,1);
noise_r = randn(N,1); 
y_l = zeros(N,1);
y_r = zeros(N,1);

model_output = [y_l, y_r]';
noise_v = [noise_l, noise_r]';

model_rank = 10;

theta_l = mround(ewls_theta_previous(1:2*model_rank));
theta_r = mround(ewls_theta_previous(2*model_rank+1:end));
theta = ewls_theta_previous;

%theta = [4.223850835785;   0.284038735959;   -1.036971850054;   -0.390519494800;   -0.476784076334;   -0.218477701166;    0.181325451208;    0.346561290843;   -1.419096365827;    0.331781229037;    2.381136616167;   -0.421502439359;    0.232208187353;   -0.339261416431;   -0.903503297563;    1.328130808858;   -0.855931539222;   -1.525116584129;    0.668776307813;    0.614222243321;   -3.152883872054;    0.806798187490;    4.671944327633;    1.216544148792;    1.252835602018;   -0.409149082132;   -4.692615223895;   -1.652839288239;    6.344380575752;    1.880512449200;   -8.208313647956;    3.030549399673;    3.626222736456;  -11.632082522918;   -0.556307404066;    6.651468380890;    1.566911666577;    5.443934574413;   -0.860994638762;   -4.371409223741];
%model_rank = 10;

Or = zeros(2*model_rank,1);
Ir = eye(2*model_rank, 2*model_rank);
regression = zeros(2*model_rank, 1);
ewls_equivalent_window_length = round((1+ewls_lambda)/(1-ewls_lambda));

[cl_theta_l, cl_theta_r, qqx] = wwr_estimation3(...
      min([ewls_equivalent_window_length, t0]),...
      clear_signal(:,t0-(min([ewls_equivalent_window_length, t0-1])):t0));

 for i=1:length(theta_l)
    theta_trajectory_recu( 2*(i-1)+1,t-1) = cl_theta_l(i);
    theta_trajectory_recu( 2*(i-1)+2,t-1) = cl_theta_r(i);
  endfor
      
for t=5:N
  regression = [model_output(:,t-1); regression(1:end-2)];
  phi = [ regression, Or; Or, regression];
  model_output(:,t) = phi'*theta + ewls_error_trajectory(:,N);
endfor

coefficients = zeros(size(theta));
covariance_matrix = 100*Ir;
noise_variance = zeros(2,2);
regression = zeros(2*model_rank, N);

theta_trajectory_recu = zeros(model_rank*4,N);
gain_trajectory_recu = zeros(2*model_rank,N);
error_trajectory_recu = zeros(size(model_output));
noise_variance_trajectory_recu = zeros(2,2,N);


estimation_output = zeros(size(model_output));
estimation_regression = zeros(2*model_rank, 1);
for t = 2:N
  estimation_regression = [estimation_output(:,t-1); estimation_regression(1:end-2)];
  phi = [ estimation_regression, Or; Or, estimation_regression];
  estimation_output(:,t) = phi'*theta_trajectory_recu(:,t) + ewls_error_trajectory(:,N);
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