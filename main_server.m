%%% Preparing workspace
run("init_server.m");
global input_filename;
global frequency;
input_directory = [input_directory, 'clear/' ];
filenames_peaq = dir(input_directory);

do_peaq = 0;
do_peaq_generate_new_noisy_samples = 0;

filenames = filenames_peaq;
for i=1:length(filenames)

  
  input_file = filenames(i);
  input_filename_with_extension = input_file.name; 
  [dir, name, ext] = fileparts(input_filename_with_extension);
  if(isempty(name) || (name == '.') || (ext == '.txt'))
    continue;
  endif
  
  input_filename = input_filename_with_extension;
  disp(input_filename)
  
  % Prepare testing signal
  seconds_start = 0; seconds_end = -1;
  [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
  
  % Generate noisy signals if specified
  if do_peaq_generate_new_noisy_samples
    generate_noisy_file(input_signal);
  endif
  
  % Load saved noisy signal
  [noisy_signal, frequency] = load_audio(['../noise/' input_filename], seconds_start, seconds_end);
  
  % Save input data for reporting and PEAQ (file is shortened from both sides - workaround for PEAQ error)
  save_audio("NOISY", noisy_signal, 0);
  save_audio("CLEAR", input_signal, 0);
  save("-binary", get_data_save_filename("INPUT"), "input_signal", "noisy_signal");
  
  ARSIN_ImpulseNoiseReduction(noisy_signal);
  VAR_BIDI_ImpulseNoiseReduction(noisy_signal);
  SCL_BIDI_ImpulseNoiseReduction(noisy_signal);
  
endfor 


%{
do_peaq = 0;
do_process_peaq = 0;
do_process_normal = 0;

execution_error_log = [];





if do_process_peaq

    for i =1:10
        try
            current_file = deblank(strtrim(filenames(i,:)));

            ARSIN_ImpulseNoiseReduction(noisy_signal);
            VAR_BIDI_ImpulseNoiseReduction(noisy_signal);
            SCL_BIDI_ImpulseNoiseReduction(noisy_signal);
        catch
            execution_error_log = [lasterror(), execution_error_log];
        end_try_catch
    endfor

endif

save("-text", [deblank(strtrim(output_directory)), "execution_error_log.txt"], "execution_error_log");
%}