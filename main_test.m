%%% Preparing workspace
run("init_server.m");
global input_filename;
global frequency;
org_input_directory = input_directory;

do_peaq = 1;
do_peaq_generate_new_noisy_samples = 1;
do_peaq_process = 0;
do_peaq_analysis = 0;

do_normal = 0;
do_normal_process = 1;
execution_error_log = [];

if do_peaq
    input_directory = org_input_directory;
    input_directory = [input_directory, 'clear/' ];
     
            input_filename_with_extension = [ 'piano_2.wav' ]; 
            [dir, name, ext] = fileparts(input_filename_with_extension);
            if(isempty(name) || (name == '.') || (ext == '.txt'))
                continue;
            endif
            output_directory =  ["00_data/output_samples/server/" name "/"];
            input_filename = input_filename_with_extension;
            
            % Generate noisy signals if specified
            if do_peaq_generate_new_noisy_samples
                seconds_start = 0; seconds_end = -1;
                [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
                generate_noisy_file(input_signal);
            endif
              
              
            % Prepare testing signal
            seconds_start = 0; seconds_end = -1;
            [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
            [noisy_signal, frequency] = load_audio(['../noise/' input_filename], seconds_start, seconds_end);
            % Save input data for reporting and PEAQ (file is shortened from both sides - workaround for PEAQ error)
            save_audio("NOISY", noisy_signal, 0);
            save_audio("CLEAR", input_signal, 0);
            save("-binary", get_data_save_filename("INPUT"), "input_signal", "noisy_signal");
             
              
            if do_peaq_analysis
                [dir, name, ext] = fileparts(input_filename);
                output_directory =  ["00_data/output_samples/server/" name "/"];

                f_noisy     = [ output_directory 'audio/NOISY_' name ext];
                f_clear     = [ output_directory 'audio/CLEAR_' name ext];
                odg.noisy    = PQevalAudio (f_clear, f_noisy)
            endif

    
endif


save("-binary", [deblank(strtrim(output_directory)), "execution_error_log.txt"], "execution_error_log");
