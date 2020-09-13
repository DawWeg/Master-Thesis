%run("init.m");
%%% Script local parameters
%global model_rank; 
%global alarm_expand;

%alarm_expand = 2;
%model_rank = 10;

%load_audio_start_second = 0;
%load_audio_end_second = 1; %-1 for whole file

%%% Reading input samples
%global input_filename;
%global frequency;
%input_filename = filenames(1,:);
%[input_signal, frequency] = load_audio(input_filename, load_audio_start_second, load_audio_end_second);
%profile off;
%profile clear;
%%% Executing alogorithms
%profile on;
%[claer_fb, clear_f, clear_b] = VAR_BIDI_ImpulseNoiseReduction(input_signal);
%profile off;

load("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/data/VAR_F_Chopin_Gavrilov_1_Bflat_clear_48.dat");
load("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/data/VAR_B_Chopin_Gavrilov_1_Bflat_clear_48.dat");
load("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/data/VAR_FBB_Chopin_Gavrilov_1_Bflat_clear_48.dat");
load("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/data/VAR_FBF_Chopin_Gavrilov_1_Bflat_clear_48.dat");

[y_f, f] = audioread("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/audio/VAR_F_Chopin_Gavrilov_1_Bflat_clear_48.wav");
[y_b, f] = audioread("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/audio/VAR_B_Chopin_Gavrilov_1_Bflat_clear_48.wav");
[y_fb, f] = audioread("00_data/output_samples/Chopin_Gavrilov_1_Bflat_clear_48/audio/VAR_FB_Chopin_Gavrilov_1_Bflat_clear_48.wav");

%range = 70475:70550;
range = 90000:96000;
dz_f = d_f(1,range).*1;
errz_f = err_f(1,range).*1;
varz_f = var_f(1,range).*1;
dz_b = d_b(1,range).*1;
errz_b = err_b(1,range).*1;
varz_b = var_b(1,range).*1;
dz_fbf = d_fbf(1,range).*1;
errz_fbf = err_fbf(1,range).*1;
varz_fbf = var_fbf(1,range).*1;

yz_f = y_f'(1,range).*1;
yz_b = y_b'(1,range).*1;
yz_fb = y_fb'(1,range).*1;

nz_s = noisy_signal(range,1)';
noise_z = noise(range,1)';

figure(1);
subplot(4,1,2); plot(yz_f(1,:)); xlim([-inf inf]);
subplot(4,1,1); plot(noise_z(1,:)); xlim([-inf inf]);
subplot(4,1,4); plot(dz_f(1,:)); xlim([-inf inf]); ylim([0 1.2]);
subplot(4,1,3); plot(abs(errz_f(1,:))); hold on;  plot(4.5*sqrt(varz_f(1,:))); xlim([-inf inf]);

figure(2);
subplot(4,1,1); plot(noise_z(1,:)); xlim([-inf inf]);
subplot(4,1,2); plot(yz_b(1,:)); xlim([-inf inf]);
subplot(4,1,4); plot(dz_b(1,:)); xlim([-inf inf]); ylim([0 1.2]);
subplot(4,1,3); plot(abs(errz_b(1,:))); hold on;  plot(4.5*sqrt(varz_b(1,:))); xlim([-inf inf]);

figure(3);
plot(nz_s(1,:)); hold on;
plot(yz_f(1,:));
plot(yz_b(1,:));
plot(yz_fb(1,:)); hold off;
xlim([-inf inf]);
legend('Noisy', 'F','B','FB');

%figure(2);
%subplot(3,1,1); plot(dz_f(1,:)); xlim([-inf inf]); ylim([0 1.2]);
%subplot(3,1,2); plot(dz_b(1,:)); xlim([-inf inf]); ylim([0 1.2]);
%subplot(3,1,3); plot(dz_fbb(1,:)); xlim([-inf inf]); ylim([0 1.2]);
