Fs=1000; % 1 khz
L=8187; % length of signal

Y = fft(simout.data);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(f,P1) 

