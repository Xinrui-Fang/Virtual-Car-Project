%% Control_result.m


%% 1.Initialize

close all 
clear 
clc 

%-----------------%
 %figure setting%
%------------------%
lineWidth = 1.5;
fontName ='Times New Roman';
fontSize = 24;

controll_datanumber = 25;%Number of experimental data with PML
uncontroll_datanumber = 25;%Number of experimental data without PML

%% 2.Parameter

%-----------------%
      %Time%
%------------------%
ts = 0.02;%sampling time in Unity
ts2 = 0.2;
T = 15;
NT = T/ts;

%-----------------%
    %Vehicle%
%------------------%
T_plant = 0.25;
umax = 4;
L = 4;

%% 3.Extraction of experimental data

RMSE_with = [];
V_with = [];
V_pml = [];
V_pml_neo = [];
Cut_hozon = [];
Sparse = [];

list = dir('*.csv');

for o = 1:controll_datanumber

    F = readmatrix(list(o).name);
    [Row Col] = size(F);
    t = F(:,1)*ts;
    a = F(:,2);
    v = F(:,3);
    v_pre = F(:,4);
    v_pml = F(:,5);
    
    N = Row;
    
    %----------------------%
     %Various calibrations%
    %----------------------%
    %z0
    z = [];
    z_t = 0;
    for i = 1:N
        z = [z;z_t];
        z_t = z_t + v(i)*ts*1000/3600;
    end
    
    N_identify=0;%Identification start time
    i=1;
    while i<N
        N_identify = N_identify + 1;
        if v_pre(i) == 80
            break
        end
        i=i+1;
    end

    N_pml_end = N_identify;
    while N_pml_end <= Row
        if v(N_pml_end) >= 80
            break
        end
        N_pml_end = N_pml_end+1;
    end
    v_pml(N_pml_end:N) = zeros(N-N_pml_end+1,1);
    v_pml = v_pml(N_identify:N_identify+NT);
    V_pml = [V_pml v_pml];
    v_pml_neo = [v_pml(1)];
    t_ts02 = [0];
    for q = 1:NT
        if mod(q,ts2/ts) == 0
            v_pml_neo = [v_pml_neo;v_pml(q)];
        end
    end
    for q = 1:T/ts2
        t_ts02 = [t_ts02;ts2*q];
    end
    V_pml_neo = [V_pml_neo v_pml_neo];
    i_off = 0;
    i = 1;
    while i <= N
        if V_pml_neo(i,o) == 0
            i_off = i-1;
            break
        end
        i = i+1;
    end
    Cut_hozon = [Cut_hozon i_off];
    sparsecount = 0;
    for i = 2:i_off
        if abs(V_pml_neo(i)-V_pml_neo(i-1)) <= 1*ts2
            sparsecount = sparsecount + 1;
        end
    end
    Sparse = [Sparse sparsecount/(i_off-1)];
    
    %z0
    z_pre_t = 10;
    z_pre = [];
    for j = 1:N
        z_pre = [z_pre;z_pre_t];
        z_pre_t = z_pre_t + v_pre(j)*ts*1000/3600;
    end
    
    %z0-z,v0-v
    z_relative = z_pre - z;
    v_relative = v_pre(1:N) - v(1:N);
    
    %parameter
    l_pre = 1.4;%[m]
    
    % RMSE
    v_dif = v_pre - v;
    v_dif = v_dif(N_identify:N);
    [Rowd, Cold] = size(v_dif);
    RMSE = 0;
    for j = 1:NT+1
        RMSE = RMSE + v_dif(j)^2;
    end
    RMSE = sqrt(RMSE/(T/ts + 1));
    RMSE_with = [RMSE_with;RMSE];

    v_neo = v(N_identify:N_identify+NT);
    v_neo_pre = v_pre(N_identify:N_identify+NT);
    t_neo = [0];
    for k = 1:NT
        t_neo = [t_neo t_neo(k)+ 0.02];
    end
    V_with = [V_with v_neo];
end
RMSE_with_ave = mean(RMSE_with)
Max_with = max(RMSE_with)
Min_with = min(RMSE_with)
Median_with = median(RMSE_with)%22
[Mwith Iwith] = max(RMSE_with)
Iwith2=22;
[Mwith3,Iwith3] = max(RMSE_with)
V_compare = [V_with(:,Iwith) V_pml(:,Iwith)];
V_compare2 = [V_with(:,22) V_pml(:,22)];

