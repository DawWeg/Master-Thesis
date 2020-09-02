run("init.m");

current_file = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, 0.0, 0.5);

%%% Unidirectional analysis
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

%%% Forward analysis
clear_signal_f = zeros(size(input_signal));
detection_signal_f = zeros(size(input_signal));
ewls_coefficients_estimate_f = zeros(model_rank, length(input_signal), 2);
ewls_noise_variance_f = zeros(size(input_signal));

[clear_signal_f(:,1), ...
 detection_signal_f(:,1), ~, ~, ...
 ewls_coefficients_estimate_f(:,:,1), ...
 ewls_noise_variance_f(:,1)] = SCL_ImpulseNoiseReduction(input_signal(:,1));
 
[clear_signal_f(:,2), ...
 detection_signal_f(:,2), ~, ~, ...
 ewls_coefficients_estimate_f(:,:,2), ...
 ewls_noise_variance_f(:,2)] = SCL_ImpulseNoiseReduction(input_signal(:,2));

%%% Backward analysis
clear_signal_b = zeros(size(input_signal));
detection_signal_b = zeros(size(input_signal));
ewls_coefficients_estimate_b = zeros(model_rank, length(input_signal), 2);
ewls_noise_variance_b = zeros(size(input_signal));

[clear_signal_b(:,1), ...
 detection_signal_b(:,1), ~, ~, ...
 ewls_coefficients_estimate_b(:,:,1), ...
 ewls_noise_variance_b(:,1)] = SCL_ImpulseNoiseReduction(flip(input_signal(:,1)));
 
[clear_signal_b(:,2), ...
 detection_signal_b(:,2), ~, ~, ...
 ewls_coefficients_estimate_b(:,:,2), ...
 ewls_noise_variance_b(:,2)] = SCL_ImpulseNoiseReduction(flip(input_signal(:,2)));
 
clear_signal_b = flip(clear_signal_b,1);
detection_signal_b = flip(detection_signal_b,1);
ewls_coefficients_estimate_b = flip(ewls_coefficients_estimate_b,2);
ewls_noise_variance_b = flip(ewls_noise_variance_b,1);

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
[clear_signal_fb(:,1), detection_signal_fb(:,1)] = SCL_BIDI_ImpulseNoiseReduction(clear_signal_f(:,1), ...
                                                                                 clear_signal_b(:,1), ...
                                                                                 detection_signal_f(:,1), ...
                                                                                 detection_signal_b(:,1), ...
                                                                                 ewls_coefficients_estimate_f(:,:,1), ...
                                                                                 ewls_coefficients_estimate_b(:,:,1), ... 
                                                                                 ewls_noise_variance_f(:,1), ...
                                                                                 ewls_noise_variance_b(:,1));
[clear_signal_fb(:,2), detection_signal_fb(:,2)] = SCL_BIDI_ImpulseNoiseReduction(clear_signal_f(:,2), ...
                                                                                 clear_signal_b(:,2), ...
                                                                                 detection_signal_f(:,2), ...
                                                                                 detection_signal_b(:,2), ...
                                                                                 ewls_coefficients_estimate_f(:,:,2), ...
                                                                                 ewls_coefficients_estimate_b(:,:,2), ... 
                                                                                 ewls_noise_variance_f(:,2), ...
                                                                                 ewls_noise_variance_b(:,2));
                                                                               

                                                                               
%save_audio(current_file, "SCL_F_3", clear_signal_f, frequency, 1);
%save_audio(current_file, "SCL_B_3", clear_signal_b, frequency, 1);
%save_audio(current_file, "SCL_FB_3_7E6", clear_signal_fb, frequency, 1);