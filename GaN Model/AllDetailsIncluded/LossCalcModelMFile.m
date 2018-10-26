%% Initial Configurations
clear all;
%% Device Parameters
Cgd = 1.748e-12;
Cgs = 160e-12;
Cds = 65.7e-12;

Ls = 62e-12;
Ld = 450e-12;
Lg = 0.65e-9;
Lss = 0.43e-9;

Rg = 1.5;
Rd = 1.1e-3;
Rs = 1.1e-3;
Rss = 1e-3;

Rt = (0.9*0.95*0.82*18.2/295 + 3.6*0.238*0.82/295);

%% Circuit Parasitics
Ldc = 3e-9;
Lground = 5e-9;

%% Gate Driver
Lgex = 3e-9;
Ron = 10;
Roff = 2;
%% Source parameters
PulseAmplitude = 6;
fsw = 2000e3;
Vdc = 400;
VpulseMax = 6;
VpulseMin = -3;
% Quantities in below are in percent
Dtop = 49; % duty cycle of top
Dbot = 49; % duty cycle of bot
DelayTop = 50;
DelayBot = 0;


%% Load parameters
LoadCurrent = 30;
Rload = (Vdc*Dtop/100)/LoadCurrent;
Lload = 40e-6;
Cload = 100e-6;

CurrRipple = (LoadCurrent*Rload)*(1-0.01*Dtop)/(fsw*Lload);
VoltRipple = CurrRipple/(8*fsw*Cload);
ReqTime = Lload*(CurrRipple/2)/(Vdc - (Vdc*(Dtop/100)-10)); %20 to compensate increase in output voltage
InitialCurrent = LoadCurrent + CurrRipple/2;
%% Run Simulink
SampleTime = 5e-13;
model = 'LossCalcModel';
load_system(model);
StopTime = ReqTime + 2.01/fsw;
StopTimeStr = num2str(StopTime);
set_param(model, 'StopTime','0.55e-6')
sim(model);
% 
% TopVoltDSCons = TopVoltDSCons + TopDSCurrCons*Rt;
% BotVoltDSCons = BotVoltDSCons + BotDSCurrCons*Rt;
% 
% TopVoltDSCap = TopVoltDSCap + TopDSCurrCap*Rt;
% BotVoltDSCap = BotVoltDSCap + BotDSCurrCap*Rt;
% 
% TopVoltDSInd = TopVoltDSInd + TopDSCurrInd*Rt;
% BotVoltDSInd = BotVoltDSInd + BotDSCurrInd*Rt;
% 
% TopVoltDSInd = TopVoltDSInd + TopDSCurrInd*Rt;
% BotVoltDSInd = BotVoltDSInd + BotDSCurrInd*Rt;

%% Plots
BotTurnOnMid = ReqTime;
BotTurnOffMid = ReqTime + Dbot/100/fsw;
TopTurnOnMid = ReqTime + DelayTop/100/fsw;
TopTurnOffMid = ReqTime + (DelayTop + Dtop)/100/fsw;
while((BotTurnOnMid + 1/(2*fsw))<StopTime)
    BotTurnOnMid = BotTurnOnMid + 1/2/fsw;
end
while((BotTurnOffMid + 1/(2*fsw))<StopTime)
    BotTurnOffMid = BotTurnOffMid + 1/2/fsw;
end
while((TopTurnOnMid+ 1/(2*fsw))<StopTime)
    TopTurnOnMid = TopTurnOnMid + 1/2/fsw;
end
while((TopTurnOffMid + 1/(2*fsw))<StopTime)
    TopTurnOffMid = TopTurnOffMid + 1/2/fsw;
end