V_with_compare = [V_with(:,Iwith) V_pml(:,Iwith) V_with(:,Iwith2) V_pml(:,Iwith2) V_with(:,Iwith3) V_pml(:,Iwith3)];

Sparse_worst = Sparse(Iwith)
Sparse_mean = mean(Sparse)

%% 4.Comparision

RMSE_without = [];
V_without = [];

list = dir('*.csv');
for o = controll_datanumber+1:controll_datanumber+uncontroll_datanumber
    F = readmatrix(list(o).name);
    [Row Col] = size(F);
    t = F(:,1)*ts;
    a = F(:,2);
    v = F(:,3);
    v_pre = F(:,4);
    v_pml = F(:,5);
    
    N = Row;
    
    z = [];
    z_t = 0;
    for i = 1:N
        z = [z;z_t];
        z_t = z_t + v(i)*ts*1000/3600;
    end
    
    N_identify=0;
    i=1;
    while i<N
        N_identify = N_identify + 1;
        if v_pre(i) == 80
            break
        end
        i=i+1;
    end

    z_pre_t = 10;
    z_pre = [];
    for j = 1:N
        z_pre = [z_pre;z_pre_t];
        z_pre_t = z_pre_t + v_pre(j)*ts*1000/3600;
    end
    
    z_relative = z_pre - z;
    v_relative = v_pre(1:N) - v(1:N);
    l_pre = 1.4;%[m]
    
    % RMSE
    v_dif = v_pre - v;
    v_dif = v_dif(N_identify:N);
    [Rowd, Cold] = size(v_dif);
    RMSE = 0;
    for j = 1:NT+1
        RMSE = RMSE + v_dif(j)^2;
    end
    RMSE = sqrt(RMSE/(T/ts + 1));
    RMSE_without = [RMSE_without;RMSE];

    v_neo = v(N_identify:N_identify+NT);
    v_neo_pre = v_pre(N_identify:N_identify+NT);
    t_neo = [0];
    for k = 1:NT
        t_neo = [t_neo t_neo(k)+ 0.02];
    end
    V_without = [V_without v_neo];
end

RMSE_without_ave = mean(RMSE_without)
Max_without = max(RMSE_without)
Min_without = min(RMSE_without)
Median_without = median(RMSE_without)
[Mwithout Iwithout] = max(RMSE_without)%6
Iwithout2=6;
[Mwithout3 Iwithout3] = max(RMSE_without)
V_compare = [V_compare V_without(:,Iwithout)];
V_compare2 = [V_compare2 V_without(:,6)];

V_without_compare = [V_without(:,Iwithout) V_without(:,Iwithout2) V_without(:,Iwithout3)];

%% figure

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
for i = 1:controll_datanumber
    plot(t_neo,V_pml(:,i), 'k', 'LineWidth', lineWidth); 
end
grid on 
box on
xlim([0 T])
xticks([0:5:T])
yticks([65:5:90])
ylim([65 90])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex'); 
ylabel('$v_{\rm{pml}}[\rm{km/h}]$', 'interpreter', 'latex');  
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
for i = 1:controll_datanumber
    plot(t_ts02(1:Cut_hozon(i)),V_pml_neo(1:Cut_hozon(i),i), 'k', 'LineWidth', lineWidth); 
