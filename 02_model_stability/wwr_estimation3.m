function [theta_l, theta_r, QQx] = wwr_estimation3(N, input_signal)

  %%% Preparing variables
  global model_rank;
  r = model_rank;
  II  = eye(2,2);
  ZZ  = zeros(2,2);     
  teta1x = zeros(2*r,1);
  teta2x = zeros(2*r,1);  
  QQx    = zeros(2,2);    
  AA = zeros(2,2,r,r);
  BB = zeros(2,2,r,r);
  QQ = zeros(2,2,r);
  SS = zeros(2,2,r);
  PP = zeros(2,2,r);
  KK1 = zeros(2,2,r);
  KK2 = zeros(2,2,r);

  %%% Calculating autocovariance coefficients  
  %input_signal = [zeros(2,model_rank), input_signal, zeros(2,model_rank)];
  %N = N+2*model_rank;  
  R = zeros(2, 2, model_rank+1);
  for k = 1:model_rank+1
    for i = 1:N-k
      R(:,:,k) = R(:,:,k) + input_signal(:,end-i+1)*input_signal(:,end-i-k+1)';
    endfor    
    R(:,:,k) = (1/N).*R(:,:,k);
  endfor 

  %%% Levinson-Wiggins-Robinson
  kk0=0;
  kk1=1;
  kk2=2;   
  % Starting conditions
  AA(:,:,1,1) =  -R(:,:,kk1+1)*(R(:,:,kk0+1)^-1);
  BB(:,:,1,1) =  -R(:,:,kk1+1)'*(R(:,:,kk0+1)^-1);
    
  QQ(:,:,1) =  R(:,:,kk0+1) + AA(:,:,1,1)*R(:,:,kk1+1)';
  SS(:,:,1) =  R(:,:,kk0+1) + BB(:,:,1,1)*R(:,:,kk1+1);
 
  for n=1:r-1
    PP(:,:,n) = R(:,:,n+2); 
    for i=1:n         
      PP(:,:,n) = PP(:,:,n) + AA(:,:,n,i)*R(:,:,n+2-i);
    endfor 
    
    XX = [II -PP(:,:,n)*(SS(:,:,n)^-1); -PP(:,:,n)'*(QQ(:,:,n)^-1) II];                   
    Y1 = [II;ZZ];
    for i=1:n                        
      Yc = [AA(:,:,n,i); BB(:,:,n,n+1-i)];
      Y1 = [Y1 Yc];
    endfor  
    
    Yc = [ZZ; II];
    YY = [Y1 Yc];                    
    WW = XX*YY;  
    for ii=2:n+2                      
      from = 2*(ii-1) + 1;
      to = 2*(ii-1) + 2;
      AA(:,:,n+1,ii-1) = WW(1:2,from:to);
    endfor
    
    for ii=1:n+1                     
      from = 2*(ii-1) + 1;
      to = 2*(ii-1) + 2;
      BB(:,:,n+1,n+2-ii) = WW(3:4,from:to);
    endfor          
     
    QQ(:,:,n+1) =  QQ(:,:,n) - PP(:,:,n)*(SS(:,:,n)^-1)*PP(:,:,n)';
    SS(:,:,n+1) =  SS(:,:,n) - PP(:,:,n)'*(QQ(:,:,n)^-1)*PP(:,:,n);        
  endfor   

  for i=1:r
    TT = AA(:,:,r,i);
        
    from = 2*(i-1) + 1;
    to = 2*(i-1) + 2;
                        
    teta1x(from:to,1) = -TT(1,:);
    teta2x(from:to,1) = -TT(2,:);
  endfor   
    
    
  %theta_l = [alfa_11', alfa_12', alfa_13', alfa_14']';
  %theta_r = [alfa_21', alfa_22', alfa_23', alfa_24']';
  %theta = [theta_l; theta_r];
  QQx = QQ(:,:,r);
  theta_l = teta1x;
  theta_r = teta2x;
end