detection_ideal = [0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 0 0 0 ];
detection_est   = [0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 ];

N = length(detection_ideal);
%mu = 0; var = 10;
%noise = sqrt(var).*randn(1,N) + mu;

noise = 10*ones(1,N);

mu = 0; var = 1;
clear_signal = sqrt(var).*randn(1,N) + mu;
%detection_ideal = zeros(N,1);
%detection_est = zeros(N,1);
%clear_signal = zeros(1,N);

%block_length = 10;
%offset = 0;
%for i=1+offset:block_length*2:N
%  detection_ideal(i:i+block_length) = 1;
%endfor

%for i=1+offset:block_length:N
%  detection_est(i:i+block_length-10) = 1;
%endfor


noise_to_inject = detection_ideal.*noise;
ideal_noise_energy = sum(noise_to_inject.^2);
noisy_signal = clear_signal + noise_to_inject;

detection_and = (detection_est+detection_ideal) == 2;
noise_detected_correctly = detection_and.*noise;
est_noise_energy = sum(noise_detected_correctly.^2);

alarms_ideal = find_alarms(detection_ideal);
alarms_est = find_alarms(detection_est);

similarity_based_indicator = 0;
similarities = 0;
for i=1:length(alarms_est(1,:))
    est_start = alarms_est(1,i);
    est_end = alarms_est(2,i);
    ideal_alarams_in_range = find_alarms_in_range(detection_ideal, est_start, est_end);
   
    
    for j=1:length(ideal_alarams_in_range(1,:))
      ends = [est_end, ideal_alarams_in_range(2,j)];
      beginnings =  [est_start, ideal_alarams_in_range(1,j)];
      similarity_based_indicator += ...
          (min(ends) - max(beginnings) + 1) ...
          / ...
          (max(ends) - min(beginnings) + 1);
      similarities++;
    endfor
endfor

if(similarities > 0)
  similarity_based_indicator = (similarity_based_indicator/similarities)*100;
endif


figure(1);
subplot(3,1,1); stem(noisy_signal); grid on;
title("Noisy signal");
subplot(3,1,2); stem(noise_to_inject); grid on;
title("Noise injected");
subplot(3,1,3); stem(noise_detected_correctly); grid on;
title("Noise detected correctly");
%color_ideal = [0.1, 0.9, 0.1];
%color_est = [0.1 0.1, 0.9];
%color_and = [0.9 0.1, 0.0];
%figure(2);
%plot(detection_ideal, 'color', color_ideal, 'linewidth', 2); hold on;
%plot(detection_est, 'color', color_est, 'linewidth', 2); 
%plot(detection_and, 'color', color_and, 'linewidth', 3);  hold off; grid on;
figure(2);
subplot(3,1,1); stem(detection_ideal); grid on; ylim([0 1.5]);
title("Ideal detection");
subplot(3,1,2); stem(detection_est);  grid on; ylim([0 1.5]);
title("Real detection");
subplot(3,1,3); stem(detection_and); grid on; ylim([0 1.5]);
title("(Real AND Ideal) detection");



energy_based_indicator = (est_noise_energy/ideal_noise_energy)*100;

printf("Noise energy coverage: %f%%\n", energy_based_indicator);
printf("Found: %f overlapping alarms, with average of %f%% similarity\n", similarities, similarity_based_indicator);