Vgs = -10:1:6;
Vds = 0:0.1:475;
cur = 4.5057;
K = cur * 0.8 * (273/300)^(-2.7);
x0 = 0.31 ;
x1 = 0.255;
slp = 2;
f1 = figure('Name','Top Switch Turn On','units','normalized','outerposition',[0 0 1 1]);
f2 = figure('Name','Top Switch Turn Off','units','normalized','outerposition',[0 0 1 1]);
f3 = figure('Name','Bottom Switch Turn On','units','normalized','outerposition',[0 0 1 1]);
f4 = figure('Name','Bottom Switch Turn Off','units','normalized','outerposition',[0 0 1 1]);
Vds2 = 0;
for GateIndex = 1:17
    for i=1:((475/0.1)+1)
        GS = Vgs(GateIndex);
        DS = Vds(i);
        DS = DS - 0.9*0.95*0.82*18.2/295 - 3.6*0.238*0.82/295;
        GD = GS - DS;
        if Vds(i)>0
            I_top(GateIndex,i) = K*log(1+exp(26*(GS-1.7)/slp))*(DS)/(1+max((x0+x1*(GS+4.1)),0.2)*DS);
            Vds2(GateIndex,i) = Vds(i) + I_top(GateIndex,i)*(0.9*0.95*0.82*18.2/295 + 3.6*0.238*0.82/295);
        else
            I_top(GateIndex,i) = -K*log(1+exp(21*(GD-1.7)/slp))*(-DS)/(1+max((x0+x1*(GD+6.1)),0.2)*(-DS));
            Vds2(GateIndex,i) = Vds(i) + I_top(GateIndex,i)*(0.9*0.95*0.82*18.2/295 + 3.6*0.238*0.82/295);
        end
        
    end
end

figure(f1);
hold all
grid on
for j=[8,13,14,17]
    plot((Vds2(j,:)), I_top(j,:),'Linewidth',2.0);
    %plot((Vds),  I_top(j,:),'Linewidth',2.0);
end
xlim([0 415]);
ylim([0 60]);
xlabel('V_d_s(V)');
ylabel('I_c_h(A)');
title({'I_c_h vs V_d_s Curve of Top Switch During Turn ON'})
legend ('Vgs = -3','Vgs = 2','Vgs = 3','Vgs = 6','Location','northeast');
hold off

figure(f2);
hold all
grid on
for j=[8,13,14,17]
    plot((Vds2(j,:)),  I_top(j,:),'Linewidth',2.0);
end
xlim([0 465]);
ylim([0 50]);
xlabel('V_d_s(V)');
ylabel('I_c_h(A)');
title({'I_c_h vs V_d_s Curve of Top Switch During Turn OFF'})
legend ('Vgs = -3','Vgs = 2','Vgs = 3','Vgs = 6','Location','northeast');
hold off





drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );
Period = 1/fsw;
% Turn OFF for Top Switch
    TopTurnOffMid = 2.5*Period/SampleTime + 1 ;
    MarginOff = round(1*Period/100/SampleTime);
    ToffSampleBegin = TopTurnOffMid - MarginOff ;
    ToffSampleEnd   = TopTurnOffMid + MarginOff ;
    DurationTopOFF = ToffSampleEnd - ToffSampleBegin;
% Turn ON for Top Switch
    TopTurnOnMid = 2*Period/SampleTime + 1 ;
    MarginOn = round(2*Period/100/SampleTime);
    TonSampleBegin = TopTurnOnMid ;
    TonSampleEnd   = TopTurnOnMid + MarginOn + 12000;%0.48*Period/SampleTime;   
    DurationTopON = TonSampleEnd - TonSampleBegin; 
%Top Switch Plot

