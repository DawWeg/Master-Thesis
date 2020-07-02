function [output] = ar_output_coef_traj(noise, coefs)
  rank = length(coefs(:,1));
  output = zeros(size(noise));
  
  for t=1:length(noise)
  acc = 0;
   for i=1:rank
    if t > rank
       acc = acc + coefs(i,t)*output(t-i);
    endif
  endfor
  
  output(t) = acc + noise(t);
  endfor
endfunction