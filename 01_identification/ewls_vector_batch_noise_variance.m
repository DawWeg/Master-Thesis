function [noise_variance] =  ewls_vector_batch_noise_variance(input_signal, regression, coefficents, error, t)
  global ewls_lambda ewls_lambda_0 ewls_noise_variance_coupled model_rank;
  
  lambda = ones(1,t);
  
  if(ewls_noise_variance_coupled==1)
    lambda = (ewls_lambda.*lambda).^(t:-1:1);
  else
    lambda = (ewls_lambda_0.*lambda).^(t:-1:1);
  endif
  
  noise_variance = 0;
  for i=1:t
    if(ewls_noise_variance_coupled==1)
      phi = [regression(:,i), zeros(2*model_rank, 1); zeros(2*model_rank, 1), regression(:,i)];
      noise_variance += (ewls_lambda^(t-i))*(input_signal(:,i)-phi'*coefficents(:,t))*(input_signal(:,i)-phi'*coefficents(:,t))';
    else
      noise_variance += (ewls_lambda_0^(t-i))*error(:,i)*error(:,i)';
    endif
  endfor

  
  noise_variance = noise_variance./sum(lambda);
endfunction
