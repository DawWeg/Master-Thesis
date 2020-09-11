function [theta] = wwr_estimation3(N, input_signal)

  global model_rank;
  r = model_rank;
  coefficients_estimate = zeros(model_rank*4, 1);
  input_signal = [zeros(2,model_rank), input_signal, zeros(2,model_rank)];
  R = zeros(2, 2, model_rank+1);
  for k = 1:model_rank+1
    for i = 1:N-k
      R(:,:,k) = R(:,:,k) + input_signal(:,end-i+1)*input_signal(:,end-i-k+1)';
    endfor    
    R(:,:,k) = (1/N).*R(:,:,k);
  endfor 
  
  II  = eye(2,2);
  ZZ  = zeros(2,2);
     
  teta1x = zeros(2*r,1);
  teta2x = zeros(2*r,1);
  
  QQx    = zeros(2,2);
 %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

    
  AA = zeros(2,2,r,r);
  BB = zeros(2,2,r,r);
  QQ = zeros(2,2,r);
  SS = zeros(2,2,r);
  PP = zeros(2,2,r);
  KK1 = zeros(2,2,r);
  KK2 = zeros(2,2,r);
  
    
    %-----------------
    %levinson-wiggins-robinson
    kk0=0;
    kk1=1;
    kk2=2;
    
    
    AA(:,:,1,1) =  -R(:,:,kk1+1)*(R(:,:,kk0+1)^-1);
    BB(:,:,1,1) =  -R(:,:,kk1+1)'*(R(:,:,kk0+1)^-1);
    
    QQ(:,:,1) =  R(:,:,kk0+1) + AA(:,:,1,1)*R(:,:,kk1+1)';
    SS(:,:,1) =  R(:,:,kk0+1) + BB(:,:,1,1)*R(:,:,kk1+1);
    
    %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
         %sprawdzenie
         %---------------------------
         %R(n) > 0   Q > 0     S > 0               
%        
%          w1 = (eig(QQ(:,:,1)));
%          w2 = (eig(SS(:,:,1)));
%          
%          if min(w1) <= 0 
%              eig(QQ(:,:,1))
%             'macierz QQ niedodatnio okre�lona!!'
%             pause
%          end
%          
%          if min(w2) <= 0 
%              eig(SS(:,:,1))
%             'macierz SS niedodatnio okre�lona!!'
%             pause
%          end
      
         %--------------------------------------
         %budowa macierzy
%          for l=1:r
%         
%          Rx = zeros(2*l,2*l);
%          
%          
%          for m=1:l
%              
%             L=[];
%                 for m1=m:-1:2
%                     L = [L, R(:,:,m1)'];
%                 end
%          
%          
%                 for m1=1:l-(m-1)
%                     L = [L, R(:,:,m1)];
%                 end
%          
%                 od = 2*(m-1) + 1; 
%                 do = 2*(m-1) + 2; 
%                 
%                 Rx(od:do,:) = L;
%          end
%          %--------------------------------------
%          
%                 %--------------------------------------
%                 w11 = (eig(Rx));
%                 
%          
%                     if min(w11) <= 0 
%                         l
%                         'macierz Rx niedodatnio okre�lona!!'
%                         pause
%                     end
%                 %--------------------------------------
%          end
     
      
   
     %-----------------------------------
 %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   
 
    for n=1:r-1
        
       %---------------------------------------------------- 
       PP(:,:,n) = R(:,:,n+2); 
       for i=1:n         
           PP(:,:,n) = PP(:,:,n) + AA(:,:,n,i)*R(:,:,n+2-i);
       end
       %---------------------------------------------------- 
       

       %----------------------------------------------------

%          KK1(:,:,n+1) =  PP(:,:,n)*(SS(:,:,n)^-1);
%          KK2(:,:,n+1) =  (QQ(:,:,n)^-1)*PP(:,:,n);
%          
%          QL  = (chol(QQ(:,:,n),'lower'))^-1;
%          SL  = (chol(SS(:,:,n),'lower'))^-1;
%          K1  = QL*PP(:,:,n)*SL';
         
         
         %------------------------------------------
         %test Qn > 0 i Sn>0
         
%                qn = (eig(QQ(:,:,n)));
%                sn = (eig(SS(:,:,n)));
%                
%                if min(qn)<=0
%                     
%                  'macierz QQ niedodatnio okre�lona!!'
%                   pause
%                end
%                
%                if min(sn)<=0
%                     
%                  'macierz SS niedodatnio okre�lona!!'
%                   pause
%                end
         
         %------------------------------------------
         
               %------------------------
               %test wspolczynnikow odbicia

%                wk3 = abs(svd(K1));
%                
%                     if  max(wk3)>= 1.000001
%                         
%                         wk3
%                         'wspolczynniki obicia wieksze niz 1!!!'
%                         pause
%                     end
               %------------------------
        
       %----------------------------------------------------
       
       %----------------------------------------------------
        
                    XX = [II -PP(:,:,n)*(SS(:,:,n)^-1); -PP(:,:,n)'*(QQ(:,:,n)^-1) II];
                    
                    Y1 = [II;ZZ];
                    for i=1:n
                        
                        Yc = [AA(:,:,n,i); BB(:,:,n,n+1-i)];
                        Y1 = [Y1 Yc];
                    end
                    
                    Yc = [ZZ; II];
                    YY = [Y1 Yc];
                    
                    WW = XX*YY;
                    
                    
                    for ii=2:n+2                      
                        from = 2*(ii-1) + 1;
                        to = 2*(ii-1) + 2;
                        AA(:,:,n+1,ii-1) = WW(1:2,from:to);
                    end
                    
                    for ii=1:n+1                     
                        from = 2*(ii-1) + 1;
                        to = 2*(ii-1) + 2;
                        BB(:,:,n+1,n+2-ii) = WW(3:4,from:to);
                    end
         %----------------------------------------------------               
           
     
        QQ(:,:,n+1) =  QQ(:,:,n) - PP(:,:,n)*(SS(:,:,n)^-1)*PP(:,:,n)';
        SS(:,:,n+1) =  SS(:,:,n) - PP(:,:,n)'*(QQ(:,:,n)^-1)*PP(:,:,n);
        %----------------------------------------------------
        
    end
    
    %-------------------------
    for i=1:r
        TT = AA(:,:,r,i);
        
        from = 2*(i-1) + 1;
        to = 2*(i-1) + 2;
                        
        teta1x(from:to,1) = -TT(1,:);
        teta2x(from:to,1) = -TT(2,:);
    end
    
    QQx = QQ(:,:,r);
    %-------------------------
    theta = [teta1x; teta2x];
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

end