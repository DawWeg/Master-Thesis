function print_quantity_test_result( total_alarms_ideal,...
                                     total_alarms_est,...
                                     energy_based_indicator,...
                                     similarity_based_indicator)
  
  line = "|--------------------------------------------------------------------------------------------------|\n";
  printf("\n");
  printf(line);
  printf("| Channel |  Total alarms  |  Detected alarms  | Noise Energy coverage [%%] | Alarms similarity [%%] |\n");
  printf(line);
  printf("|    L    | %13.0f  |%17.0f  | %25.10f | %21.10f |\n",...
    total_alarms_ideal(1), total_alarms_est(1), energy_based_indicator(1), similarity_based_indicator(1));
  printf(line);
  printf("|    R    | %13.0f  |%17.0f  | %25.10f | %21.10f |\n",...
    total_alarms_ideal(2), total_alarms_est(2), energy_based_indicator(2), similarity_based_indicator(2));
  printf(line);
  
endfunction
