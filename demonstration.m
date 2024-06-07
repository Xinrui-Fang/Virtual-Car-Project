%% Initialize

close all 
clear 
clc 

userChoice = 'Each';%All or Each
if strcmp(userChoice, 'Each')
    Drivernumber = 5;%1~10
end

%-----------------%
 %figure setting%
%-----------------%
lineWidth = 3;
fontName ='Times New Roman';
fontSize = 28;
cmp = colormap;

ts_Unity = 0.02;
ts = 0.2;
t = 15;
N = t/ts;
T = (0:N)*ts;

%% plant parameter

% vehicle
K_plant = 4;
T_plant = 0.25;
L = 4;

load("everyone_parameter.mat");%each driver's parameter

Ll = 60;
km = 0.135;
cm = 0.142;
hm = 0.211;
Lv = 10;
Lv2 = 40;



%% simulation

load('dataset_neoplant_reduce_0529_v2.mat');
W = Wmin;



R2 = [0:0.15:15;
    0:0.1:10];

V = 70*ones(20/ts + 1,10);
Vnon = 70*ones(20/ts + 1,10);
Vpml_hozon = zeros(20/ts + 1,10);

RMSE_save = zeros(2,10);
for o = 1:10
    cl = CL(o);
    dl = DL(o);
    cm2 = CM(o);
    dm = DM(o);
    if dm >= dl
        d = dm;
    else
        d = dl;
    end
    % P
    v1_start = 70;
    v1 = v1_start;
    V1 = zeros(N+1,1);
    V1(1) = v1;
    z1 = 0;
    Z1 = zeros(N+1,1);
    Z1(1) = z1;
    
    % P0
    v0 = v1 + 10;
    V0 = v0*ones(N+1,1);
    z0 = z1 + 10 + L;
    Z0 = zeros(N+1,1);
    Z0(1) = z0;
    for i = 1:N
        Z0(i+1) = Z0(i) + ts*V0(i)/3.6;
    end
    
    % PML
    vpml_start = v1;
    vpml = vpml_start;
    Vpml = zeros(N+1,1);
    Vpml(1) = vpml;
    zpml = z1 + 10;
    Zpml = zeros(N+1,1);
    Zpml(1) = zpml;
    vref=80;
    
    % P
    upre = 0;
    U = zeros(N+1,1);
    apre = 0;
    vpre = v1*ones(d,1);
    zpre = zeros(d,1);
    for i = 1:d-1
        zpre(d-i) = zpre(d-i+1) - ts*vpre(d-i+1)/3.6;
    end
    
    % P0
    v0pre = v1*ones(dm,1);
    z0pre = z0*ones(dm,1);
    for i = 1:dm-1
        z0pre(dm-i) = z0pre(dm-i+1) - ts*v0pre(dm-i+1)/3.6;
    end
    
    % PML
    zpmlpre = zeros(dl,1);
    vpmlpre = vpml*ones(dl,1);
    Tch = 0;
    Tl = 0;
    XX = [];
    
    for i = 1:N
       
        if or(z0pre(1) - zpre(d-dm+1) - L >= Lv,z0pre(1) - zpre(d-dm+1) - L <= Lv2)
            if or(zpmlpre(1) - zpre(d-dl+1) < 0,zpmlpre(1) - zpre(d-dl+1) > Ll)
                % follow preceding vehicle
                % update
                u1 = cm2 * ( v0pre(1) - vpre(d-dm+1) );
                a1 = ((T_plant-ts)*apre + ts*upre)/T_plant;
                v1 = vpre(d) + ts*apre;
                z1 = zpre(d) + ts*vpre(d)/3.6;
                if V1(i) <= V0(i)
                    zpml = z1 + 10;
                    vpml = vpml_start;
                else
                    zpml = z1;
                    vpml = 0;
                end
                % update
                upre = u1;
                apre = a1;
                z0pre = [z0pre(2:dm);Z0(i+1)];
                v0pre = [v0pre(2:dm);V0(i+1)];
                zpre = [zpre(2:d);z1];
                vpre = [vpre(2:d);v1];
                zpmlpre = [zpmlpre(2:dl);zpml];
                vpmlpre = [vpmlpre(2:dl);vpml];
                % time when pml can be seen
                Tch = 0;
            else
                if Tch < dl
                    % free drive
                    % update
                    u1 = cm2 * ( v0pre(1) - vpre(d-dm+1) );
                    a1 = ((T_plant-ts)*apre + ts*upre)/T_plant;
                    v1 = vpre(d) + ts*apre;
                    z1 = z1 + ts*vpre(d)/3.6;
                    if V1(i) <= V0(i)
                        zpml = zpml + ts*vpml/3.6;
                        vpml = vpml_start;
                    else
                        zpml = z1;
                        vpml = 0;
                    end
                    % update
                    upre = u1;
                    apre = a1;
                    z0pre = [z0pre(2:dm);Z0(i+1)];
                    v0pre = [v0pre(2:dm);V0(i+1)];
                    zpre = [zpre(2:d);z1];
                    vpre = [vpre(2:d);v1];
                    zpmlpre = [zpmlpre(2:dl);zpml];
                    vpmlpre = [vpmlpre(2:dl);vpml];
                    % time when pml can be seen
                    Tch = Tch + 1;
                else 
                    if V1(i) <= V0(i)
                        
                        %%%%%%%%%%Control logic Start%%%%%%%%%%
                        X = [vpml-vpre(1) vref-vpre(2)];
                        sum = 0;
                        for k = 1:2
                            for j = 1:101
                                sum = sum + Wmin(k,j)*exp( -(X(k)-R2(k,j))^2 );
                            end
                        end
                        vpml = vpml + sum;
                        %%%%%%%%%%Control logic End%%%%%%%%%%
                        
                        %update
                        zpml = zpml + vpmlpre(dl)*ts/3.6;
                        u1 = cl * ( vpmlpre(1) - vpre(d-dl+1) );
                        Tl = 0;
                        XX = [XX;X];
                    else
                        vpml = 0;
                        zpml = z1;
                        if Tl < dl
                            u1 = cl * ( vpmlpre(1) - vpre(d-dl+1) );
                        else
                            u1 = 0;
                        end
                        Tl = Tl+1;
                    end
                    if u1 >= 1
                        u1 = 1;
                    elseif u1 <= -1
                        u1 = -1;
                    end
                    a1 =  ((T_plant-ts)*apre + ts*upre)/T_plant;
                    v1 = vpre(d) + ts*apre;
                    z1 = z1 + ts*vpre(d)/3.6;
                    % update
                    upre = u1;
                    apre = a1;
                    z0pre = [z0pre(2:dm);Z0(i+1)];
                    v0pre = [v0pre(2:dm);V0(i+1)];
                    zpre = [zpre(2:d);z1];
                    vpre = [vpre(2:d);v1];
                    zpmlpre = [zpmlpre(2:dl);zpml];
                    vpmlpre = [vpmlpre(2:dl);vpml];
                end
            end
        elseif z0pre(1) - zpre(d-dm+1) - L >= Lv2
            if or(zpmlpre(1) - zpre(d-dl+1) < 0,zpmlpre(1) - zpre(d-dl+1) > Ll)
                % follow preceding vehicle
                % update
                u1 = 0;
                a1 = ((T_plant-ts)*apre + ts*upre)/T_plant;
                v1 = vpre(d) + ts*apre;
                z1 = zpre(d) + ts*vpre(d)/3.6;
                if V1(i) <= V0(i)
                    zpml = z1 + 10;
                    vpml = vpml_start;
                else
                    zpml = z1;
                    vpml = 0;
                end
                % update
                upre = u1;
                apre = a1;
                z0pre = [z0pre(2:dm);Z0(i+1)];
                v0pre = [v0pre(2:dm);V0(i+1)];
                zpre = [zpre(2:d);z1];
                vpre = [vpre(2:d);v1];
                zpmlpre = [zpmlpre(2:dl);zpml];
                vpmlpre = [vpmlpre(2:dl);vpml];
                % time when pml can be seen
                Tch = 0;
            else
                if Tch < dl
                    % free drive
                    % update
                    u1 = 0;
                    a1 = ((T_plant-ts)*apre + ts*upre)/T_plant;
                    v1 = vpre(d) + ts*apre;
                    z1 = z1 + ts*vpre(d)/3.6;
                    if V1(i) <= V0(i)
                        zpml = zpml + 10;
                        vpml = vpml_start;
                    else
                        zpml = z1;
                        vpml = 0;
                    end
                    % update
                    upre = u1;
                    apre = a1;
                    z0pre = [z0pre(2:dm);Z0(i+1)];
                    v0pre = [v0pre(2:dm);V0(i+1)];
                    zpre = [zpre(2:d);z1];
                    vpre = [vpre(2:d);v1];
                    zpmlpre = [zpmlpre(2:dl);zpml];
                    vpmlpre = [vpmlpre(2:dl);vpml];
                    % time when pml can be seen
                    Tch = Tch + 1;
                else 
                    if V1(i) <= V0(i)
                        % follow pml
                     
                       X = [vpml-vpre(1) vref-vpre(2)];
                        sum = 0;
                        for k = 1:2
                            for j = 1:51
                                sum = sum + Wmin(k,j)*exp( -(X(k)-R2(k,j))^2 );
                                sum = sum + W(i,j+51)*abs(X(k,i)-R(i,j));
                            end
                        end
                        vpml = vpml + sum;
               
                        %update
                        zpml = zpml + vpmlpre(dl)*ts/3.6;
                        u1 = cl * ( vpmlpre(1) - vpre(d-dl+1) );
                        Tl = 0;
                        XX = [XX;X];
                    else
                        vpml = 0;
                        zpml = z1;
                        if Tl < dl
                            u1 = cl * ( vpmlpre(1) - vpre(d-dl+1) );
                        else
                            u1 = 0;
                        end
                        Tl = Tl+1;
                    end
                    if u1 >= 1
                        u1 = 1;
                    elseif u1 <= -1
                        u1 = -1;
                    end
                    a1 =  ((T_plant-ts)*apre + ts*upre)/T_plant;
                    v1 = vpre(d) + ts*apre;
                    z1 = z1 + ts*vpre(d)/3.6;
                    % update
                    upre = u1;
                    apre = a1;
                    z0pre = [z0pre(2:dm);Z0(i+1)];
                    v0pre = [v0pre(2:dm);V0(i+1)];
                    zpre = [zpre(2:d);z1];
                    vpre = [vpre(2:d);v1];
                    zpmlpre = [zpmlpre(2:dl);zpml];
                    vpmlpre = [vpmlpre(2:dl);vpml];
                end
            end
        else
            % follow preceding vehicle
            u1 = km * ( z0(1) - zpre(d-dm+1) - hm*vpre(d-dm+1) - L) + cm * ( v0pre(d-dm+1) - vpre(d-dm+1) );
            if u1 >= 1
                u1 = 1;
            elseif u1 <= -1
                u1 = -1;
            end
            a1 = ((T_plant-ts)*apre + ts*upre)/T_plant;
            v1 = vpre(d) + ts*apre;
            z1 = z1 + ts*vpre(d)/3.6;
            zpml = z1;
            vpml = 0;
            % update
            upre = u1;
            apre = a1;
            z0pre = [z0pre(2:dm);Z0(i+1)];
            v0pre = [v0pre(2:dm);V0(i+1)];
            zpre = [zpre(2:d);z1];
            vpre = [vpre(2:d);v1];
            zpmlpre = [zpmlpre(2:dl);zpml];
            vpmlpre = [vpmlpre(2:dl);vpml];
            % time when pml can be seen
            Tch = 0;
        end
        Z1(i+1) = z1;
        V1(i+1) = v1;
        Zpml(i+1) = zpml;
        Vpml(i+1) = vpml;
        U(i+1) = upre;
    end
    V(5/ts+1:20/ts+1,o) = V1;
    Vpml_hozon(5/ts+1:20/ts+1,o) = Vpml;


    % RMSE
    J = V0 - V1;
    J1 = 0;
    for i = 1:N+1
        J1 = J1 + J(i)^2;
    end
    RMSE = sqrt(J1/(N+1));
    
    %% simulation (without PML)
    
    % P
    v1 = v1_start;
    V1_non = zeros(N+1,1);
    V1_non(1) = v1;
    z1 = 0;
    Z1_non = zeros(N+1,1);
    Z1_non(1) = z1;
    
    % P
    upre = 0;
    U_non = zeros(N+1,1);
    apre = 0;
    vpre2 = v1*ones(d,1);
    zpre2 = zeros(d,1);
    for i = 1:d-1
        zpre2(d-i) = zpre2(d-i+1) - ts*vpre2(d-i+1)/3.6;
    end
    
    % P0
    z0 = z1 + 20 + L;
    v0pre2 = v1*ones(dm,1);
    z0pre2 = z0*ones(dm,1);
    for i = 1:dm-1
        z0pre2(dm-i) = z0pre2(dm-i+1) - ts*v0pre2(dm-i+1)/3.6;
    end
    
    % simulation
    for i = 1:N
        if or(z0pre2(1) - zpre2(d-dm+1) - L >= Lv,z0pre2(1) - zpre2(d-dm+1) - L <= Lv2)
            u1 = cm2 * ( v0pre2(1) - vpre2(d-dm+1) );
        elseif z0pre2(1) - zpre2(d-dm+1) - L <= Lv
            u1 = km * ( z0(1) - zpre2(d-dm+1) - hm*vpre2(d-dm+1) - L) + cm * ( v0pre2(d-dm+1) - vpre2(d-dm+1) );
        else
            u1 = 0;
        end
        if u1 >= 1
            u1 = 1;
        elseif u1 <= -1
            u1 = -1;
        end
        a1 = ((T_plant-ts)*apre + ts*upre)/T_plant;
        v1 = vpre2(d) + ts*apre;
        z1 = z1 + ts*vpre2(d)/3.6;
        % update
        upre = u1;
        apre = a1;
        z0pre2 = [z0pre2(2:dm);Z0(i+1)];
        v0pre2 = [v0pre2(2:dm);V0(i+1)];
        zpre2 = [zpre2(2:d);z1];
        vpre2 = [vpre2(2:d);v1];
        Z1_non(i+1) = z1;
        V1_non(i+1) = v1;
        U_non(i+1) = upre;
    end
    Vnon(5/ts+1:20/ts+1,o) = V1_non;

    JJ = V0 - V1_non;
    J2 = 0;
    for i = 1:N+1
        J2 = J2 + JJ(i)^2;
    end
    RMSE_non = sqrt(J2/(N+1));

    RMSE_save(:,o) = [RMSE;RMSE_non];