% Turn OFF Plot
%         InitI = TopCurrentDS(ToffSampleBegin);
%         InitV = TopVoltageDS(ToffSampleBegin);
%         EnergyTopOFF = 0;
%         TopOFFVI = zeros(1,2);
%         figure(f2)
%         hold all
%         for j=ToffSampleBegin:ToffSampleEnd
%             if abs(TopVoltageDS(j)-InitV) >= Vsens || abs(TopCurrentDS(j)-InitI) >= Isens
%                 X = [InitV TopVoltageDS(j)];
%                 Y = [InitI TopCurrentDS(j)];
%                 drawArrow(X,Y,'MaxHeadSize',150,'Color','b','LineWidth',2);
%                 InitV = TopVoltageDS(j);
%                 InitI = TopCurrentDS(j);
%             end
%             EnergyTopOFF = abs(TopVoltageDS(j) * TopCurrentDS(j)) * SampleTime + EnergyTopOFF;
%             TopOFFVI(j+1-ToffSampleBegin,:) = [TopVoltageDS(j),TopCurrentDS(j)];
%             EnergyTOFinst(j+1-ToffSampleBegin) = EnergyTopOFF;
%         end 
%         PowerTopOFF = EnergyTopOFF / Period;
%             plot(TopVoltageDS(ToffSampleBegin),TopCurrentDS(ToffSampleBegin),'*','Linewidth',10.0);
%             plot(TopVoltageDS(ToffSampleEnd),TopCurrentDS(ToffSampleEnd),'*','Linewidth',10.0);
%         hold off



