function [coefficients_estimate] = wwr_estimation2 (N, input_signal)
  %{
    Wielkosc N przyjmuje wartosc na podstawie równowaznej dlugosci zastosowanego okna wykladniczego.
    Wielkosc input_signal o wymiarach N x 2 zawierajaca oba kanaly sygnalu wykorzystana jest do wyznaczania
    lokalnych ocen macierzy autokowariancji. 
    Implementacja oparta byla na uzupelnieniu 8.6 z ksiazki P.Stoica "System Identification".  
  %}
  global model_rank; % Wielkosc model_rank okreslajaca rzad wykorzystywanego modelu autoregresyjnego. Zwyczajowo 10.  
  coefficients_estimate = zeros(model_rank*4, 1);
  input_signal = [zeros(2,model_rank), input_signal, zeros(2,model_rank)]; % Nie bylismy pewni czy tutaj takze nalezalo poszerzac zerami wektor wejsciowy.
  % Obliczanie lokalnych ocen macierzy kowariancji.
  R = zeros(2, 2, model_rank+1);
  for k = 1:model_rank+1
    for i = 1:N-k
      R(:,:,k) = R(:,:,k) + input_signal(:,end-i+1)*input_signal(:,end-i-k+1)';
    endfor    
    R(:,:,k) = (1/N).*R(:,:,k);
  endfor 
  %%% Starting conditions 
  A = -R(:,:,2)*inv(R(:,:,1));
  % Taka struktura "macierzy" B wynika z koniecznosci jej obracania lecz z zachowaniem struktury pojedynczych komórek
  % do czego zwykly flip() nie starczal.
  B = zeros(2,2,model_rank);
  B(:,:,1) = -R(:,:,2)'*inv(R(:,:,1));
  Q = R(:,:,1) + A*R(:,:,2)';
  S = R(:,:,1) + B(:,:,1)*R(:,:,2);
  P = R(:,:,3) + A*R(:,:,2);
  for i = 1:model_rank-1
    Btemp = [];
    for j = 1:i
      Btemp = [B(:,:,j), Btemp];
    endfor    
    estimation = [eye(2), -P*inv(S); -P'*inv(Q), eye(2)]*[eye(2), A, zeros(2); zeros(2), Btemp, eye(2)];
    A = estimation(1:2,3:end);
    for j = 1:i+1
      B(:,:,j) = estimation(3:4,end-(j*2+1):end-(j*2));
    endfor
    Q = Q - P*inv(S)*P';
    S = S - P'*inv(Q)*P;
    Rtemp = zeros(i*2,2);
    if(i != model_rank-1)
        P = R(:,:,i+3);
      for j = 1:i+1
        P = P + A(:,(j-1)*2+1:j*2)*R(:,:,i+3-j);
      endfor
    endif    
  endfor    
  coefficients_estimate = [-A(1,:)'; -A(2,:)'];
endfunction