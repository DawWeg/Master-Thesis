run("init.m");

global frequency;
global input_filename = filenames(1,:);
[input_signal, frequency] = load_audio(input_filename, 0.0, 0.5);


clear_signal_fb = zeros(size(input_signal));
detection_signal_fb = zeros(length(input_signal),1);

profile on;
dbstop("SCL_BIDI_ImpulseNoiseReduction");
[clear_signal_fb, clear_signal_f, clear_signal_b, clear_signal_fbf, clear_signal_fbb] = SCL_BIDI_ImpulseNoiseReduction(input_signal);
profile off;

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

save_audio("BIDI_SCL",clear_signal_fb,1);                                                                   
