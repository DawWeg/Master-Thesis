function [lr_clear_signal] = bidirectional_interpolation(lr_detection_signal, ...
                                                         l_clear_signal, ...                                                
                                                         l_coefficients_trajectory, ...
                                                         l_noise_variance_trajectory, ...
                                                         r_clear_signal, 
                                                         r_coefficients_trajectory, ...
                                                         r_noise_variance_trajectory)

global model_rank;                                                         
N = length(lr_detection_signal);
lr_clear_signal = zeros(N,1);
lrl_clear_signal = zeros(N,1);
lrr_clear_signal = zeros(N,1);

t = 1; 
while(t <= N)
  if(lr_detection_signal(t) == 1 && lr_detection_signal(t-1) == 0)
    block_length = 1;
    while(lr_detection_signal(t+block_length))
      block_length = block_length + 1;
    endwhile  
    m = block_length;
    q = 2*model_rank + m;  
    lrl_clear_signal(t:t+m-1) = recursive_interpolation( ...
                  [l_clear_signal(t-q:t-1); r_clear_signal(t:t+m+model_rank)], ...
                  m, ...
                  q, ...
                  l_coefficients_trajectory(t-1,:), ...
                  l_noise_variance_trajectory(t-1));
    lrr_clear_signal(t:t+m-1) = recursive_interpolation( ...
                  [l_clear_signal(t-q:t-1); r_clear_signal(t:t+m+model_rank)], ...
                  m, ...
                  q, ...
                  r_coefficients_trajectory(t+m+1,:), ...
                  r_noise_variance_trajectory(t+m+1));
    wf = r_noise_variance_trajectory(t+m+1) / (l_noise_variance_trajectory(t-1) + r_noise_variance_trajectory(t+m+1));
    wb = l_noise_variance_trajectory(t-1) / (l_noise_variance_trajectory(t-1) + r_noise_variance_trajectory(t+m+1));
    lr_clear_signal(t:t+m) = wf*lrl_clear_signal(t:t+m) + wb*lrr_clear_signal(t:t+m);
    t = t + m + 1;
  else
    lrl_clear_signal(t) = l_clear_signal(t);
    lrr_clear_signal(t) = r_clear_signal(t);
    lr_clear_signal(t) = (l_clear_signal(t) + r_clear_signal(t)) / 2;
    t = t + 1;
  endif   
endwhile      
endfunction