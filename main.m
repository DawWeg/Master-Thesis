run("init.m");
source("06_vector_extension/vector_utils.m");
source("06_vector_extension/var_kalman.m");

%%% Script local parameters
should_plot = 1;
should_save_audio = 1;
load_audio_start_second = 0;
load_audio_end_second = 0.5; %-1 for whole file

%%% Reading input samples
current_file = filenames(1,:);
[input_signal, frequency] = load_audio(current_file, load_audio_start_second, load_audio_end_second);
%%% Executing alogorithms

[ clear_signal,...
  detection,...
  error,...
  variance ] = VAR_ImpulseNoiseReduction(input_signal) ;

printf("VAR Detected L: %d from %d | %d\n",...
  sum(detection(1,:)), length(detection(1,:)), ...
  (sum(detection(1,:))/length(detection(1,:)))*100);
printf("VAR Detected R: %d from %d | %d\n",...
  sum(detection(2,:)), length(detection(2,:)), ...
  (sum(detection(2,:))/length(detection(2,:)))*100);
 
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






