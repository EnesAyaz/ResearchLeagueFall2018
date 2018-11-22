% State Variables
% Id, Ig, Vgsin, Vdsin
%% State Space Model of GaN
% clear all;
% close all;

%% Simulation Parameters
SampleTime = 1e-13; %Time Steps
StopTime = 1000e-9; %Stop Time

%% Load Parameters
Rload = 10;
Lload = 40e-6;
fsw = 3e6;
Lp = 1e-10;
LdcP = 5e-9;
LdcN = 5e-9;
Ls=42e-12;
Ld=450e-12;
%%
Lgin = 0.65e-9;
Rss = 1e-3;
Lss = 0.43e-9;
Ls = 42e-12;
Rs = 3.6 * 0.238 * 0.82 * (1 - (-0.0135*(125 - 25))) / 295;
Ld = 450e-12;
Rd = (3.6/8) * (0.95*0.82*(1 - (-0.0135*(125 - 25))) * 18.2 / 295);



%% Input Definition
t = (0 : SampleTime : StopTime);
[u1T, u1B] = PulseTimer(t,fsw,SampleTime);
% plot(t,u1T,t,u1B);
%% Allocation
t = (0 : SampleTime : StopTime);

x1T = zeros(size(t)); %Ids
x3T = zeros(size(t)); %Vdsin
x4T = zeros(size(t)); %Vgsin
x7T = zeros(size(t)); %Ig
% u1T = zeros(size(t)); %Vgsso
u2T = zeros(size(t)); %Vdso

u = 100*ones(size(t)); %Vdc
Vload = zeros(size(t)); %Load Voltage
Iload = zeros(size(t)); %Load Current
Id=zeros(size(t)); %Diode Current

%% Bottom
x1B = zeros(size(t)); %Ids
x3B = zeros(size(t)); %Vdsin
x4B = zeros(size(t)); %Vgsin
x7B = zeros(size(t)); %Ig
% u1B = zeros(size(t)); %Vgsso
u2B = zeros(size(t)); %Vdso
u1B= zeros(size(t));

%% Calculation
[~,n] = size(t);
for k=3:(n-3)
    u2T(k)= u(k)-Vload(k);
    [x1T(k),x7T(k),x4T(k),x3T(k)] = StateSpaceGaNBlock(u1T(k),u2T(k),x1T(k-1),x7T(k-1),x4T(k-1),x3T(k-1),SampleTime);
    u2T(k+1)= x3T(k)+ ((x1T(k)- x1T(k-1))*(Ls+Ld)/SampleTime) +(x1T(k)* (Rs+Rd));
    Vload(k+1) = u2T(k+1)- u2B(k);
    Iload(k)= ((Iload(k-1)*Lload)+(Vload(k+1)*SampleTime))/( SampleTime*Rload+ Lload);
    x1B(k)= x1T(k)-Iload(k);
    [x7B(k),x4B(k),x3B(k)] = CurrentBlock(u1B(k),x1B(k),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
    u2B(k+1)= x3B(k)+ (x1B(k)- x1B(k-1))*(Ls+Ld)/SampleTime + x1B(k)* (Rs+Rd);
    Vload(k+1)=u2B(k+1);
   
end

%% Plot and See


figure;
hold all
grid on
plot(t,x1T,t,u2T,t,x7T,t,u1T,'Linewidth',2.0);
%xlim([0]);
ylim([-50 120]);
xlabel('Time');
ylabel('Voltage,Ampere');
title({'Top Switch Ids, Vds, Ig, Vgs'})
legend ('Ids','Vds','Ig','Vgs','Location','best');
hold off

figure;
hold all
grid on
plot(t,x1B,t,u2B,t,x7B,t,u1B,'Linewidth',2.0);
%xlim([0]);
ylim([-50 120]);
xlabel('Time');
ylabel('Voltage,Ampere');
title({'Bottom Switch Ids, Vds, Ig, Vgs'})
legend ('Ids','Vds','Ig','Vgs','Location','best');
hold off

figure;
hold all
grid on
plot(t,x1B,t,x1T,t,Iload,'Linewidth',2.0);
%xlim([0]);
ylim([-50 120]);
xlabel('Time');
ylabel('Voltage,Ampere');
title({'Bottom Switch Ids, Vds, Ig, Vgs'})
legend ('IdsB','IdsT','Il','Vgs','Location','best');
hold off

