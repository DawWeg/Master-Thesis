function [y1so,y2so,d1,d2,x1,x2,prog1x,prog2x] ...
    = algorytm_VAR_prost_durb_dobry_detektor(y1,y2,r,lams,mi,kmax,NN)



% plot(y2)

% cc

% wariancja = zeros(55,1);





lam_w      = 0.99;
wsp_w      = 1-lam_w;

tol        = -12;

wsps       = 1-lams;

N = length(y1);


pauza      = 0;
alarmy     = 0;
alarmy1     = 0;
alarmy2     = 0;
m          = 0;

n          = 2*r;
r2         = 2*r;
r_2        = r2;

Aq = zeros(r2,r2);
Aq(3:end,1:end-2) = eye(r2-2,r2-2);

y1s = y1;
y2s = y2;

% y1s2 = y1;
% y2s2 = y2;

y1so = y1;
y2so = y2;

% y1sox = y1;
% y2sox = y2;

Y = [y1';y2'];


x1 = zeros(N,1);
x2 = zeros(N,1);

prog1x = zeros(N,1);
prog2x = zeros(N,1);

d1 = zeros(N,1);
d2 = zeros(N,1);



fi = zeros(n,1);


alarm_start = false;
ee          = zeros(2,1);

pauza = 0;
 %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&    
 
koniec = N - kmax+r;
tic
%########################################################################
tx = NN;

sr1 = mean(y1(1:2000));
sr2 = mean(y2(1:2000));
%-----------------------------------
%usuwanie wartoœci œredniej
for t = 1:tx     
         
     y1s(t) = y1(t) - sr1;
     y2s(t) = y2(t) - sr2;
         
     sr1 = lams*sr1 + wsps*y1(t);
     sr2 = lams*sr2 + wsps*y2(t);
         
     Y(:,t) = [y1s(t);y2s(t)];
end
%-----------------------------------
     
R11 = zeros(r+1,1);
R12 = zeros(r+1,1);
R21 = zeros(r+1,1);
R22 = zeros(r+1,1);

    
for i=0:r  
    for j=1+i:tx
        R11(i+1) = R11(i+1)+ y1s(j)*y1s(j-i);
        R12(i+1) = R12(i+1)+ y1s(j)*y2s(j-i);
        R21(i+1) = R21(i+1)+ y2s(j)*y1s(j-i);
        R22(i+1) = R22(i+1)+ y2s(j)*y2s(j-i);
   end                               
end  
    
[teta1, teta2,QQ] = alg_lev_durb_var(r,R11,R12,R21,R22);
NN_old = QQ./NN;

%predykcja jednokrokowa
NN_old11 = 0;
NN_old21 = 0;
NN_old22 = 0;

        for t=r+1:tx
            %--------------------------
            %--------------------------
            for ki = 1:r                
                od = 2*(ki-1) + 1;
                do = 2*(ki-1) + 2;
                
                fi(od) = y1s(t-ki);
                fi(do) = y2s(t-ki);                                         
            end
            %--------------------------
            %--------------------------
            
            
            %-------------------------------------
            %-------------------------------------
            suma1 = 0;
            suma2 = 0;
            %n=2*r
            
            for ki = 1:r2                
                suma1 = suma1 + fi(ki)*teta1(ki);
                suma2 = suma2 + fi(ki)*teta2(ki);
            end
                        
            e1  = y1s(t) - suma1;
            e2  = y2s(t) - suma2;
            
            NN_old11 = lam_w*NN_old11 + wsp_w*(e1^2);
            prog1    = mi*sqrt(NN_old11);
         
            NN_old22 = lam_w*NN_old22 + wsp_w*(e2^2);
            prog2    = mi*sqrt(NN_old22);
         
            NN_old21 = lam_w*NN_old21 + wsp_w*(e2*e1);
         
            prog1x(t+1) = prog1;
            prog2x(t+1) = prog2;

            x1(t) = e1;
            x2(t) = e2;
           %-------------------------------------
           %-------------------------------------
        end


for t=tx+1:koniec
%     t
    
    y1s(t) = y1(t) - sr1;
    y2s(t) = y2(t) - sr2;
%     y1so(t) = y1s(t);
%     y2so(t) = y2s(t);
%     
%     y1s2(t) = y1s(t);
%     y2s2(t) = y2s(t);
    
%     
%     Y(1,t) = y1s(t);
%     Y(2,t) = y2s(t);
    
  
                %----------------------------
                %----------------------------
                %test stabilnoœci
