run("init.m");

%%% Script local parameters
should_plot = 1;
should_save_audio = 1;
load_audio_start_second = 0;
load_audio_end_second = 1; %-1 for whole file

%%% Reading input samples
current_file = filenames(1,:);

[input_signal, frequency] = load_audio(current_file, load_audio_start_second, load_audio_end_second);
input_signal = input_signal(:,1);
%%% Executing alogorithms


[  R_U_S_T_RK_output_signal,...
   R_U_S_T_RK_detection_signal,...
   R_U_S_T_RK_residual_errors,...
   R_U_S_T_RK_activate_threshold,...
   R_U_S_T_RK_release_threshold  ] = R_U_S_T_RK(input_signal, 256, 128);
R_U_S_T_RK_threshold = [R_U_S_T_RK_activate_threshold, R_U_S_T_RK_release_threshold];

%[  P_B_S_O_RK_output_signal,...
%   P_B_S_O_RK_detection_signal,...
%   P_B_S_O_RK_prediction_errors,...
%   P_B_S_O_RK_activate_threshold  ] = P_B_S_O_RK(input_signal);   
   
%%% Plotting results 
if should_plot
  plot_result(1, input_signal, R_U_S_T_RK_detection_signal, R_U_S_T_RK_output_signal);
  plot_error_detection(2, R_U_S_T_RK_residual_errors, R_U_S_T_RK_threshold);

  %plot_result(3, input_signal, P_U_S_O_RK_detection_signal, P_U_S_O_RK_output_signal);
  %plot_error_detection(4, P_U_S_O_RK_prediction_errors, P_U_S_O_RK_activate_threshold);
endif

%%% Saving audio files
if should_save_audio
  save_audio(current_file, R_U_S_T_RK_output_signal, frequency, 1);
  %save_audio(current_file, P_U_S_O_RK_output_signal, frequency, 1);
endif






