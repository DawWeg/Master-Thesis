run('includes.m')
% Arsin parameters
lead_in = 1024; 
lead_out = 1024;
p = 31; 
q = 31; 
w = 1024;
threshold = 5;
fatness = 4;
interp_iters = 3;

[rec_1, Fs] = audioread("11_ARSIN_Method/verification/rec_REF_1.wav");
rec_1 = rec_1(1:5*48000);
%[rec_12, Fs] = audioread("11_ARSIN_Method/verification/rec_REF_12.wav");
%[rec_31, Fs] = audioread("11_ARSIN_Method/verification/rec_REF_31.wav");
%[rec_38, Fs] = audioread("11_ARSIN_Method/verification/rec_REF_38.wav");

[x1 idl] = do_arsin_process(rec_1, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
audiowrite("11_ARSIN_Method/verification/rec_ARSIN_1.wav", x1, Fs);

%[x12 idl2] = do_arsin_process(rec_12, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
%audiowrite("11_ARSIN_Method/verification/rec_ARSIN_12.wav", x12, Fs);

%[x31 idl] = do_arsin_process(rec_31, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
%audiowrite("11_ARSIN_Method/verification/rec_ARSIN_31.wav", x31, Fs);

%[x38 idl] = do_arsin_process(rec_38, p, q, w, lead_in, lead_out, threshold, fatness, interp_iters);
%audiowrite("11_ARSIN_Method/verification/rec_ARSIN_38.wav", x38, Fs);


StartS  = Fs+1;
EndS    = 21*Fs;

odg.rec1 = PQevalAudio( "11_ARSIN_Method/verification/rec_ORG_1.wav", ...
                        "11_ARSIN_Method/verification/rec_ARSIN_1.wav",...
                        StartS, EndS);
%{  
odg.rec12 = PQevalAudio( "11_ARSIN_Method/verification/rec_ORG_12.wav", ...
                         "11_ARSIN_Method/verification/rec_ARSIN_12.wav",...
                         StartS, EndS);
                      
odg.rec31 = PQevalAudio( "11_ARSIN_Method/verification/rec_ORG_31.wav", ...
                         "11_ARSIN_Method/verification/rec_ARSIN_31.wav",...
                         StartS, EndS);  
                         
odg.rec38 = PQevalAudio( "11_ARSIN_Method/verification/rec_ORG_38.wav", ...
                         "11_ARSIN_Method/verification/rec_ARSIN_38.wav",...
                         StartS, EndS);
%}                       
save('-text', '05_testing/arsin_verify/results.txt', 'odg');
