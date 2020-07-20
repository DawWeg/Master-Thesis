run("init.m");
pkg load control;

N = 100000;
variance = 0.4;
model_poles = zeros(model_rank, N);
model_poles(1:model_rank/2,:) = (variance*randn(model_rank/2,N))+j*(variance*randn(model_rank/2,N));
model_poles(model_rank/2+1:end,:) = conj(model_poles(1:model_rank/2,:));
model_coefficients = zeros(model_rank+1, N);

stable = 0;
unstable = 0;
fault_count = 0;
 
for i = 1:N
  print_progress("Check stability test", i, N, 10000);
  model_coefficients(:,i) = real(poly(model_poles(:,i)));
  if(any(abs(roots(model_coefficients(:,i))) >= 1))
    unstable = unstable + 1;
    if(!check_stability(-model_coefficients(2:end,i), model_rank))
      %printf("Model unstable at %d, confirmed by check_stability. [%f]\n", i, max(abs(model_poles(:,i))));
    else
      %printf("\nModel unstable at %d, overlooked by check_stability. [%f]\n", i, max(abs(model_poles(:,i))));
      fault_count = fault_count + 1;
    endif 
  elseif(!check_stability(-model_coefficients(2:end,i), model_rank))
    %printf("\nModel stable at %d, falsely marked by check_stability. [%f]\n", i, max(abs(model_poles(:,i))));
    fault_count = fault_count + 1;
  else
    stable = stable + 1;
    %printf("Model stable at %d. [%f]\n", i, max(abs(model_poles(:,i))));
  endif 
endfor
printf("Fault count: %d\nStable models: %d\nUnstable models: %d", fault_count, stable, unstable);



