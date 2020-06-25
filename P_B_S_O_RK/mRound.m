function [output_value] = mRound(decimal_place, input_value)
  multiplier = power(10,decimal_place);
  output_value = round(multiplier*input_value)/multiplier;
endfunction
