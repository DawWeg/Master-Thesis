%%% Preparing workspace
run("init_server.m");
global input_filename;
global frequency;
org_input_directory = input_directory;

do_peaq = 1;
do_peaq_process = 1;
do_peaq_analysis = 1;

do_normal = 0;
do_normal_process = 1;
execution_error_log = [];

if do_peaq
    input_directory = org_input_directory;
    input_directory = [input_directory, 'clear/' ];
    filenames = dir(input_directory);
    for i=1:length(filenames)
            input_file = filenames(i);
            input_filename_with_extension = input_file.name; 
            [dir, name, ext] = fileparts(input_filename_with_extension);
            if(isempty(name) || (name == '.') || (ext == '.txt'))
                continue;
            endif
            output_directory =  ["00_data/output_samples/server/" name "/"];
            input_filename = input_filename_with_extension;
              
            % Prepare testing signal
            seconds_start = 0; seconds_end = 10;
            [input_signal, frequency] = load_audio(input_filename, seconds_start, seconds_end);
            [noisy_signal, frequency] = load_audio(['../noise/' input_filename], seconds_start, seconds_end);
            % Save input data for reporting and PEAQ (file is shortened from both sides - workaround for PEAQ error)
            save_audio("NOISY", noisy_signal, 0);
            save_audio("CLEAR", input_signal, 0);
            save("-binary", get_data_save_filename("INPUT"), "input_signal", "noisy_signal");
              
            if do_peaq_process
                ARSIN_ImpulseNoiseReduction(noisy_signal);
                VAR_BIDI_ImpulseNoiseReduction(noisy_signal);
                SCL_BIDI_ImpulseNoiseReduction(noisy_signal);
            endif
              
            if do_peaq_analysis
                [dir, name, ext] = fileparts(input_filename);
                output_directory =  ["00_data/output_samples/server/" name "/"];

                f_noisy     = [ output_directory 'audio/NOISY_' name ext];
                f_clear     = [ output_directory 'audio/CLEAR_' name ext];
                f_scl_f     = [ output_directory 'audio/SCL_F_' name ext];
                f_scl_b     = [ output_directory 'audio/SCL_B_' name ext];
                f_scl_fb    = [ output_directory 'audio/SCL_FB_' name ext];
                f_scl_fbb   = [ output_directory 'audio/SCL_FBB_' name ext];
                f_scl_fbf   = [ output_directory 'audio/SCL_FBF_' name ext];
                f_var_f     = [ output_directory 'audio/VAR_F_' name ext];
                f_var_b     = [ output_directory 'audio/VAR_B_' name ext];
                f_var_fb    = [ output_directory 'audio/VAR_FB_' name ext];
                f_var_fbb   = [ output_directory 'audio/VAR_FBB_' name ext];
                f_var_fbf   = [ output_directory 'audio/VAR_FBF_' name ext];
                f_arsin     = [ output_directory 'audio/ARSIN_' name ext];

                odg.clear    = PQevalAudio (f_clear, f_clear);
                odg.noisy    = PQevalAudio (f_clear, f_noisy);

                odg.scl_f    = PQevalAudio (f_clear, f_scl_f);
                odg.scl_b    = PQevalAudio (f_clear, f_scl_b);
                odg.scl_fb   = PQevalAudio (f_clear, f_scl_fb);
                odg.scl_fbb  = PQevalAudio (f_clear, f_scl_fbb);
                odg.scl_fbf  = PQevalAudio (f_clear, f_scl_fbf);

                odg.var_f    = PQevalAudio (f_clear, f_var_f);
                odg.var_b    = PQevalAudio (f_clear, f_var_b);
                odg.var_fb   = PQevalAudio (f_clear, f_var_fb);
                odg.var_fbb  = PQevalAudio (f_clear, f_var_fbb);
                odg.var_fbf  = PQevalAudio (f_clear, f_var_fbf);

 
                odg.arsin = PQevalAudio (f_clear, f_arsin);

                save("-text", [output_directory, "PEAQ_Report.txt"], "odg");
            endif

    endfor 
endif


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


