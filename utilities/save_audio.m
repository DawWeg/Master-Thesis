function save_audio(method_name, samples, save_with_id)
  global output_directory input_filename frequency;
  datetime = int32(clock());
  id = "";
  if save_with_id
   id = sprintf("%4d_%02d_%02d_%02d%02d%02d_", ...
                  datetime(1), datetime(2), datetime(3), ...
                  datetime(4), datetime(5), datetime(6)); 
  endif
  mkdir([output_directory "audio/"]);
  save_filename = strcat([output_directory, "audio/", id, method_name, "_", input_filename]);
  audiowrite(save_filename, samples, frequency);
  printf("Saved audio file as %s\n", save_filename);
endfunction
