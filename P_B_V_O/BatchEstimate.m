function [batch_estimate] = BatchEstimate (input_signal, lambda)
%%% Preparing variables
global N AR_model_order;
batch_estimate = zeros(2, AR_model_order, N);
input_signal = [zeros(AR_model_order,2); input_signal];

%%% Estimation loop
for j = 1:2
  for t = 1:N
    R = zeros(AR_model_order);
    P = zeros(AR_model_order,1);
    for k = 1:t
      regression_vector = input_signal(k+AR_model_order-1:-1:k,j);
      R = R + power(lambda, t-k)*regression_vector*regression_vector';
      P = P + power(lambda, t-k)*regression_vector*input_signal(k+AR_model_order);
    endfor 
    batch_estimate(j,:,t) = (R\eye(size(R)))*P;   
  endfor  
endfor

endfunction
