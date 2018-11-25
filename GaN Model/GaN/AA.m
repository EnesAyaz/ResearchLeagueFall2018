%%
figure;
hold all;
grid on;
plot(t,x1);
xlabel('Time');
ylabel('Ampere');
title('Ids');
hold off;
%%
figure;
hold all;
grid on;
plot(t,u2,t,x3);
xlabel('Time');
ylabel('voltage');
title('Vds and Vdsin');
legend('Vds', 'Vdsin');
hold off;
%%
figure;
hold all;
grid on;
plot(t,x7);
xlabel('Time');
ylabel('Current');
title('Ig');
hold off;
%%
figure;
hold all;
grid on;
plot(t,u1,t,x4);
xlabel('Time');
ylabel('Voltage');
title('Vgs and Vgsin');
legend('Vgs', 'Vgsin');
hold off;
