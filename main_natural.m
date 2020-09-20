run("init.m");

if do_normal
    input_directory = org_input_directory;
    filenames = dir(input_directory);
    for i=1:length(filenames)
        try
            input_file = filenames(i);
            input_filename_with_extension = input_file.name; 
            [dir, name, ext] = fileparts(input_filename_with_extension);
            if(isempty(name) || (name == '.') || (ext == '.txt') || input_file.isdir)
                continue;
            endif
            output_directory =  ["00_data/output_samples/" name "/"];
            input_filename = input_filename_with_extension;
            seconds_start = 0; seconds_end = -1;
            [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
            

             ARSIN_ImpulseNoiseReduction(input_signal);
             VAR_BIDI_ImpulseNoiseReduction(input_signal);
             SCL_BIDI_ImpulseNoiseReduction(input_signal);
             
        catch
            error = lasterror()
            execution_error_log = [error, execution_error_log];
        end_try_catch
    endfor
endif