InitI = TopDSCurrInd(ToffSampleBegin);
InitV = TopVoltDSInd(ToffSampleBegin);
figure(f2)
Isens = 2;
Vsens = 2;
hold all
for j=ToffSampleBegin:ToffSampleEnd
    if abs(TopVoltDSInd(j)-InitV) >= Vsens || abs(TopDSCurrInd(j)-InitI) >= Isens
        X = [InitV TopVoltDSInd(j)];
        Y = [InitI TopDSCurrInd(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','r','LineWidth',2);
        InitV = TopVoltDSInd(j);
        InitI = TopDSCurrInd(j);
    end
end 
    plot(TopVoltDSCap(ToffSampleBegin),TopDSCurrCap(ToffSampleBegin),'*','Linewidth',10.0);
    plot(TopVoltDSCap(ToffSampleEnd),TopDSCurrCap(ToffSampleEnd),'*','Linewidth',10.0);
    
Isens = 2;
Vsens = 2;
InitI = TopDSCurrCap(ToffSampleBegin);
InitV = TopVoltDSCap(ToffSampleBegin);
for j=ToffSampleBegin:ToffSampleEnd
    if abs(TopVoltDSCap(j)-InitV) >= Vsens || abs(TopDSCurrCap(j)-InitI) >= Isens
        X = [InitV TopVoltDSCap(j)];
        Y = [InitI TopDSCurrCap(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','b','LineWidth',2);
        InitV = TopVoltDSCap(j);
        InitI = TopDSCurrCap(j);
    end
end 

Isens = 2;
Vsens = 2;
InitI = TopDSCurrCons(ToffSampleBegin);
InitV = TopVoltDSCons(ToffSampleBegin);
for j=ToffSampleBegin:ToffSampleEnd
    if abs(TopVoltDSCons(j)-InitV) >= Vsens || abs(TopDSCurrCons(j)-InitI) >= Isens
        X = [InitV TopVoltDSCons(j)];
        Y = [InitI TopDSCurrCons(j)];
        drawArrow(X,Y,'MaxHeadSize',150,'Color','k','LineWidth',2);
        InitV = TopVoltDSCons(j);
        InitI = TopDSCurrCons(j);
    end
end 
hold off



% Turn ON Plot
Isens = 2;
Vsens = 2;
% Drain-Source Current PLOT
%         InitI = TopCurrentDS(TonSampleBegin);
%         InitV = TopVoltageDS(TonSampleBegin);
%         EnergyTopON = 0;
%         TopONVI = zeros(1,2);
%         figure(f1)
%         hold all
%         for j=TonSampleBegin:TonSampleEnd
%             if abs(TopVoltageDS(j)-InitV) >= Vsens || abs(TopCurrentDS(j)-InitI) >= Isens
%                 X = [InitV TopVoltageDS(j)];
%                 Y = [InitI TopCurrentDS(j)];
%                 drawArrow(X,Y,'MaxHeadSize',150,'Color','b','LineWidth',2);
%                 InitV = TopVoltageDS(j);
%                 InitI = TopCurrentDS(j);
%             end
%             EnergyTopON = abs(TopVoltageDS(j) * TopCurrentDS(j)) * SampleTime + EnergyTopON;
%             TopONVI(j+1-TonSampleBegin,:) = [TopVoltageDS(j),TopCurrentDS(j)];
%             EnergyTONinst(j+1-TonSampleBegin) = EnergyTopON;
%         end 
%         PowerTopON = EnergyTopON / Period;
%             plot(TopVoltageDS(TonSampleBegin),TopCurrentDS(TonSampleBegin),'*','Linewidth',10.0);
%             plot(TopVoltageDS(TonSampleEnd),TopCurrentDS(TonSampleEnd),'*','Linewidth',10.0);
%         hold off;

InitI = TopDSCurrInd(TonSampleBegin);
InitV = TopVoltDSInd(TonSampleBegin);
figure(f1)
hold all
for j=TonSampleBegin:TonSampleEnd
    if abs(TopVoltDSInd(j)-InitV) >= Vsens || abs(TopDSCurrInd(j)-InitI) >= Isens
        X = [InitV TopVoltDSInd(j)];
        Y = [InitI TopDSCurrInd(j)];
        drawArrow(X,Y,'MaxHeadSize',1000,'Color','r','LineWidth',2);
        InitV = TopVoltDSInd(j);
        InitI = TopDSCurrInd(j);
    end
    if InitV<20
        Vsens = 0.5;
        Isens = 0.5;
    elseif InitV<5
        Vsens = 0.1;
        Isens = 0.1;
    end
       
end 
    plot(TopVoltDSCap(TonSampleBegin),TopDSCurrCap(TonSampleBegin),'*','Linewidth',10.0);
    plot(TopVoltDSCap(TonSampleEnd),TopDSCurrCap(TonSampleEnd),'*','Linewidth',10.0);
    
Isens = 2;
Vsens = 2;
InitI = TopDSCurrCap(TonSampleBegin);
InitV = TopVoltDSCap(TonSampleBegin);
for j=TonSampleBegin:TonSampleEnd
    if abs(TopVoltDSCap(j)-InitV) >= Vsens || abs(TopDSCurrCap(j)-InitI) >= Isens
        X = [InitV TopVoltDSCap(j)];
        Y = [InitI TopDSCurrCap(j)];
        drawArrow(X,Y,'MaxHeadSize',1000,'Color','b','LineWidth',2);
        InitV = TopVoltDSCap(j);
        InitI = TopDSCurrCap(j);
    end
    if InitV<20
        Vsens = 0.5;
        Isens = 0.5;
    elseif InitV<5
        Vsens = 0.1;
        Isens = 0.1;
    end
       
end 

InitI = TopDSCurrCons(TonSampleBegin);
InitV = TopVoltDSCons(TonSampleBegin);
Isens = 2;
Vsens = 2;
for j=TonSampleBegin:TonSampleEnd
    if abs(TopVoltDSCons(j)-InitV) >= Vsens || abs(TopDSCurrCons(j)-InitI) >= Isens
        X = [InitV TopVoltDSCons(j)];
        Y = [InitI TopDSCurrCons(j)];
        drawArrow(X,Y,'MaxHeadSize',1000,'Color','k','LineWidth',2);
        InitV = TopVoltDSCons(j);
        InitI = TopDSCurrCons(j);
    end
    if InitV<20
        Vsens = 0.5;
        Isens = 0.5;
    elseif InitV<5
        Vsens = 0.1;
        Isens = 0.1;
    end
       
end 
hold off;




%Bot Switch Plot
Isens = 0.5;
Vsens = 0.5;
% Turn OFF for Bottom Switch
    BotTurnOffMid = 2*Period/SampleTime + 1 ;
    MarginOff = round(Period/100/SampleTime);
    ToffSampleBegin = BotTurnOffMid - MarginOff;
    ToffSampleEnd   = BotTurnOffMid + MarginOff + 36000;
    DurationBotOFF = ToffSampleEnd - ToffSampleBegin;
% Turn ON for Bottom Switch
    BotTurnOnMid = 2.5*Period/SampleTime + 1 ;
    MarginOn = round(2.5*Period/100/SampleTime);
    TonSampleBegin = BotTurnOnMid - MarginOn;
    TonSampleEnd   = BotTurnOnMid + MarginOn;%0.48*Period/SampleTime;  
    DurationBotON = TonSampleEnd - TonSampleBegin;
Vds = -15:0.1:400;
Vds2 = 0;
for GateIndex = 1:17
    for i=1:((415/0.1)+1)
        GS = Vgs(GateIndex);
        DS = Vds(i);
        GD = GS - DS;
        if Vds(i)>0
            I_bottom(GateIndex,i) = K*log(1+exp(26*(GS-1.7)/slp))*(DS)/(1+max((x0+x1*(GS+4.1)),0.2)*DS);
        else
            I_bottom(GateIndex,i) = -K*log(1+exp(21*(GD-1.7)/slp))*(-DS)/(1+max((x0+x1*(GD+6.1)),0.2)*(-DS));
        end
        Vds2(GateIndex,i) = Vds(i) + I_bottom(GateIndex,i)*(0.9*0.95*0.82*18.2/295 + 3.6*0.238*0.82/295);
    end
end


figure(f3);
hold all
grid on
for j=[1,5,17]
    plot((Vds2(j,:)),  I_bottom(j,:),'Linewidth',2.0);
end
xlim([-25 420]);
ylim([-30 30]);
xlabel('V_d_s(V)');
ylabel('I_c_h(A)');
title({'I_c_h vs V_d_s Curve of Bottom Switch during Turn ON'})
legend ('Vgs = -10','Vgs = -6','Vgs = 6','Location','southeast');
hold off

figure(f4);
hold all
grid minor
for j=[5,8,17]
   plot((Vds2(j,:)),  I_bottom(j,:),'Linewidth',2.0);
end
xlim([-25 420]);
ylim([-30 30]);
xlabel('V_d_s(V)');
ylabel('I_c_h(A)');
title({'I_c_h vs V_d_s Curve of Bottom Switch during Turn OFF'})
legend ('Vgs = -6','Vgs = -3','Vgs = 6','Location','southeast');
hold off

% Turn ON Plot
% Drain-Source Current Plot
%         InitI = BotCurrentDS(TonSampleBegin);
%         InitV = BotVoltageDS(TonSampleBegin);
%         EnergyBotON = 0;
%         BotONVI = zeros(1,2);
%         figure(f3)
%         hold all
%         for j=TonSampleBegin:TonSampleEnd
%             if abs(BotVoltageDS(j)-InitV) >= Vsens || abs(BotCurrentDS(j)-InitI) >= Isens
%                 X = [InitV BotVoltageDS(j)];
%                 Y = [InitI BotCurrentDS(j)];
%                 drawArrow(X,Y,'MaxHeadSize',20,'Color','b','LineWidth',2);
%                 InitV = BotVoltageDS(j);
%                 InitI = BotCurrentDS(j);
%             end
%             EnergyBotON = abs(BotVoltageDS(j) * BotCurrentDS(j)) * SampleTime + EnergyBotON;
%             BotONVI(j+1-TonSampleBegin,:) = [BotVoltageDS(j),BotCurrentDS(j)];
%             EnergyBONinst(j+1-TonSampleBegin) = EnergyBotON;
%         end      
%         PowerBotON = EnergyBotON / Period;
%         plot(BotVoltageDS(TonSampleBegin),BotCurrentDS(TonSampleBegin),'*','Linewidth',10.0);
%         plot(BotVoltageDS(TonSampleEnd),BotCurrentDS(TonSampleEnd),'*','Linewidth',10.0);
%         hold off

InitI = BotDSCurrInd(TonSampleBegin);
InitV = BotVoltDSInd(TonSampleBegin);
figure(f3)
hold all
for j=TonSampleBegin:(TonSampleEnd-10000)
    if abs(BotVoltDSInd(j)-InitV) >= Vsens || abs(BotDSCurrInd(j)-InitI) >= Isens
        X = [InitV BotVoltDSInd(j)];
        Y = [InitI BotDSCurrInd(j)];
        drawArrow(X,Y,'MaxHeadSize',0,'Color','r','LineWidth',2);
        InitV = BotVoltDSInd(j);
        InitI = BotDSCurrInd(j);
    end
end 
    plot(BotVoltDSInd(TonSampleBegin),BotDSCurrInd(TonSampleBegin),'*','Linewidth',10.0);
    plot(BotVoltDSInd(TonSampleEnd),BotDSCurrInd(TonSampleEnd),'*','Linewidth',10.0);
    
InitI = BotDSCurrCap(TonSampleBegin);
InitV = BotVoltDSCap(TonSampleBegin);
for j=(TonSampleBegin+5000):TonSampleEnd
    if abs(BotVoltDSCap(j)-InitV) >= Vsens || abs(BotDSCurrCap(j)-InitI) >= Isens
        X = [InitV BotVoltDSCap(j)];
        Y = [InitI BotDSCurrCap(j)];
        drawArrow(X,Y,'MaxHeadSize',0,'Color','b','LineWidth',2);
        InitV = BotVoltDSCap(j);
        InitI = BotDSCurrCap(j);
    end
end 

InitI = BotDSCurrCons(TonSampleBegin);
InitV = BotVoltDSCons(TonSampleBegin);
for j=TonSampleBegin:TonSampleEnd
    if abs(BotVoltDSCons(j)-InitV) >= Vsens || abs(BotDSCurrCons(j)-InitI) >= Isens
        X = [InitV BotVoltDSCons(j)];
        Y = [InitI BotDSCurrCons(j)];
        drawArrow(X,Y,'MaxHeadSize',0,'Color','k','LineWidth',2);
        InitV = BotVoltDSCons(j);
        InitI = BotDSCurrCons(j);
    end
end 
hold off
% Turn OFF Plot
% Drain Source Current Plot
%         InitI = BotCurrentDS(ToffSampleBegin);
%         InitV = BotVoltageDS(ToffSampleBegin);
%         EnergyBotOFF = 0;
%         BotOFFVI = zeros(1,2);
%         figure(f4)
%         hold all
%         for j=ToffSampleBegin:ToffSampleEnd
%             if abs(BotVoltageDS(j)-InitV) >= Vsens || abs(BotCurrentDS(j)-InitI) >= Isens
%                 X = [InitV BotVoltageDS(j)];
%                 Y = [InitI BotCurrentDS(j)];
%                 drawArrow(X,Y,'MaxHeadSize',20,'Color','b','LineWidth',2);
%                 InitV = BotVoltageDS(j);
%                 InitI = BotCurrentDS(j);
%             end
%             EnergyBotOFF = abs(BotVoltageDS(j) * BotCurrentDS(j)) * SampleTime + EnergyBotOFF;
%             BotOFFVI(j+1-ToffSampleBegin,:) = [BotVoltageDS(j),BotCurrentDS(j)];
%             EnergyBOFinst(j+1-ToffSampleBegin) = EnergyBotOFF;
%         end
%         PowerBotOFF = EnergyBotOFF / Period;
%         plot(BotVoltageDS(ToffSampleBegin),BotCurrentDS(ToffSampleBegin),'*','Linewidth',10.0);
%         plot(BotVoltageDS(ToffSampleEnd),BotCurrentDS(ToffSampleEnd),'*','Linewidth',10.0);
%         hold off
Isens = 1;
Vsens = 1;
InitI = BotDSCurrInd(ToffSampleBegin);
InitV = BotVoltDSInd(ToffSampleBegin);
figure(f4)
hold all
for j=ToffSampleBegin:(ToffSampleEnd)
    if abs(BotVoltDSInd(j)-InitV) >= Vsens || abs(BotDSCurrInd(j)-InitI) >= Isens
        X = [InitV BotVoltDSInd(j)];
        Y = [InitI BotDSCurrInd(j)];
        drawArrow(X,Y,'MaxHeadSize',0,'Color','r','LineWidth',2);
        InitV = BotVoltDSInd(j);
        InitI = BotDSCurrInd(j);
    end
end
plot(BotVoltDSInd(ToffSampleBegin),BotDSCurrInd(ToffSampleBegin),'*','Linewidth',10.0);
plot(BotVoltDSInd(ToffSampleEnd),BotDSCurrInd(ToffSampleEnd),'*','Linewidth',10.0);

Isens = 1;
Vsens = 0.5;
InitI = BotDSCurrCap(ToffSampleBegin);
InitV = BotVoltDSCap(ToffSampleBegin);
for j=ToffSampleBegin:(ToffSampleEnd)
    if abs(BotVoltDSCap(j)-InitV) >= Vsens || abs(BotDSCurrCap(j)-InitI) >= Isens
        X = [InitV BotVoltDSCap(j)];
        Y = [InitI BotDSCurrCap(j)];
        drawArrow(X,Y,'MaxHeadSize',0,'Color','b','LineWidth',2);
        InitV = BotVoltDSCap(j);
        InitI = BotDSCurrCap(j);
    end
end

InitI = BotDSCurrCons(ToffSampleBegin);
InitV = BotVoltDSCons(ToffSampleBegin);
for j=ToffSampleBegin:(ToffSampleEnd)
    if abs(BotVoltDSCons(j)-InitV) >= Vsens || abs(BotDSCurrCons(j)-InitI) >= Isens
        X = [InitV BotVoltDSCons(j)];
        Y = [InitI BotDSCurrCons(j)];
        drawArrow(X,Y,'MaxHeadSize',0,'Color','k','LineWidth',2);
        InitV = BotVoltDSCons(j);
        InitI = BotDSCurrCons(j);
    end
end
hold off

%%
%Print to Screen
fprintf('//////////////////////////////////////////////////////////////////////////////////////// \n');
fprintf('---------------------------------------------------------------------------------------- \n');
fprintf('Results of STANDART Calculation \n');
fprintf('Energy Top ON: %f \n', EnergyTopON);
fprintf('Power Top ON: %f \n', PowerTopON);
fprintf('Energy Top OFF: %f \n', EnergyTopOFF);
fprintf('Power Top OFF: %f \n', PowerTopOFF);
fprintf('Energy Bot ON: %f \n', EnergyBotON);
fprintf('Power Bot ON: %f \n', PowerBotON);
fprintf('Energy Bot OFF: %f \n', EnergyBotOFF);
fprintf('Power Bot OFF: %f \n', PowerBotOFF);
fprintf('\n');
fprintf('---------------------------------------------------------------------------------------- \n');
fprintf('Area Calculations\n');
%---------------------
X = BotONVI(:,1);
Y = BotONVI(:,2);
Size = size(X);
Xsize = Size(1);
integ1 = 0;
InstPower = 0;
figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:Xsize - 1
    deltaX = (X(Xsize) - X(1))/Xsize;
    deltaY = Y(i);
    integ1(i+1) = integ1(i) + abs(deltaX*deltaY);
    InstPower(i) = abs(deltaX*deltaY);
end
subplot(2,2,3);
plot((1:Xsize)*SampleTime,integ1,(1:Xsize)*SampleTime,X,(1:Xsize)*SampleTime,Y,(1:Xsize)*SampleTime,10*EnergyBONinst*fsw,'Linewidth',2.0);
title('Bot ON switching energy and instantenous power');
legend('Inst. Power AREA calc.','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaBotON = integ1(Xsize-1);
fprintf('Bottom ON Area: %f \n', AreaBotON );
%---------------------
X1 = BotOFFVI(:,1);
Y1 = BotOFFVI(:,2);
Size = size(X1);
Xsize1 = Size(1);
integ2 = 0;
InstPower = 0;
for i = 1:Xsize1 - 1
    deltaX1 = (X1(Xsize1) - X1(1))/Xsize1;
    deltaY1 = Y1(i);
    integ2(i+1) = integ2(i) + abs(deltaX1*deltaY1);
    InstPower(i) = abs(deltaX1*deltaY1);
end
subplot(2,2,4);
plot((1:Xsize1)*SampleTime,integ2,(1:Xsize1)*SampleTime,X1,(1:Xsize1)*SampleTime,Y1,(1:Xsize1)*SampleTime,10*EnergyBOFinst*fsw,'Linewidth',2.0);
title('Bot OFF switching energy and instantenous power');
legend('Inst. Power AREA calc.','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaBotOFF = integ2(Xsize1);
fprintf('Bottom OFF Area: %f \n', AreaBotOFF);
%---------------------
X2 = TopONVI(:,1);
Y2 = TopONVI(:,2);
Size = size(X2);
Xsize2 = Size(1);
integ3 = 0;
InstPower = 0;
for i = 1:Xsize2 - 1
    deltaX2 = (X2(Xsize2) - X2(1))/Xsize2;
    deltaY2 = Y2(i);
    integ3(i+1) = integ3(i) + abs(deltaX2*deltaY2);
    InstPower(i) = abs(deltaX2*deltaY2);
end
subplot(2,2,1);
plot((1:Xsize2)*SampleTime,integ3/100,(1:Xsize2)*SampleTime,X2,(1:Xsize2)*SampleTime,Y2,(1:Xsize2)*SampleTime,10*EnergyTONinst*fsw,'Linewidth',2.0);
title('Top ON switching energy and instantenous power');
legend('Inst. Power AREA calc.(/100)','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaTopON = integ3(Xsize2);
fprintf('Top ON Area: %f \n', AreaTopON);
%---------------------
X3 = TopOFFVI(:,1);
Y3 = TopOFFVI(:,2);
Size = size(X3);
Xsize3 = Size(1);
integ4 = 0;
InstPower = 0;
for i = 1:Xsize3 - 1
    deltaX3 = (X3(Xsize3) - X3(1))/Xsize3;
    deltaY3 = Y3(i);
    integ4(i+1) = integ4(i) + abs(deltaX3*deltaY3);
    InstPower(i) = abs(deltaX3*deltaY3);
end
subplot(2,2,2);
plot((1:Xsize3)*SampleTime,integ4,(1:Xsize3)*SampleTime,X3,(1:Xsize3)*SampleTime,Y3,(1:Xsize3)*SampleTime,10*EnergyTOFinst*fsw,'Linewidth',2.0);
title('Top OFF switching energy and instantenous power');
legend('Inst. Power AREA calc.','Voltage','Current','Power Cons. up to now IV calc.(x10) ');
AreaTopOFF = integ4(Xsize3);
fprintf('Top OFF Area: %f \n', AreaTopOFF);
%---------------------
fprintf('\n');
fprintf('---------------------------------------------------------------------------------------- \n');
fprintf('Results with AREA Calculation \n');
fprintf('Energy Top ON: %f \n', DurationTopON * SampleTime * AreaTopON);
fprintf('Power Top ON: %f \n', DurationTopON * SampleTime * AreaTopON / Period);
fprintf('Energy Top ON: %f \n', DurationTopOFF * SampleTime * AreaTopOFF);
fprintf('Power Top OFF: %f \n', DurationTopOFF * SampleTime * AreaTopOFF / Period);
fprintf('Energy Bot ON: %f \n', DurationBotON * SampleTime * AreaBotON);
fprintf('Power Bot ON: %f \n', DurationBotON * SampleTime * AreaBotON / Period);
fprintf('Energy Bot OFF: %f \n', DurationBotOFF * SampleTime * AreaBotOFF);
fprintf('Power Bot OFF: %f \n', DurationBotOFF * SampleTime * AreaBotOFF / Period);



