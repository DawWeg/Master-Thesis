run("init.m");

current_file = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, 0.0, 5);

%{
  SCL_MODE description.
  First number:
    0 - open loop detector,
    1 - closed loop detector.
  Second number:
    0 - batch interpolator,
    1 - variable rank kalman filter interpolator.
%}
global SCL_MODE = [1; 1];

%%% Creating bidirectional detection signal
%{
  BIDI_MODE description.
  First number defines merging rule for configuration A:
  0 - logic sum,
  1 - logic product,
  2 - "front edge-front edge".
  Second number defines merging rule for configuration B:
  0 - logic sum with filling,
  1 - logic product.
  Third number defines merging rule for configuration C:
  0 - logic sum,
  1 - logic product,
  2 - "front edge".
  Fourth number defines merging rule for configuration D:
  0 - logic sum with filling,
  1 - logic product,
  2 - "front edge-front edge".
%}
global BIDI_MODE = [2; 0; 2; 2];
clear_signal_fb = zeros(size(input_signal));
detection_signal_fb = zeros(size(input_signal));
[clear_signal_fb, detection_signal_fb] = SCL_BIDI_ImpulseNoiseReduction(input_signal);

                                                                               

                                                                               
