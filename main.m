run("init.m");
source("06_vector_extension/var_kalman.m");

%%% Script local parameters
should_plot = 1;
should_save_audio = 1;
load_audio_start_second = 0.2;
load_audio_end_second = 0.5; %-1 for whole file

%%% Reading input samples
current_file = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, load_audio_start_second, load_audio_end_second);
%%% Executing alogorithms


delta_1 = 2; %<2 ; 4>

[ clear_signal_f,...
  detection_f,...
  error_f,...
  variance_f ] = VAR_ImpulseNoiseReduction(input_signal) ;

[ clear_signal_fb,...
  detection_fb,...
  error_fb,...
  variance_fb ] = VAR_ImpulseNoiseReduction(flip(input_signal)) ;
  
clear_signal_fb = flip(clear_signal_fb')';
detection_fb = flip(detection_fb')';
error_fb = flip(error_fb')';
variance_fb = flip(variance_fb')';

figure(1);
subplot(2,1,1); plot(clear_signal_f(1,:));
subplot(2,1,2); plot(clear_signal_fb(1,:));
  
  
figure(2);
subplot(2,1,1); plot(detection_f(1,:));
subplot(2,1,2); plot(detection_fb(1,:));
  %{
printf("VAR Detected L: %d from %d | %d\n",...
  sum(detection(1,:)), length(detection(1,:)), ...
  (sum(detection(1,:))/length(detection(1,:)))*100);
printf("VAR Detected R: %d from %d | %d\n",...
  sum(detection(2,:)), length(detection(2,:)), ...
  (sum(detection(2,:))/length(detection(2,:)))*100);

 save_audio(current_file, "ORG", input_signal, frequency, 0); 
 save_audio(current_file, "VAR", clear_signal', frequency, 0); 
%%% Plotting results 
figure(1);
clf;
subplot(3,1,1);
title('Output L'); plot(clear_signal(1,:), 'k'); grid on;
subplot(3,1,2);
title('Error and threshold L');
hold on;
plot(abs(error(1,:)), 'r'); plot(mu*sqrt(variance(1,:)), 'm');
hold off;
grid on;
subplot(3,1,3);
title('Detection L');
stairs(detection(1,:), 'r');
grid on;

figure(2);
clf;
subplot(3,1,1);
title('Output R'); plot(clear_signal(2,:), 'k'); grid on;
subplot(3,1,2);
title('Error and threshold R');
hold on;
plot(abs(error(2,:)), 'r'); plot(mu*sqrt(variance(2,:)), 'm');
hold off;
grid on;
subplot(3,1,3);
title('Detection R');
stairs(detection(2,:), 'r');
grid on;
%%% Saving audio files



%}


z