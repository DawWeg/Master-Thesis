% Initializes regression vector based on input signal
% Args:
%   @signal       - Signal to create regression vector from
%   @r            - Model rank
% Returns:
%   @regression   - Regression vector
function [regression] = var_init_regression_vector(signal, r, t0);
  regression = signal(:,t0-r);
  for n=r-1:-1:1
    regression = [signal(:,t0-n); regression];
  endfor
endfunction

