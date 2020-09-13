run("init.m");
%%% Script local parameters
global model_rank; 
global alarm_expand;

alarm_expand = 2;
model_rank = 10;

load_audio_start_second = 0;
load_audio_end_second = 5; %-1 for whole file

%%% Reading input samples
global input_filename;
global frequency;
input_filename = filenames(1,:);
[input_signal, frequency] = load_audio(input_filename, load_audio_start_second, load_audio_end_second);
profile off;
profile clear;
%%% Executing alogorithms
profile on;
[claer_fb, clear_f, clear_b] = VAR_BIDI_ImpulseNoiseReduction(input_signal);
profile off;

