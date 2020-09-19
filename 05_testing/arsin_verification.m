
% Arsin parameters
lead_in = 1024; 
lead_out = 1024;
p = 31; 
q = 31; 
w = 1024;
threshold = 5;
fatness = 4;
interp_iters = 3;

%[rec_1, Fs] = audioread("05_testing/arsin_verify/rec_REF_1.wav");
%[x1 idl] = do_arsin_process(rec_1, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
%audiowrite("05_testing/arsin_verify/rec_ARSIN_1.wav", x1, Fs);
%StartS  = Fs+1;
%EndS    = 21*Fs;
%odg    = PQevalAudio ("05_testing/arsin_verify/rec_ORG_1.wav", "05_testing/arsin_verify/rec_ARSIN_1.wav", StartS, EndS);
%save('-text', '05_testing/arsin_verify/result_1.txt', 'odg');


%[rec_12, Fs] = audioread("05_testing/arsin_verify/rec_REF_12.wav");
%[xl idl] = do_arsin_process(rec_12, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
%audiowrite("05_testing/arsin_verify/rec_ARSIN_12.wav", x1, Fs);
%StartS  = Fs+1;
%EndS    = 21*Fs;
%odg    = PQevalAudio ("05_testing/arsin_verify/rec_ORG_12.wav", "05_testing/arsin_verify/rec_ARSIN_12.wav", StartS, EndS);
%save('-text', '05_testing/arsin_verify/result_12.txt', 'odg');


%[rec_31, Fs] = audioread("05_testing/arsin_verify/rec_REF_31.wav");
%[x1 idl] = do_arsin_process(rec_31, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
%audiowrite("05_testing/arsin_verify/rec_ARSIN_31.wav", x1, Fs);
%StartS  = Fs+1;
%EndS    = 21*Fs;
%odg    = PQevalAudio ("05_testing/arsin_verify/rec_ORG_31.wav", "05_testing/arsin_verify/rec_ARSIN_31.wav", StartS, EndS);
%save('-text', '05_testing/arsin_verify/result_31.txt', 'odg');


[rec_38, Fs] = audioread("05_testing/arsin_verify/rec_REF_38.wav");
[x1 idl] = do_arsin_process(rec_38, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
audiowrite("05_testing/arsin_verify/rec_ARSIN_38.wav", x1, Fs);
StartS  = Fs+1;
EndS    = 21*Fs;
odg    = PQevalAudio ("05_testing/arsin_verify/rec_ORG_38.wav", "05_testing/arsin_verify/rec_ARSIN_38.wav", StartS, EndS);
save('-text', '05_testing/arsin_verify/result_38.txt', 'odg');


          