end
grid on 
box on
xlim([0 T])
xticks([0:5:T])
yticks([65:5:90])
ylim([65 90])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
ylabel('$v_{\rm{pml}}[\rm{km/h}]$', 'interpreter', 'latex');  
legend('$v_{\rm{pml}}$','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
plot(t_neo,v_neo_pre, 'r-', 'LineWidth', lineWidth); 
for i = 1:controll_datanumber
    plot(t_neo,V_with(:,i), 'k-', 'LineWidth', lineWidth); 
end
hold off
grid on 
box on
xticks([0:5:T])
yticks([65:5:90])
ylim([65 90])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex'); 
ylabel('$v[\rm{km/h}]$', 'interpreter', 'latex');  
legend('$v_{0}$','$v_1$(with PMLs)','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
plot(t_neo,v_neo_pre, 'r-', 'LineWidth', lineWidth); 
for i = 1:uncontroll_datanumber
    plot(t_neo,V_without(:,i), 'k-', 'LineWidth', lineWidth); 
end
hold off
grid on 
box on
xticks([0:5:T])
yticks([65:5:90])
ylim([65 90])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex'); 
ylabel('$v[\rm{km/h}]$', 'interpreter', 'latex'); 
legend('$v_{0}$','$v_1$(without PMLs)','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
plot(t_neo,v_neo_pre, 'r-', 'LineWidth', lineWidth); 
plot(t_neo,V_compare(:,1),'k-', 'LineWidth', lineWidth); 
plot(t_neo,V_compare(:,3),'k-.', 'LineWidth', lineWidth); 
plot(t_ts02(1:Cut_hozon(Iwith)),V_pml_neo(1:Cut_hozon(Iwith),Iwith), 'g', 'LineWidth', lineWidth); 
hold off
grid on
box on
xticks([0:5:T])
yticks([65:5:100])
ylim([65 100])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
ylabel('$v[\rm{km/h}]$', 'interpreter', 'latex');  
legend('$v_{0}$','$v_1$(with PMLs)','$v_1$(without PMLs)','$v_{\rm{pml}}$','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
plot(t_neo,v_neo_pre, 'r-', 'LineWidth', lineWidth);
plot(t_neo,V_with_compare(:,1),'k-', 'LineWidth', lineWidth); 
plot(t_neo,V_with_compare(:,3),'k--', 'LineWidth', lineWidth); 
plot(t_neo,V_with_compare(:,5),'k:', 'LineWidth', lineWidth); 
plot(t_ts02(1:Cut_hozon(Iwith)),V_pml_neo(1:Cut_hozon(Iwith),Iwith), 'g-', 'LineWidth', lineWidth); 
plot(t_ts02(1:Cut_hozon(Iwith2)),V_pml_neo(1:Cut_hozon(Iwith2),Iwith2), 'g--', 'LineWidth', lineWidth); 
plot(t_ts02(1:Cut_hozon(Iwith3)),V_pml_neo(1:Cut_hozon(Iwith3),Iwith3), 'g:', 'LineWidth', lineWidth); 
hold off
grid on
box on
xticks([0:5:T])
yticks([65:5:100])
ylim([65 100])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex'); 
ylabel('$v[\rm{km/h}]$', 'interpreter', 'latex');  
legend('$v_{0}$','$v_1$(best)','$v_1$(median)','$v_1$(worst)','$v_{\rm{pml}}$(best)','$v_{\rm{pml}}$(median)','$v_{\rm{pml}}$(worst)','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
plot(t_neo,v_neo_pre, 'r-', 'LineWidth', lineWidth); 
plot(t_neo,V_without_compare(:,1),'k-', 'LineWidth', lineWidth); 
plot(t_neo,V_without_compare(:,2),'k--', 'LineWidth', lineWidth); 
plot(t_neo,V_without_compare(:,3),'k:', 'LineWidth', lineWidth); 
hold off
grid on 
box on
xticks([0:5:T])
yticks([65:5:100])
ylim([65 100])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
ylabel('$v[\rm{km/h}]$', 'interpreter', 'latex');  
legend('$v_{0}$','$v_1$(best)','$v_1$(median)','$v_1$(worst)','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

figure('Position', [0 0 700 450], 'Color', 'white'); 
hold on
plot(t_neo,v_neo_pre, 'r-', 'LineWidth', lineWidth); 
plot(t_neo,V_compare2(:,1),'k-', 'LineWidth', lineWidth); 
plot(t_neo,V_compare2(:,3),'k-.', 'LineWidth', lineWidth); 
plot(t_ts02(1:Cut_hozon(22)),V_pml_neo(1:Cut_hozon(22),22), 'g', 'LineWidth', lineWidth); 
hold off
grid on 
box on
xticks([0:5:T])
yticks([65:5:100])
ylim([65 100])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
ylabel('$v[\rm{km/h}]$', 'interpreter', 'latex');  
legend('$v_{0}$','$v_1$(with PMLs)','$v_1$(without PMLs)','$v_{\rm{pml}}$','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

%% EOF_of_Control_result.m
