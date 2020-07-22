function [interpolated_samples] = batch_interpolation (input_signal, coefficients)
%%% Preparign variables
global model_rank;
m = length(input_signal) - 2*model_rank;
psi0 = [input_signal(1:model_rank); input_signal(model_rank+m+1:end)];

%%% Building B matrices
B = zeros(model_rank+m, 2*model_rank+m);
for i = 1:model_rank+m
  B(i,i:i+model_rank) = [flip(coefficients'), -1]; 
endfor
Bm = B(:,model_rank+1:model_rank+m);
B0 = [B(:,1:model_rank), B(:,model_rank+m+1:end)];

interpolated_samples = -inv(Bm'*Bm)*Bm'*B0*psi0; 
endfunction
