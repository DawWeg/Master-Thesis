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
detection_signal_fb = zeros(length(input_signal),1);
dbstop("SCL_BIDI_ImpulseNoiseReduction");
[clear_signal_fb, detection_signal_fb] = SCL_BIDI_ImpulseNoiseReduction(input_signal);

figure(1);
subplot(4,1,1);
plot(input_signal(:,1));
hold on;
plot(clear_signal_fb(:,1));
hold off;
subplot(4,1,2);
plot(input_signal(:,2));
hold on;
plot(clear_signal_fb(:,2));
hold off;                                                                          
subplot(4,1,3);
plot(abs(input_signal(:,1)-clear_signal_fb(:,1)));
subplot(4,1,4);
plot(abs(input_signal(:,2)-clear_signal_fb(:,2))); 

save_audio(current_file,"BIDI_SCL",clear_signal_fb,frequency,1);                                                                   
