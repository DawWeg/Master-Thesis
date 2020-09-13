global input_filename output_directory;

[dir, name, ext] = fileparts(input_filename);
output_directory =  ["00_data/output_samples/" name "/"];

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

save("-text", [output_directory, "PEAQ_Report.txt"], "odg");
disp(odg);