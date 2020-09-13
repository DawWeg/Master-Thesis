run("init.m");

global input_filename;
global frequency;
input_filename = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, 0.0, 10);

clear_signal = zeros(size(input_signal));
detection_signal = zeros(size(input_signal));
[clear_signal(:,1)] = SCL_ImpulseNoiseReduction(input_signal(:,1));
[clear_signal(:,2)] = SCL_ImpulseNoiseReduction(input_signal(:,2));

save_audio("SCL",clear_signal,1);