end

V0neo = [70*ones(5/ts,1);V0];

%% 
if strcmp(userChoice, 'All')
    disp('Run All');
    
    % Evaluation
    Average_RMSE_with_PML = mean(RMSE_save(1,:))
    Average_RMSE_without_PML = mean(RMSE_save(2,:))
    [M,I] = max(RMSE_save(1,:));
    
    WorstRMSE_with = RMSE_save(1,I)
    WorstRMSE_without = RMSE_save(2,I)
    % figure
    
    V_pml_hozonneo = Vpml_hozon(:,I);
    i_off = 0;
    i = 20/ts+1;
    while i >= 1
        if V_pml_hozonneo(i) ~= 0
            i_off = i;
            break
        end
        i = i-1;
    end
    V_pml = V_pml_hozonneo(5/ts+1:i_off);
    t_pml = 5:ts:(i_off-1)*ts;
    
    %withPML
    figure('Position', [0 0 700 450], 'Color', 'white'); 
    hold on
    plot(0:ts:20,V0neo, 'r-', 'LineWidth', lineWidth); 
    for i = 1:10
    plot(0:ts:20,V(:,i), 'k-', 'LineWidth', 1); 
    end
    xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
    ylabel({'$v[\rm{km/h}]$'}, 'interpreter', 'latex');
    ax = gca; 
    xlim([0 20])
    ylim([65 90])
    xticks([0:5:20])
    yticks([65:5:90])
    grid on 
    box on
    legend('$v_{\rm{pv}}$','$v$(with)','interpreter','latex')
    legend('Location','best')
    set(gca, 'FontName',fontName,'FontSize', fontSize); 
    
    %without PML
    figure('Position', [0 0 700 450], 'Color', 'white'); 
    hold on
    plot(0:ts:20,V0neo, 'r-', 'LineWidth', lineWidth); 
    for i = 1:10
    plot(0:ts:20,Vnon(:,i), 'k-', 'LineWidth', 1); 
    end
    xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
    ylabel({'$v[\rm{km/h}]$'}, 'interpreter', 'latex');
    ax = gca; 
    xlim([0 20])
    ylim([65 90])
    xticks([0:5:20])
    yticks([65:5:90])
    grid on % グリッドの表示
    box on
    legend('$v_{\rm{pv}}$','$v$(without)','interpreter','latex')
    legend('Location','best')
    set(gca, 'FontName',fontName,'FontSize', fontSize); 
    
    %Worst case
    figure('Position', [0 0 700 450], 'Color', 'white'); 
    hold on
    plot(0:ts:20,V0neo, 'r-', 'LineWidth', lineWidth); 
    plot(0:ts:20,V(:,I), 'k-', 'LineWidth', 3); 
    plot(0:ts:20,Vnon(:,I), 'k-.', 'LineWidth', 3); 
    plot(t_pml,V_pml,'g-.', 'LineWidth', 3)
    xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
    ylabel({'$v[\rm{km/h}]$'}, 'interpreter', 'latex');
    ax = gca; 
    xlim([0 20])
    ylim([65 90])
    xticks([0:5:20])
    yticks([65:5:90])
    grid on 
    box on
    legend('$v_{\rm{pv}}$','$v$(with)','$v$(without)','$v_{\rm{pml}}$','interpreter','latex')
    legend('Location','best')
    set(gca, 'FontName',fontName,'FontSize', fontSize); 

