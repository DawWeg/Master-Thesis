function [output_value] = mround(input_value)
  global decimal_accuracy;
  multiplier = power(10,decimal_accuracy);
  output_value = round(multiplier.*input_value)./multiplier;
endfunction
