function [data_save_filename] = get_data_save_filename(method_name, ext)
  global output_directory input_filename;
  if nargin<2
    ext = ".dat"
  endif
  id = "";
  [dir, name, ext] = fileparts(input_filename);
  data_save_filename = strcat([output_directory, "data/",id, method_name, "_", name, ext]);
endfunction
