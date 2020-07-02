function save_audio(input_filename, samples, frequency)
  datetime = int32(clock());
  id = sprintf("%4d_%02d_%02d_%02d%02d%02d_", ...
                  datetime(1), datetime(2), datetime(3), ...
                  datetime(4), datetime(5), datetime(6));
  save_filename = strcat(["output_samples/",id,input_filename]);
  audiowrite(save_filename, samples, frequency);
  printf("Saved audio file as %s\n", save_filename);
endfunction