%                 Aq(1,1:r2) = teta1(1:r2)';  
%                 Aq(2,1:r2) = teta2(1:r2)';  
%    
%                 moduly = abs(eig(Aq))
%                 stab = max(moduly);
%                 
%                 if stab > 1
%                     ds(t) = 1;                    
%                 end
                %----------------------------
                %----------------------------
    
                  
    
    if m == 0
        
    
            %--------------------------
            %--------------------------
            for ki = 1:r                
                od = 2*(ki-1) + 1;
                do = 2*(ki-1) + 2;
                
                fi(od) = y1s(t-ki);
                fi(do) = y2s(t-ki);                                         
            end
            %--------------------------
            %--------------------------
            
            
            %-------------------------------------
            %-------------------------------------
            suma1 = 0;
            suma2 = 0;
            for ki = 1:n                
                suma1 = suma1 + fi(ki)*teta1(ki);
                suma2 = suma2 + fi(ki)*teta2(ki);
            end
            
            
            x1(t)  = y1s(t) - suma1;
            x2(t)  = y2s(t) - suma2;
         
           %-------------------------------------
           %-------------------------------------
           
           
           e1 = x1(t);
           e2 = x2(t);
           %-------------------------------------

           %-------------------------------------
           if  pauza<=0
                if (abs(e1) > prog1) 
                    
                        alarm_start = true;
                        m = 1; 
                        d1(t) = 1;                      
                end
                
                
                if (abs(e2) > prog2)
                    
                        alarm_start = true;
                        m = 1; 
                        d2(t) = 1;
                end
           end
        %-------------------------------------
        %-------------------------------------
        pauza = pauza - 1;
  
    end
    
    
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


    if m > 0
        
        
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$         
        if alarm_start == true
         
            
            teta_H = [teta1 teta2];
            
            Xz_f   = fi;   
            
            Pz_f   = zeros(r2,r2);           
            m      = 0;
            alarm_start = false;
            to     = t-1;
            
            prog1o = prog1;
            prog2o = prog2;
            
            NN_old2 = [NN_old11 NN_old21 ; NN_old21 NN_old22];
            
%             CC = 100;
%             
%             wariancja = zeros(CC,1);
%             wariancja2 = zeros(CC,1);
%             
%             wariancja11 = zeros(CC,1);
%             wariancja22 = zeros(CC,1);
            
%               predykcja jednokrokowa
%                 Aq         = zeros(r2+CC,r2+CC);
%                 Aq(3:end,1:end-2) = eye(r2+CC-2,r2+CC-2);
%                 Aq(1,1:r2) = teta1(1:r2)';  
%                 Aq(2,1:r2) = teta2(1:r2)';  
%                 
% 
%                 moduly = abs(eig(Aq));
%                 stab = max(moduly);
                
%                 if stab > 1
                    
%                     'model niestabilny'
%                     t
%                     stab
%                     pause
%                 end
%                  
        end
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 
                
                
            %Uwaga NN_old = QQ./NN;  lub NN_old2
            
            
              %-----------------------------------------------
            %pierwsza wersja
