function [ total_alarms_ideal,...
           total_alarms_est,...
           energy_based_indicator,...
           similarity_based_indicator ] = single_channel_quantity_test( noise,...
                                                                        detection_ideal,...
                                                                        detection_est)
  
  noise = detection_ideal.*noise;
  ideal_noise_energy = sum(noise.^2);
  detection_and = (detection_est+detection_ideal) == 2;
  noise_detected_correctly = detection_and.*noise;
  est_noise_energy = sum(noise_detected_correctly.^2);

  %printf("Finding all alarms in ideal detection\n");
  alarms_ideal = find_alarms(detection_ideal);
  %printf("Finding all alarms in estimated detection\n");
  alarms_est = find_alarms(detection_est);

  similarity_based_indicator = 0;
  similarities = 0;
  N = length(alarms_est(1,:));
  for i=1:length(alarms_est(1,:))
      %print_progress("Single channel quantity test", i, N, N/100);
      est_start = alarms_est(1,i);
      est_end = alarms_est(2,i);
      ideal_alarams_in_range = find_alarms_in_range(detection_ideal, est_start, est_end);
     
      
      for j=1:length(ideal_alarams_in_range(1,:))
        ends = [est_end, ideal_alarams_in_range(2,j)];
        beginnings =  [est_start, ideal_alarams_in_range(1,j)];
        similarity_based_indicator += ...
            (min(ends) - max(beginnings) + 1) ...
            / ...
            (max(ends) - min(beginnings) + 1);
        similarities++;
      endfor
  endfor
  %print_progress("Single channel quantity test", i, N, N/100);

  if(similarities > 0)
    similarity_based_indicator = (similarity_based_indicator/similarities)*100;
  endif

  energy_based_indicator = (est_noise_energy/ideal_noise_energy)*100;
  total_alarms_est = length(alarms_est(1,:));
  total_alarms_ideal = length(alarms_ideal(1,:));
endfunction