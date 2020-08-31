function [noise, detection] = generate_artificial_noise(signal_length, skip, min_spacing, max_spacing)
  noise = zeros(signal_length,1);
  detection = zeros(signal_length,1);
  [samples_original, frequency] = audioread("00_data/test_samples/original_1.wav");
  [samples_clear, frequency] = audioread("00_data/test_samples/clear_1.wav");
  pulse_noise = samples_original-samples_clear; 
  pulse_noise = pulse_noise(250000:350000);
  printf("Extracting noise samples from signal...\n");
  alarms = find_alarms(abs(pulse_noise)>0);
  alarm_count = length(alarms);
  
  i=skip + 1;
  while i<signal_length
    alarm_num = floor(rand()*alarm_count+1);
    alarm_start = alarms(1, alarm_num);
    alarm_end = alarms(2, alarm_num);
    alarm_length = alarm_end-alarm_start;
    
    if i+alarm_length > signal_length
      alarm_length=signal_length-alarm_length;
      alarm_end=alarm_start+alarm_length;
    endif
    noise(i:i+alarm_length) = pulse_noise(alarm_start:alarm_end);
    detection(i:i+alarm_length) = 1;
    
    i=i+min_spacing+round(rand()*max_spacing);
  
  endwhile
  
endfunction