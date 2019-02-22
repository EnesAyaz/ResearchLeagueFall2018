Id=[];
leg=[];
for Vgs=-3:3:6
    
    Id=[];
    for Vds=-5:0.2:5
      
        
    
    [Ich,Cgd,Cgs,Cds] = NumericCalc(Vgs,Vds);
    Id=[Id;Ich];
    
    
    end
    
    if Vgs == -3
    color = [ 0 1 0];
    elseif Vgs == 0
    color = [1 0 1];
    elseif Vgs == 3
    color = [0 0 1];
    elseif Vgs == 6
    color = [1 0 0];
    end

    
    Vds= -5:0.2:5;
    figure(1);
    title( 'Static Characterization of GaN')
    plot(Vds,Id,'Color',color,'LineWidth',3);
    hold on;  
    title('Drain Voltage vs Channel Current with Different Gate Voltage');
    xlabel('Drain Voltage(V)');
    ylabel('Channel Voltage Current(A)');
    
    str ='Vgs='+string(Vgs)
    leg=[leg ,str ];

end

legend(leg)
