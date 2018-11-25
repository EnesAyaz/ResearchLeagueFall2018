clc;
clear all;
close all;
%% Simulation Parameters
SampleTime = 1e-13; %Time Steps
StopTime = 1000e-9; %Stop Time
fsw = 3e6;
t = (0 : SampleTime : StopTime);
t=t(1,1:end-1);
Ls=42e-12;
Ld=450e-12;
Rs = 3.6 * 0.238 * 0.82 * (1 - (-0.0135*(125 - 25))) / 295;
Rd = (3.6/8) * (0.95*0.82*(1 - (-0.0135*(125 - 25))) * 18.2 / 295);
%%
[u1T, u1B] = PulseTimer(t,fsw,SampleTime);
%%
a=length(t);
u2CB = linspace(0,-3,10000) ;%Ids
u2B1=-3*ones(1,a-10000);
u2CB=[u2CB u2B1]; % Ids
x3B = zeros(size(t)); %Vdsin
x4B = zeros(size(t)); %Vgsin
x7B = zeros(size(t)); %Ig
Vdsout = zeros(size(t));
x8=zeros(size(t)); %%Ich
%u1B= zeros(size(t)); %Vgso
%%u1B= 3*ones(size(t)); %Vgso
% u1B(t>50e-9)=-3;
%u1B(t>=200e-9) = -3;

%%
[~,n] = size(t);
for k=3:n
   
    [x8(k),x7B(k),x4B(k),x3B(k)] = StateSpaceGanCurrentInput(u1B(k),u2CB(k),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
     Vdsout(k)= ((u2CB(k)-u2CB(k-1))/(SampleTime/(Ls+Ld))) + x3B(k)+ (u2CB(k)*(Rs+Rd));
     
end
%%
figure ;

subplot(2,2,1);
hold all
grid on
plot(t,u2CB','Linewidth',2.0);
title('Ids')
legend ('Ids');
hold off


subplot(2,2,2);
hold all
grid on
plot(t,x4B,t,x7B,t,u1B,'Linewidth',2.0);
title('Vgsin,Vgsout and Ig')
legend ('Vgs','Ig','Vgsout');
hold off

subplot(2,2,3);
hold all
grid on
plot(t,x3B,'Linewidth',2.0);
legend ('Vdsin');
hold off



subplot(2,2,4);
hold all
grid on
plot(t,x8,'Linewidth',2.0);
legend ('Ich');
hold off

suptitle(' Vgs switching and Ids negative');


