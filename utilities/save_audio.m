function save_audio(method_name, samples, save_with_id)
  global output_directory input_filename frequency ewls_lambda;
  datetime = int32(clock());
  model_delay = round((1+ewls_lambda)/(1-ewls_lambda));
  id = "";
  if save_with_id
   id = sprintf("%4d_%02d_%02d_%02d%02d%02d_", ...
                  datetime(1), datetime(2), datetime(3), ...
                  datetime(4), datetime(5), datetime(6)); 
  endif
  mkdir([output_directory "audio/"]);
  save_filename = strcat([output_directory, "audio/", id, method_name, "_", input_filename]);
  audiowrite(save_filename, samples(1+model_delay:end-model_delay,:), frequency);
  printf("Saved audio file as %s\n", save_filename);
endfunction
