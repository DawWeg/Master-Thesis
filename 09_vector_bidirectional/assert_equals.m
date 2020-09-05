function [] = assert_equals(test_name, expected, found)
  if all(expected==found)
    printf("%s : OK\n", test_name);
  else
    printf("%s : NOT OK\n", test_name);
    disp(expected); disp(found);
  endif
endfunction
