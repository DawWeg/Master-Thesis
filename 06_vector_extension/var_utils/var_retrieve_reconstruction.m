% Retrieves reconstructed signal from VAR model Kalman state vector
% Args:
%   @state_vector           - Kalman state vector containing interpolation
% Returns:
%   @signal_reconstruction  - Reconstructed signal retrieved from state vector
function [signal_reconstruction] = var_retrieve_reconstruction(state_vector)
      reconstruction_l = state_vector(1:2:end)';
      reconstruction_r = state_vector(2:2:end)';  
      signal_reconstruction = [flip(reconstruction_l); flip(reconstruction_r)];   
endfunction