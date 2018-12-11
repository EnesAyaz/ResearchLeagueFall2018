% State Variables
% Id, Ig, Vgsin, Vdsin
%% State Space Model of GaN
clear all;
close all;

%% Simulation Parameters
SampleTime = 1e-12; %Time Steps
StopTime = 400e-9; %Stop Time

%% Load Parameters
Rload = 100;
Lload = 4e-6;
Cload=1e-12;
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
figure;
plot(t,u1T,t,u1B);
legend('U1','U2');
ylim([-6 10])
%% Allocation
t = (0 : SampleTime : StopTime);

x1T = zeros(size(t)); %Ids
x3T = zeros(size(t)); %Vdsin
x4T =-3*ones(size(t)); %Vgsin
x7T = zeros(size(t)); %Ig
% u1T = zeros(size(t)); %Vgsso
u2T = zeros(size(t)); %Vdso

% u = linspace(0,1,10000);%Vdc
% u=[u, 1*ones(1,length(t-10000))];
u= 100*ones(size(t));
Vload = zeros(size(t)); %Load Voltage
Iload = zeros(size(t)); %Load Current

%% Bottom
x1B = zeros(size(t)); %Ids
x3B = ones(size(t)); %Vdsin
x4B = -3*ones(size(t)); %Vgsin
x7B = zeros(size(t)); %Ig
% u1B = zeros(size(t)); %Vgsso
u2B = zeros(size(t)); %Vdso
x8=zeros(size(t)); %%Ich
%u1B= zeros(size(t));

%% Calculation
[~,n] = size(t);
for k=3:(n-3)
  u2T(k)= u(k)- u2B(k-1);
  [x1T(k),x7T(k),x4T(k),x3T(k)] = StateSpaceGaNBlock(u1T(k),u2T(k),x1T(k-1),x7T(k-1),x4T(k-1),x3T(k-1),SampleTime);
  x1B(k)=x1T(k)-Iload(k-1);
  [x8(k),x7B(k),x4B(k),x3B(k)] = StateSpaceGanCurrentInput(u1B(k),x1B(k),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
  u2B(k)= x3B(k)+ (x1B(k)- x1B(k-1))*(Ls+Ld)/SampleTime + x1B(k)* (Rs+Rd);
  Iload(k)= ((Iload(k-1))*(Lload/SampleTime)+ u2B(k))/( Rload+ Lload/SampleTime);
  Vload(k)=u2B(k);
  
  

end
%%
%      [x1T(k),x7T(k),x4T(k),x3T(k)] = StateSpaceGaNBlock(u1T(k),u2T(k),x1T(k-1),x7T(k-1),x4T(k-1),x3T(k-1),SampleTime);
%      
%          u2T(k)= (x1T(k)*(Rd+Rs) )+ (((x1T(k)-x1T(k-1))/SampleTime)*(Ls+Ld))+ x3T(k);
%     Vload(k)=u(k)-u2T(k);
%     Iload(k)= (SampleTime*Vload(k)/Lload+ Iload(k-1))/(((SampleTime*Rload)/Lload)+1);
%     x1B(k)=x1T(k)-Iload(k);
%     [x8(k),x7B(k),x4B(k),x3B(k)] = StateSpaceGanCurrentInput(u1B(k),x1B(k),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
%     u2B(k)= x3B(k)+ (x1B(k)- x1B(k-1))*(Ls+Ld)/SampleTime + x1B(k)* (Rs+Rd);

 %%    
%      Vload(k)=Vload(k-1)+ (x1T(k)*SampleTime)/Cload;
    
    
    % Vload(k)=((Lload*(x1T(k)-x1T(k-1))/SampleTime) + ((Lload/Rload)*Vload(k-1)))/ (1+Lload/Rload);
    
    %% voltage
%     Iload(k)=x1T(k)-x1B(k-1);
%     Vload(k)= Iload(k)*Rload+ ((Iload(k)-Iload(k-1))*Lload)/SampleTime;
%     u2B(k)=Vload(k);
%     [x1B(k),x7B(k),x4B(k),x3B(k)] = StateSpaceGaNBlock(u1B(k),u2B(k),x1B(k-1),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
    
    %% voltage
    
%    u2T(k)= u(k)-u2B(k-1);
%         u2T(k)=u(k)-u2B(k-1);
% %       u2T(k)=u(k);
%         [x1T(k),x7T(k),x4T(k),x3T(k)] = StateSpaceGaNBlock(u1T(k),u2T(k),x1T(k-1),x7T(k-1),x4T(k-1),x3T(k-1),SampleTime);
%         u2T(k)= (x1T(k)*(Rd+Rs) )+ (((x1T(k)-x1T(k-1))/SampleTime)*(Ls+Ld))+ x3T(k);
%         u2B(k)=u(k)-u2T(k);
%         [x1B(k),x7B(k),x4B(k),x3B(k)] = StateSpaceGaNBlock(u1B(k),u2B(k),x1B(k-1),x7B(k-1),x4B(k-1),x3B(k-1),SampleTime);
%         Iload(k)=x1T(k)-x1B(k);
%         Vload(k)= Iload(k)*Rload+ ((Iload(k)-Iload(k-1))*Lload)/SampleTime;
%         u2B(k)=Vload(k);
   


%% Plot and See

% 
% figure;
% hold all
% grid on
% plot(t,x1T,'Linewidth',2.0);
% %xlim([0]);
% %ylim([-50 120]);
% xlabel('Time');
% ylabel('Voltage,Ampere');
% title({'Top Switch Ids, Vds '})
% legend ('IdsT','VdsT','Location','best');
% hold off

% figure;
% hold all
% grid on
% plot(t,u2B,'Linewidth',2.0);
% %xlim([0]);
% %ylim([-50 120]);
% xlabel('Time');
% ylabel('Voltage,Ampere');
% title({'Bottom Switch Ids, Vds '})
% legend ('IdsB','VdsB','Location','best');
% hold off

%%
figure;
hold on;
plot(t,x1T,t,u2T,t,Vload','Linewidth',2.0);
legend ('IdsT','VdsT','Vload');

hold off


%%

figure;
hold on;
plot(t, u2T,'Linewidth',2.0);
legend ('u2');

hold off
%%

figure;
hold all
grid on
plot(t,x1B,t,x4B,t,Iload,'Linewidth',2.0);
%xlim([0]);
ylim([-20 20]);
xlabel('Time');
ylabel('Voltage,Ampere');
title({'Bottom Switch Ids, Vds, Ig, Vgs'})
legend ('IdsB','IdsT','Il','Vgs','Location','best');
hold off

