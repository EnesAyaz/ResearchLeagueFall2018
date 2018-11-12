
clc;
clear all;
%% Simulation Parameters
SampleTime = 1e-11; %Time Steps
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
x1B = linspace(0,-5,10000) ;%Ids
x1B1=-5*ones(1,a-10000);
x1B=[x1B x1B1];
x3B = zeros(size(t)); %Vdsin
x4B = zeros(size(t)); %Vgsin
x7B = zeros(size(t)); %Ig
u2B = zeros(size(t)); %Vdso
u1B= zeros(size(t)); %Vgso
x8=zeros(size(t)); %%Ich

%%
[~,n] = size(t);
for k=3:n
   
    [x8(k),x7B(k),x4B(k),x3B(k)] = StateSpaceGanCurrentInput(u1B(k),x1B(k),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
     u2B(k)= ((x1B(k)-x1B(k-1))/(SampleTime*(Ls+Ld))) + x3B(k)+ (x1B(k)*(Rs+Rd));
     
end
%%
figure(1);
hold all
grid on
plot(t,x1B,'Linewidth',2.0);
legend ('Ids');
hold off

figure(2);
hold all
grid on
plot(t,u2B,'Linewidth',2.0);
legend ('Vbias');
hold off

figure(3);
hold all
grid on
plot(t,x4B,t,x7B,'Linewidth',2.0);
legend ('Vgs','Ig');
hold off

figure(4);
hold all
grid on
plot(t,x3B,'Linewidth',2.0);
legend ('Vds');
hold off


figure(5);
hold all
grid on
plot(t,u1B,'Linewidth',2.0);
legend ('U1');
hold off


figure(6);
hold all
grid on
plot(t,x8,'Linewidth',2.0);
legend ('Ich');
hold off



