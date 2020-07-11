function [noise_variance] =  ewls_batch_noise_variance(input_signal, regression, coefficents, error, t)
  global ewls_lambda ewls_lambda_0 ewls_noise_variance_coupled;
  
  lambda = (ewls_lambda.*ones(1,t)).^(t:-1:1);
  noise_variance = 0;
  for i=2:t
    if(ewls_noise_variance_coupled==1)
      noise_variance += (ewls_lambda^(t-i))*(input_signal(i)-regression(:,i)'*coefficents)^2;
    else
      noise_variance += (ewls_lambda_0^(t-i))*error(i)*error(i);
    endif
  endfor
  noise_variance = noise_variance/sum(lambda);
endfunction
