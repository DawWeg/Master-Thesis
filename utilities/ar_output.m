function [output] = ar_output(noise, coefs)
  rank = length(coefs);
  output = zeros(size(noise));
  
  for t=1:length(noise)
  acc = 0;
   for i=1:rank
    if t > rank
       acc = acc + coefs(i)*output(t-i);
    endif
  endfor
  
  output(t) = acc + noise(t);
  endfor
endfunction