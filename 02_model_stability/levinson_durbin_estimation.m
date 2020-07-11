function [coefficients_estimate, r] = levinson_durbin_estimation (N, input_signal)
  global process_rank;
  input_signal = [zeros(process_rank,1); input_signal; zeros(process_rank,1)];
  coefficients_estimate = zeros(process_rank, 1);

  p = zeros(1, process_rank+1);
  r = zeros(1, process_rank+1);
  for k = 1:process_rank+1
    for i = 1:N-k
      p(k) = p(k) + input_signal(end-i)*input_signal(end-i-k+1);
    endfor    
    r(k) = (1/N)*p(k);
  endfor  
  R = build_toeplitz_matrix(r);
  P = r(2:end);
  coefficients_estimate = inv(R)*P';
endfunction
