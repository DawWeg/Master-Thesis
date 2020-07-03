function save_data(input_filename, method_name, data, save_with_id)
  global output_directory;
  datetime = int32(clock());
  id = "";
  if save_with_id
   id = sprintf("%4d_%02d_%02d_%02d%02d%02d_", ...
                  datetime(1), datetime(2), datetime(3), ...
                  datetime(4), datetime(5), datetime(6)); 
  endif
  [dir, name, ext] = fileparts(input_filename);
  filename = strcat([output_directory,"data/",id, method_name, "_", name, ".dat"]);
  save("-binary", filename, "data"); 
  printf("Saved data file as %s\n", filename);
endfunction
