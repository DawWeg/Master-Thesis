run("init.m");

current_file = filenames(3,:);
[input_signal, frequency] = load_audio(current_file, 0.0, 5);

%{
  First number:
    0 - open loop detector,
    1 - closed loop detector,
  Second number:
    0 - batch interpolator,
    1 - variable rank kalman filter interpolator.
%}
global SCL_MODE = [1; 1];

clear_signal = zeros(size(input_signal));
detection_signal = zeros(size(input_signal));
[clear_signal(:,1)] = SCL_ImpulseNoiseReduction(input_signal(:,1));
[clear_signal(:,2)] = SCL_ImpulseNoiseReduction(input_signal(:,2));

save_audio(current_file, "SCL_1_1", clear_signal, frequency, 1);