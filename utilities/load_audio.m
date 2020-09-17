function [samples, frequency] = load_audio(filename, start_seconds, end_seconds)
  global input_directory;
  [samples, frequency] = audioread(strcat([input_directory, filename]));
  sample_time = 1/frequency;
  start_sample = floor(start_seconds/sample_time) + 1;
  
  if end_seconds==-1
   end_sample = length(samples(:,1));
  else
   end_sample = end_seconds/sample_time;
  endif
  
  samples = samples((start_sample:end_sample),:);
endfunction
