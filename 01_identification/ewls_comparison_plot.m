color_model = [0.0, 0.0, 0.0];
color_recu = [0.7 0.3, 0.1];
color_iter = [0.1 0.3, 0.7];

figure(1);
h_model = plot( (ones(model_rank,2).*[0, N])', [ar_model; ar_model], 'color', color_model);
hold on;
h_ewls_recu_coefs = plot(ewls_recu_coefs', 'color', color_recu, ':');
h_ewls_iter_coefs = plot(ewls_iter_coefs', 'color', color_iter, '--');
hold off;

xlim([-inf inf]); ylim([ 1.5*min(ar_model), 1.5*max(ar_model)]); grid on;
title("Model coefficients:");
legend([h_model, h_ewls_recu_coefs, h_ewls_iter_coefs]',  {"Model", "EWLS Recu", "EWLS Iter"});


figure(2);
subplot(2,1,1);
abs_recu = abs(ewls_recu_error);
abs_iter = abs(ewls_iter_error);
h_ewls_recu_coefs = plot(abs_recu, 'color', color_recu, ':');
hold on;
h_ewls_iter_coefs = plot(abs_iter, 'color', color_iter, '--');
hold off;
xlim([-inf inf]); ylim([ 0, noise_sigma*4 ]); grid on;
title("Absolute one step prediction errors:");
legend([h_ewls_recu_coefs, h_ewls_iter_coefs]',  {"EWLS Recu", "EWLS Iter"});

subplot(2,1,2);
h_ewls_recu_coefs = plot(ewls_recu_noise_variance, 'color', color_recu, ':');
hold on;
h_ewls_iter_coefs = plot(ewls_iter_noise_variance, 'color', color_iter, '--');
hold off;
xlim([-inf inf]); ylim([ 0, sqrt(noise_sigma)*2 ]); grid on;
title("Noise variance:");
legend([h_ewls_recu_coefs, h_ewls_iter_coefs]',  {"EWLS Recu", "EWLS Iter"});


figure(3);
subplot(3,1,1);
plot(abs(ewls_recu_coefs' - ewls_iter_coefs'), 'color', color_recu); 
xlim([-inf inf]); ylim([0 noise_sigma*2]); grid on;
title("Coefficients trajectory absolute difference");

subplot(3,1,2);
plot(abs(ewls_recu_error - ewls_iter_error), 'color', color_recu); 
xlim([-inf inf]); ylim([0 noise_sigma*2]); grid on;
title("One step prediction error trajectory absolute difference");

subplot(3,1,3);
plot(abs(ewls_recu_noise_variance - ewls_iter_noise_variance), 'color', color_recu); 
xlim([-inf inf]); ylim([0 noise_sigma*2]); grid on;
title("Noise variance absolute difference");