%             H     = Pz_f(:,1:r2) * teta_H;              
%             G      = teta_H'*Pz_f(1:r2,1:r2)*teta_H + NN_old;  
%             Pz_p   = [G H'; H Pz_f];
            %-----------------------------------------------
            
            %-----------------------------------------------
            H1     = Pz_f(:,1:r2) * teta_H;
            H2     = teta_H'*Pz_f(1:r2,:);
            G      = teta_H'*Pz_f(1:r2,1:r2)*teta_H + NN_old2;
            Pz_p   = [G H2; H1 Pz_f];              
            %-----------------------------------------------
%           
            
            Y_pr   = teta_H'*Xz_f(1:r2);
            Xz_p   = [Y_pr; Xz_f];
            
            ee(1,1)     = y1s(t) - Y_pr(1);
            ee(2,1)     = y2s(t) - Y_pr(2);
          
            %-----------------------------------------
             if G(1,1) < 0     
               disp('ujemna wariancja - interpolacja')  
               t
               G
               m
               
               1
               to
               NN_old
%                hold off
%                plot(wariancja)
%                hold on
%                plot(wariancja2,'r')
%                hold on
%                plot(wariancja11,'g')
%                hold on
%                plot(wariancja22,'k')
%                
%                wariancja-wariancja11
%                wariancja2-wariancja22
               
%                stairs(2+d1(t-50:t+50))
%                hold on
%                stairs(d2(t-50:t+50))
%                cc
                %-----------------------------
                %predykcja jednokrokowa
%                 Aq(1,1:r2) = teta1(1:r2)';  
%                 Aq(2,1:r2) = teta2(1:r2)';  
%    
%                 moduly = abs(eig(Aq));
%                 stab   = max(moduly)
    
                %wymuszenie dodatniej wariancji
                G(1,1) = 0;
%                 
                pause
             end
%              -----------------------------------------
             if G(2,2) < 0  
               disp('ujemna wariancja - interpolacja')
               t
               G
               m
               
               2
               to
               
               to
               NN_old
%                hold off
%                plot(wariancja)
%                hold on
%                plot(wariancja2,'r')
%                hold on
%                plot(wariancja11,'g')
%                hold on
%                plot(wariancja22,'k')
%                
%                wariancja-wariancja11
%                wariancja2-wariancja22
%                cc
%                 -----------------------------
%                 predykcja jednokrokowa
%                 Aq(1,1:r2) = teta1(1:r2)';  
%                 Aq(2,1:r2) = teta2(1:r2)';  
%    
%                 moduly = abs(eig(Aq));
%                 stab = max(moduly)
                
%                 wymuszenie dodatniej wariancji
                G(2,2) = 0;
                disp('ujemna wariancja - interpolacja')
                pause
             end
             %-----------------------------------------
             
             
            prog1 = mi*sqrt((G(1,1)));
            prog2 = mi*sqrt((G(2,2)));   
            
            x1(t)    = ee(1,1);
            x2(t)    = ee(2,1);
            prog1x(t) = prog1;
            prog2x(t) = prog2;
            
            if abs(ee(1,1)) > prog1
               d1(t) = 1;          
            end
    
            if abs(ee(2,1)) > prog2
               d2(t) = 1;             
            end
            
            %------------------------------------------
          

        
            %------------------------------------------
            if t == koniec
                d1(t-m:t) = 0; 
                d2(t-m:t) = 0; 
            end
 
            
            %--------------------------------------------------------------
            %--------------------------------------------------------------
             %sytuacja A
            if d1(t) == 1 && d2(t) == 1 && m < kmax

            %kolejne zabezpieczenie od œmieci na ogonach liczb
%             Xz_f   = Xz_p;
%             Pz_f   = Pz_p;

            Xz_f   = roundn(Xz_p, tol);
            Pz_f   = roundn(Pz_p, tol);
%             PP     = roundn(PP, tol);
            
%             Pz_fx   = roundn(Pz_px, tol);
                        
            m      = m + 1;
            licznik_dobrych_probrk = 0;
            %--------------------------------------------------------------
            %--------------------------------------------------------------
            else
                
            %--------------------------------------------------------------
            %--------------------------------------------------------------  
               
                %sytuacja B
                if d1(t) == 0 && d2(t) == 1 && m < kmax
                                
                
                lr   = (1/G(1,1))*(Pz_p(:,1));
                %ze wzglêdu na b³edy numeryczne
                %wymuszenie '1'
                lr(1) = 1;
                lr(1) = roundn(lr(1), tol);
                
                Xz_f = Xz_p + lr*ee(1,1);
%                 Pz_f = Pz_p - G(1,1)*(lr*lr');
%                 Pz_f(1,1) = 0;
        
                        %--------------------------------------------------
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie dodatnio okreœlonoœci
                        WW = length(Pz_p);
                        
                        CCx = [1 0 zeros(1,WW-2)];    
                        ZZ  = (eye(WW,WW) - lr*CCx);
                        Pz_f = ZZ*Pz_p*ZZ';     
                        Pz_f(1,1) = 0;
                        %--------------------------------------------------
                        
                %kolejne zabezpieczenie od œmieci na ogonach liczb
                Xz_f = roundn(Xz_f, tol);
                Pz_f = roundn(Pz_f, tol);            
                
                m    = m + 1;
                licznik_dobrych_probrk = 0;
                
           %--------------------------------------------------------------
           %--------------------------------------------------------------     
                else
                    
            %--------------------------------------------------------------
            %--------------------------------------------------------------
                %sytuacja C
                if d1(t) == 1 && d2(t) == 0 && m < kmax
                          
                lr    = 1/(G(2,2))*(Pz_p(:,2));
                
                %ze wzglêdu na b³edy numeryczne
                %wymuszenie '1'
                lr(2) = 1;
                lr(2) = roundn(lr(2), tol);
                
                Xz_f  = Xz_p + lr*ee(2,1);
%                 Pz_f  = Pz_p - G(2,2)*(lr*lr');
                
                        %--------------------------------------------------
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie dodatnio okreœlonoœci
                        WW = length(Pz_p);
                        
                        CCx = [0 1 zeros(1,WW-2)];
                        ZZ  = (eye(WW,WW) - lr*CCx);
                        Pz_f = ZZ*Pz_p*ZZ';     
                        Pz_f(2,2) = 0;
                        %--------------------------------------------------
                
                %kolejne zabezpieczenie od œmieci na ogonach liczb
                Xz_f = roundn(Xz_f, tol);
                Pz_f = roundn(Pz_f, tol);
                
                m      = m + 1;
                licznik_dobrych_probrk = 0;
                
                  %--------------------
%                 if t > 7580
%                 t
%                 disp('sytuacja C')
%                 pause
% 
%                 end
                  %--------------------
                  
            %--------------------------------------------------------------
            %--------------------------------------------------------------    
                else
                    
            %--------------------------------------------------------------
            %--------------------------------------------------------------
                    %sytuacja D
                    if (d1(t) == 0 && d2(t) == 0) ||  m >= kmax

                        %wa¿ne w przypadku przpe³nienia
                        d1(t) = 0;
                        d2(t) = 0;
                        
                        %odwracanie macierzy 2x2
                        GD = [G(2,2) -G(1,2); -G(2,1) G(1,1)];
                        G1 = (1/det(G))*GD;
                        
%                         Lrx          = Pz_p(:,1:2)*(G^-1);

                        Lr  = Pz_p(:,1:2)*G1;
                        
                        
                        
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie '1'
                        Lr(1:2,1:2) = eye(2,2);
                        Lr = roundn(Lr, tol);
                     
                        Xz_f = Xz_p + Lr*ee;    
                        
%                         Pz_f = Pz_p - Lr*G*Lr'; %ma³e liczby      
                        
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie dodatnio okreœlonoœci
                        WW = length(Pz_p);
                        CCx = [eye(2,2) zeros(2,WW-2)];
                        ZZ = (eye(WW,WW) - Lr*CCx);
                        Pz_f = ZZ*Pz_p*ZZ';     
                        Pz_f(1:2,1:2) = zeros(2,2);

                        %kolejne zabezpieczenie od œmieci na ogonach liczb
                        Xz_f = roundn(Xz_f, tol);
                        Pz_f = roundn(Pz_f, tol);

                        m    = m + 1;                                                
                        licznik_dobrych_probrk = licznik_dobrych_probrk + 1;                           
                        
                            %---------------------
%                               t
% %                             m
% %                             kmax
%                             disp('dobra _probka')
%                             licznik_dobrych_probrk
%                             pause
                            %---------------------
                            
                        if licznik_dobrych_probrk == r
                            
                            m        = m - r;
                            

                            %----------------------------------------------
                            %scalanie alarmów detekcyjnych
                            
                            d11 = d1(t-2*r-m+1:t);
                            d22 = d2(t-2*r-m+1:t);
                            
                            d1x = d1;
                            d2x = d2;
                            
                            diff_d11 = diff(d11);
                            diff_d22 = diff(d22);
                            
                                                      
                            pocz_d1  = find(diff_d11 == 1) + 1;
                            kon_d1   = find(diff_d11 == -1);
                            
                            pocz_d2  = find(diff_d22 == 1) + 1;
                            kon_d2   = find(diff_d22 == -1);
                            
                            
         
                            
                            %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                            %-------------------------------------
                            %drugi wariant scalania bloków
                    
                            Len1 = length(pocz_d1);
                            
                            for i = 1:Len1-1
                            
                                if Len1 > i
                                    
                                    if pocz_d1(i+1) - kon_d1(i) <= r                                        
                                        d11(kon_d1(i):pocz_d1(i+1)) = 1;                                        
                                    end
                                    
                                end
                            end
                            
                            Len2 = length(pocz_d2);
                            
                            for i = 1:Len2-1
                            
                                if Len2 > i
                                    
                                    if pocz_d2(i+1) - kon_d2(i) <= r                                        
                                        d22(kon_d2(i):pocz_d2(i+1)) = 1;
                                    end
                                    
                                end
                            end
                            %-------------------------------------
                            %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                            
                            %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                            %przygotowanie wektora do wykreœlania kolumn 
                            %w macierzy A
                            
                            
                            d1(t-2*r-m+1:t) = d11;
                            d2(t-2*r-m+1:t) = d22;
% %                             
                            detektor = [];                        
                            det_razem = [d11,d22];
                            
                            for kk=1:2*r+m
                                detektor = [detektor; det_razem(kk,:)'];
                            end  
%                             
%                             
%                             %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                             %----------------------------------------------
                             
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

                             %--------------------------------------------
                              %ponowne uruchomienie filtru kalmana dla
                              %detekcji bez dziur
                              
                              td = to + 1;
                        
                              teta_H = [teta1 teta2];         
                              Xz_f2   = [];
                              Xz_f2   = fi;               
                              Pz_f   = zeros(r_2,r_2);           
                              m      = 0;
            
            %##############################################################
            %##############################################################
            for tt = td:t
            %tylko ma³a czêœæ macierzy kowariancji jest potrzebna do
            %aktualizacji macierzy G

%             G      = teta_H'*Pz_f(1:r2,1:r2)*teta_H + NN_old;            
%             H      = Pz_f(:,1:r2) * teta_H;       
%             Pz_p   = [G H'; H Pz_f];
            
            %-----------------------------------------------
            H1     = Pz_f(:,1:r2) * teta_H;
            H2     = teta_H'*Pz_f(1:r2,:);
            G      = teta_H'*Pz_f(1:r2,1:r2)*teta_H + NN_old;
            Pz_p   = [G H2; H1 Pz_f];              
            %-----------------------------------------------
            
            
            Y_pr   = teta_H'*Xz_f2(1:r2);
            
            Xz_p        = [Y_pr; Xz_f2];
            ee(1,1)     = y1s(tt) - Y_pr(1);
            ee(2,1)     = y2s(tt) - Y_pr(2);
            
            
            %-----------------------------------------
             if G(1,1) < 0     
               disp('ujemna wariancja - interpolacja')  
               t
               G
               m
               
                %-----------------------------
                %predykcja jednokrokowa
%                 Aq(1,1:r2) = teta1(1:r2)';  
%                 Aq(2,1:r2) = teta2(1:r2)';  
%    
%                 moduly = abs(eig(Aq));
%                 stab   = max(moduly)
    
                %wymuszenie dodatniej wariancji
                G(1,1) = 0;
%                 
%                 pause
             end
%              -----------------------------------------
             if G(2,2) < 0  
               disp('ujemna wariancja - interpolacja')
               t
               G
               m
               
%                 -----------------------------
%                 predykcja jednokrokowa
%                 Aq(1,1:r2) = teta1(1:r2)';  
%                 Aq(2,1:r2) = teta2(1:r2)';  
%    
%                 moduly = abs(eig(Aq));
%                 stab = max(moduly)
                
%                 wymuszenie dodatniej wariancji
                G(2,2) = 0;
                disp('ujemna wariancja - interpolacja')
%                 pause
             end
             %-----------------------------------------

        
            %------------------------------------------
            if tt == koniec
                d1(tt-m:tt) = 0; 
                d2(tt-m:tt) = 0; 
            end
 
            
            %--------------------------------------------------------------
            %--------------------------------------------------------------
             %sytuacja A
            if d1(tt) == 1 && d2(tt) == 1 && m < kmax

            %kolejne zabezpieczenie od œmieci na ogonach liczb
            Xz_f2   = roundn(Xz_p, tol);
            Pz_f   = roundn(Pz_p, tol);
                        
            m      = m + 1;
            %--------------------------------------------------------------
            %--------------------------------------------------------------
            else
                
            %--------------------------------------------------------------
            %--------------------------------------------------------------  
               
                %sytuacja B
                if d1(tt) == 0 && d2(tt) == 1 && m < kmax
                                
                
                lr   = (1/G(1,1)).*(Pz_p(:,1));
                %ze wzglêdu na b³edy numeryczne
                %wymuszenie '1'
                lr(1) = 1;
                lr(1) = roundn(lr(1), tol);
                
                Xz_f2 = Xz_p + lr*ee(1,1);
%                 Pz_f = Pz_p - G(1,1)*(lr*lr');
%                 Pz_f(1,1) = 0;
                
                        %--------------------------------------------------
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie dodatnio okreœlonoœci
                        WW = length(Pz_p);
                        
                        CCx = [1 0 zeros(1,WW-2)];    
                        ZZ  = (eye(WW,WW) - lr*CCx);
                        Pz_f = ZZ*Pz_p*ZZ';     
                        Pz_f(1,1) = 0;
                        %--------------------------------------------------
        
                
                %kolejne zabezpieczenie od œmieci na ogonach liczb
                Xz_f2 = roundn(Xz_f2, tol);
                Pz_f = roundn(Pz_f, tol);            
                
                m    = m + 1;
                
           %--------------------------------------------------------------
           %--------------------------------------------------------------     
                else
                    
            %--------------------------------------------------------------
            %--------------------------------------------------------------
                %sytuacja C
                if d1(tt) == 1 && d2(tt) == 0 && m < kmax
                          
                lr    = 1/(G(2,2))*(Pz_p(:,2));
                
                %ze wzglêdu na b³edy numeryczne
                %wymuszenie '1'
                lr(2) = 1;
                lr(2) = roundn(lr(2), tol);
                
                Xz_f2  = Xz_p + lr*ee(2,1);
%                 Pz_f   = Pz_p - G(2,2)*(lr*lr');
                
                       %--------------------------------------------------
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie dodatnio okreœlonoœci
                        WW = length(Pz_p);
                        
                        CCx = [0 1 zeros(1,WW-2)];
                        ZZ  = (eye(WW,WW) - lr*CCx);
                        Pz_f = ZZ*Pz_p*ZZ';     
                        Pz_f(2,2) = 0;
                        %--------------------------------------------------
                
                
                %kolejne zabezpieczenie od œmieci na ogonach liczb
                Xz_f2 = roundn(Xz_f2, tol);
                Pz_f  = roundn(Pz_f, tol);
                
                m      = m + 1;        
            %--------------------------------------------------------------
            %--------------------------------------------------------------    
                else
                    
            %--------------------------------------------------------------
            %--------------------------------------------------------------
                    %sytuacja D
                    if (d1(tt) == 0 && d2(tt) == 0) ||  m >= kmax

                        %wa¿ne w przypadku przpe³nienia
                        d1(tt) = 0;
                        d2(tt) = 0;
                        
                        %odwracanie macierzy 2x2
                        GD = [G(2,2) -G(1,2); -G(2,1) G(1,1)];
                        G1 = (1/det(G))*GD;
                        
%                         Lrx          = Pz_p(:,1:2)*(G^-1);
                        Lr  = Pz_p(:,1:2)*G1;
                        
                        
                        
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie '1'
                        Lr(1:2,1:2) = eye(2,2);
                        Lr = roundn(Lr, tol);
                     
                        Xz_f2 = Xz_p + Lr*ee;                      
%                         Pz_f = Pz_p - Lr*G*Lr'; %ma³e liczby      
                        
                        %ze wzglêdu na b³edy numeryczne
                        %wymuszenie dodatnio okreœlonoœci
                        WW = length(Pz_p);
                        CCx = [eye(2,2) zeros(2,WW-2)];
                        ZZ = (eye(WW,WW) - Lr*CCx);
                        Pz_f = ZZ*Pz_p*ZZ';     
                        Pz_f(1:2,1:2) = zeros(2,2);
     
%                         Pz_f(1:2,1:2) = zeros(2,2);

                        %kolejne zabezpieczenie od œmieci na ogonach liczb
                        Xz_f2 = roundn(Xz_f2, tol);
                        Pz_f = roundn(Pz_f, tol);

                        m    = m + 1;                                   
                    end
                end
            end
        end
            
                
                
            end
                Xz_f = Xz_f2;
                m = m - r;
%                              %----------------------------------------------
% %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$                                 
%                             %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                            Nc   = length(Xz_f)/2;
                            y11c = zeros(Nc,1);
                            y22c = zeros(Nc,1);
                   
                            for i=1:Nc
                                od = (i-1)*2 + 1;
                                do = (i-1)*2 + 2;
                                y11c(i) = Xz_f(od);
                                y22c(i) = Xz_f(do);
                            end   
                            ycc1 = flipud(y11c);                            
                            ycc2 = flipud(y22c);
                            
                            y1s(t-r-m+1:t-r) = ycc1(r+1:r+m);
                            y2s(t-r-m+1:t-r) = ycc2(r+1:r+m);
                            y1so(t-r-m+1:t-r) = ycc1(r+1:r+m) + sr1;
                            y2so(t-r-m+1:t-r) = ycc2(r+1:r+m) + sr2;

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$                                 
                            %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
                            %----------------------------------------------
                            %rekonstrukcja wsadowa - offline
% w przetwarzaniu dwukierunkowym nie potrzebne                              
%                             yall = [];
%                             
%                             for i = 1:2*r+m
%                                 yall = [yall ; y1s(t-2*r-m+i);y2s(t-2*r-m+i)];                        
%                             end
%                             
%                             orgi   = find(detektor == 0);
%                             
%                             yo     = yall(orgi);
                            
                           
%                             ym  = rek_probek_AR_multi_const2(teta1,teta2,m,r,NN_old,detektor,yo);                             
% %                             
%                              %----------------------------------------------
%                             %przepisanie w odpowiednie miejsca
%                             %zrekonstruowanych próbek sygna³u dla obu
%                             %kana³ów
%                             % w przetwarzaniu dwukierunkowym nie potrzebne                            
%                             p     = 2;
%                             numer_rek = 1;
%                             
%                             for i=1:m
%                                  od     = 2*r + (i-1)*p + 1;
%                                  do     = 2*r + (i-1)*p + p;
%                                  
%                                  if detektor(od) == 1               
% %                                     y1s(t-r-m+i)  = ym(numer_rek) ; 
% %                                     y1so(t-r-m+i) = ym(numer_rek) + sr1;
%                                     y1sox(t-r-m+i) = ym(numer_rek)+ sr1;
%                                     numer_rek    = numer_rek + 1;
%                                     
%                                  end
%                                  
%                                  if detektor(do) == 1
% %                                     y2s(t-r-m+i)  = ym(numer_rek) ; 
% %                                     y2so(t-r-m+i) = ym(numer_rek) + sr2;
%                                     y2sox(t-r-m+i) = ym(numer_rek)+ sr2;
%                                     numer_rek    = numer_rek + 1;
%                                     
%                                  end
% %                                  Y(:,t-r-m+i) = [y1s(t-r-m+i); y2s(t-r-m+i)];
%                             end

             
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$       

                           %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  
                           %ustawienie pocz¹tkowych wartoœci
%                   if t > 3.38*10^4     
%                       
%                       
%                         Aq(1,1:r2) = teta1(1:r2)';  
%                         Aq(2,1:r2) = teta2(1:r2)';  
%    
%                         moduly = abs(eig(Aq));
%                         stab = max(moduly)
%                         war_scz
%                         max(war_scz)
% 
% %                             'ok'
% %                             hold off
% %                             Nc   = length(Xz_f)/2;
% %                             y11c = zeros(Nc,1);
% %                             y22c = zeros(Nc,1);
% %                    
% %                             for i=1:Nc
% %                                 od = (i-1)*2 + 1;
% %                                 do = (i-1)*2 + 2;
% %                                 y11c(i) = Xz_f(od);
% %                                 y22c(i) = Xz_f(do);
% %                             end   
% %                             
% %                             Nc   = length(Xz_f)/2;
% %                             y111c = zeros(Nc,1);
% %                             y222c = zeros(Nc,1);
% %                    
% %                             for i=1:Nc
% %                                 od = (i-1)*2 + 1;
% %                                 do = (i-1)*2 + 2;
% %                                 y111c(i) = Xz_f2(od);
% %                                 y222c(i) = Xz_f2(do);
% %                             end   
% %                             ycc = flipud(y22c);
% %                             
% %                             y2s2(t-2*r-m+1:t) = ycc;
% %                             
% % %                             yy = flipud(y11c);
% % %                             yy(r+1:r+m) = ym2;
% % d1xx = zeros(N,1);
% % d2xx = zeros(N,1);
% % beta
% % d1xx(t-2*r-m+1:t) = d1(t-2*r-m+1:t);
% % d2xx(t-2*r-m+1:t) = d2(t-2*r-m+1:t);
% % 
% %                             subplot(211)
% %                             hold off
% %                             plot(bet(:,2,2)+1)
% %                             hold on
% %                             plot(-0.5+x2)
% %                             hold on
% %                             plot(to-TT+1,-0.5+x2(to-TT+1),'ro')
% %                             hold on
% %                             plot(to-TT+1,y2s(to-TT+1),'ro')
% %                             hold on
% %                             plot(to+1,y2s(to+1),'ro')
% %                             hold on
% %                             plot((y2s))
% % %                             hold on
% % %                             plot(y1s+1,'r')
% %                             hold on
% %                             plot(y2so,'g')
% %                             hold on
% %                             plot(y2s2,'r')
% %                             hold on
% %                             stairs(-1.3+d1xx./20,'r')
% %                             hold on
% %                             stairs(-1.4+d2xx./20,'r')
% % 
% %                             subplot(212)
%                             hold off
% %                             
% ods = 0.8;
% % zak = 100;
%                             plot(ods+y1so(t-2*r-m+1:t))
%                             hold on
%                             plot(y2so(t-2*r-m+1:t))
%                             hold on
%                             
%                             plot(ods+y1sox(t-2*r-m+1:t),'g')
%                             hold on
%                             plot(y2sox(t-2*r-m+1:t),'g')
%                             hold on
%                             
%                             plot(ods+y1s2(t-2*r-m+1:t),'r')
%                             hold on
%                             plot(y2s2(t-2*r-m+1:t),'r')
%                             hold on
% %                             plot(ods+flipud(y11c),'r.')
% %                             hold on
% %                             plot(flipud(y22c),'r.')
% %                             
% %                             
% %                             
% % %                             ym - ycc(r+1:r+m)
% % %                             
% % %                             ycc(r+1:r+m)
% %                             
% %                             hold on
% %                             plot(ods+flipud(y111c),'mo')
% %                             hold on
% %                             plot(flipud(y222c),'mo')
% %                             
% %                             
% %                             plot(ods+y1s(t-2*r-m+1:t),'k')
% %                             hold on
% %                             plot(y2s(t-2*r-m+1:t),'k')
% %                             
% %                             
% %                             
% %                             hold on
% %                             stairs(-0.3+d1x(t-2*r-m+1:t)./10,'k')
% %                             hold on
% %                             stairs(-0.4+d2x(t-2*r-m+1:t)./10,'k')
%                             hold on
%                             stairs(-0.3+d1(t-2*r-m+1:t)./20,'r')
%                             hold on
%                             stairs(-0.4+d2(t-2*r-m+1:t)./20,'r')
% % t
% % m
% %                             pause
%        cc
%                   end
                           %ewentualna pauza w przypadku d³ugich alarmów
                           %detekcyjnych
                           if m >= 80                            
                               pauza = 50; 
                           end
                           
                           %-----------------------------------------------
                           %-----------------------------------------------
                           %Aktualizacja na zrekonstruowanym fragmencie
                           
                           for tt = t-r-m+1:t 
                               
                                %--------------------------
                                %--------------------------
                                    for ki = 1:r                
                                        od = 2*(ki-1) + 1;
                                        do = 2*(ki-1) + 2;
                
                                        fi(od) = y1s(tt-ki);
                                        fi(do) = y2s(tt-ki);                                         
                                    end
                                %--------------------------
                                %--------------------------
            
            
                                %-------------------------------------
                                %-------------------------------------
                                    suma1 = 0;
                                    suma2 = 0;
                                    for ki = 1:n                
                                        suma1 = suma1 + fi(ki)*teta1(ki);
                                        suma2 = suma2 + fi(ki)*teta2(ki);
                                    end
            
            
                                    e1  = y1s(tt) - suma1;
                                    e2  = y2s(tt) - suma2;
                                    
                                    x1(tt) = e1;
                                    x2(tt) = e2;
                                %-------------------------------------
                                %-------------------------------------
           
           
                                % Aktualizacja parametrów
                                for i=0:r    
                                  R11(i+1) = R11(i+1)+ y1s(tt)*y1s(tt-i)- y1s(tt-NN)*y1s(tt-NN+i);
                                  R12(i+1) = R12(i+1)+ y1s(tt)*y2s(tt-i)- y2s(tt-NN)*y1s(tt-NN+i);
                                  R21(i+1) = R21(i+1)+ y2s(tt)*y1s(tt-i)- y1s(tt-NN)*y2s(tt-NN+i);
                                  R22(i+1) = R22(i+1)+ y2s(tt)*y2s(tt-i)- y2s(tt-NN)*y2s(tt-NN+i);                                                
                                end 


                                %algorytm levinson durbin
                                [teta1, teta2,war_scz] = alg_lev_durb_var(r,R11,R12,R21,R22);
                   

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$                                
                                
                                
                                
                           end
                           
       
                      
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                            %-----------------------------------------------
%                            %---------------------------------------------
                           
                           
                            alarm_start = false;
                            
                           
                            licznik_dobrych_probrk = 0;
                            prog1x(t+1) = prog1o;
                            prog2x(t+1) = prog2o;
                            alarmy      = alarmy + 1
                            
                            if sum(d11)>0
                                alarmy1      = alarmy1 + 1
                            end
                            
                            if sum(d22)>0
                                alarmy2      = alarmy2 + 1
                            end
                            
                             m = 0;
                            %---------------------------------------------
                          
                           %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  

                    
                            
                            
                        end
                            
                            
                    end
                  end
                end
            end
             %--------------------------------     
            
            
            
            
            
            
            
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        
    else
        

        
         NN_old11 = lam_w*NN_old11+wsp_w*(e1^2);
         prog1    = mi*sqrt(NN_old11);
         
         NN_old22 = lam_w*NN_old22+wsp_w*(e2^2);
         prog2    = mi*sqrt(NN_old22);
         
         NN_old21 = lam_w*NN_old21+wsp_w*(e2*e1);
         
         prog1x(t+1) = prog1;
         prog2x(t+1) = prog2;

       
         %------------------------------------------
         %------------------------------------------
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% Aktualizacja parametrów
 for i=0:r    
     R11(i+1) = R11(i+1)+ y1s(t)*y1s(t-i)- y1s(t-NN)*y1s(t-NN+i);
     R12(i+1) = R12(i+1)+ y1s(t)*y2s(t-i)- y2s(t-NN)*y1s(t-NN+i);
     R21(i+1) = R21(i+1)+ y2s(t)*y1s(t-i)- y1s(t-NN)*y2s(t-NN+i);
     R22(i+1) = R22(i+1)+ y2s(t)*y2s(t-i)- y2s(t-NN)*y2s(t-NN+i);                                                
 end 
 
 %algorytm levinson durbin
      [teta1, teta2,QQ] = alg_lev_durb_var(r,R11,R12,R21,R22);
      NN_old = QQ./NN;
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



      sr1    = lams*sr1 + wsps*y1(t);
      sr2    = lams*sr2 + wsps*y2(t);
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        
    end
    
    
end


toc
alarmy 
alarmy1
alarmy2

% subplot(211)
% hold off
% plot(1+y1)
% hold on
% plot(1+y1so,'r')
% 
% hold on
% plot(y2)
% hold on
% plot(y2so,'r')
% 
% dd = 0.3;
% 
% subplot(212)
% hold off
% plot(dd + abs(x1))
% hold on
% plot(dd +abs(x1),'.')
% hold on
% plot(dd +prog1x,'r')
% hold on
% plot(dd +prog1x,'r.')
% hold on
% 
% plot(abs(x2))
% hold on
% plot(abs(x2),'.')
% hold on
% plot(prog2x,'r')
% hold on
% plot(prog2x,'r.')
% 
% hold on
% stairs(-0.1+d1./40)
% hold on
% stairs(-0.3+d2./40)


% figure
% subplot(211)
% hold off
% plot(y1-e1x+2,'r')
% hold on
% plot(y1+2)
% hold on
% plot(y2-e2x,'r')
% hold on
% plot(y2)
% 
% subplot(212)
% hold off
% plot(e1x+.2)
% hold on
% plot(e2x)
% cc




 function [DD] = rek_probek_AR_multi_const2(teta1,teta2,k,r,N,detektor,yo)
%----------------------------------------------------------------------
%Napisane przez Marcina Cio³ek
%Ostatnia aktulizacja kodu 03.12.2013

%----------------------------------------------------------------------
% global stoper
% 

format long 


a  = zeros(2,2*r+2);
r2 = 2*r;

%-----------------------------------
%-----------------------------------
for i= r2:-2:1

    ii = r2-i+1;
    a(1,ii)    = -teta1(i-1);
    a(1,ii+1)  = -teta1(i,1);
    a(2,ii)    = -teta2(i-1);
    a(2,ii+1)  = -teta2(i);
end

a(1,2*r+1) = 1;
a(2,2*r+2) = 1;
%-----------------------------------
%-----------------------------------


%-------------------------------------------------    
%-------------------------------------------------
% NX = N^(-0.5);

NX = (sqrtm(N))^(-1);
AN = (NX)*a; 
n = 2*(r+k);
m = 2*r+2;
A = zeros(n,2*(2*r+k));
    
    for i=1:2:n
        for j=1:m
            A(i,j+i-1)   = AN(1,j);
            A(i+1,j+i-1) = AN(2,j);
        end
    end
    
%-------------------------------------------------    
%-------------------------------------------------    


    do_rek = find(detektor == 1);
    orgi   = find(detektor == 0);
    
    Am     = A(:,do_rek);
    Ao     = A(:,orgi);
    R      = (Am'*Am)^-1;
    DD     =  -(R)*(Am')*(Ao)*yo;
