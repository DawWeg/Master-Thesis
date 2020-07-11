run("init.m");
pkg load control;

N = 1000;
variance = 0.4;
model_poles = zeros(model_rank, N);
model_poles(1:model_rank/2,:) = (variance*randn(model_rank/2,N))+j*(variance*randn(model_rank/2,N));
model_poles(model_rank/2+1:end,:) = conj(model_poles(1:model_rank/2,:));
model_coefficients = zeros(model_rank+1, N);

unstable_reference_count = 0;
stable_reference_count = 0;

unstable_test_count = 0;
stable_test_count = 0;
 
for i  = 1:N
  model_coefficients(:,i) = real(poly(model_poles(:,i)));
  if(any(abs(roots(model_coefficients(:,i))) >= 1))
    unstable_reference_count = unstable_reference_count + 1;
    if(!check_stability(-model_coefficients(2:end,i), model_rank))
      unstable_test_count = unstable_test_count + 1;
      printf("Model unstable at %d, confirmed by check_stability. [%f]\n", i, max(abs(model_poles(:,i))));
    else
      printf("\nModel unstable at %d, overlooked by check_stability. [%f]\n", i, max(abs(model_poles(:,i))));
    endif 
  elseif(!check_stability(-model_coefficients(2:end,i), model_rank))
    printf("\nModel stable at %d, falsely marked by check_stability. [%f]\n", i, max(abs(model_poles(:,i))));
  else
    stable_test_count = stable_test_count + 1;
    stable_reference_count = stable_reference_count + 1;
    printf("Model stable at %d. [%f]\n", i, max(abs(model_poles(:,i))));
  endif 
endfor
printf("\nUnstable reference count: %d\nUnstable test count: %d\nStable reference count: %d\nStable test count: %d\n", unstable_reference_count, unstable_test_count, stable_reference_count, stable_test_count);