elseif strcmp(userChoice, 'Each')
   
    disp('Run Each.');
   

    RMSE_selectdriver = RMSE_save(1,Drivernumber)
    
    V_pml_hozonneo = Vpml_hozon(:,Drivernumber);
    i_off = 0;
    i = 20/ts+1;
    while i >= 1
        if V_pml_hozonneo(i) ~= 0
            i_off = i;
            break
        end
        i = i-1;
    end
    V_pml = V_pml_hozonneo(5/ts+1:i_off);
    t_pml = 5:ts:(i_off-1)*ts;
    
    %Selected driver
    figure('Position', [0 0 700 450], 'Color', 'white'); 
    hold on
    plot(0:ts:20,V0neo, 'r-', 'LineWidth', lineWidth); 
    plot(0:ts:20,V(:,Drivernumber), 'k-', 'LineWidth', 3); 
    plot(t_pml,V_pml,'g-.', 'LineWidth', 3)
    xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
    ylabel({'$v[\rm{km/h}]$'}, 'interpreter', 'latex');
    ax = gca; 
    xlim([0 20])
    ylim([65 90])
    xticks([0:5:20])
    yticks([65:5:90])
    grid on 
    box on
    legend('$v_{\rm{pv}}$','$v$(with)','$v_{\rm{pml}}$','interpreter','latex')
    legend('Location','best')
    set(gca, 'FontName',fontName,'FontSize', fontSize); 

else
    disp('Invalid selection, please select Robust or Select.');
end
%% EOF
