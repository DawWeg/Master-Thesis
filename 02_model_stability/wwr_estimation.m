function [coefficients_estimate] = wwr_estimation (N, input_signal)
  global model_rank;  
  coefficients_estimate = zeros(model_rank*4, 1);
  R = zeros(2, 2, model_rank+1);
  for k = 1:model_rank+1
    for i = 1:N-k
      R(:,:,k) = R(:,:,k) + input_signal(:,end-i)*input_signal(:,end-i-k+1)';
    endfor    
    R(:,:,k) = (1/N).*R(:,:,k);
  endfor 
  %%% Preparing variables 
  A = [-R(:,:,2)*inv(R(:,:,1))];
  B = [-R(:,:,2)'*inv(R(:,:,1))];
  Q = [
endfunction
