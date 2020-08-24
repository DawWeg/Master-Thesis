function [coefficients_estimate] = wwr_estimation (N, input_signal, noise_variance)
  global model_rank;
  input_signal = [zeros(2,model_rank), input_signal, zeros(2,model_rank)];
  coefficients_estimate = zeros(model_rank*4, 1);
  R = zeros(2, 2, model_rank+1);
  for k = 1:model_rank+1
    for i = 1:N-k
      R(:,:,k) = R(:,:,k) + input_signal(:,end-i)*input_signal(:,end-i-k+1)';
    endfor    
    R(:,:,k) = (1/N).*R(:,:,k);
  endfor  
  Rm = build_toeplitz_matrix(R);
  coefficients_estimate = [noise_variance, zeros(2,model_rank*2)]*inv(Rm);
  coefficients_estimate = [coefficients_estimate(1,3:end)'; coefficients_estimate(2,3:end)'];
endfunction
