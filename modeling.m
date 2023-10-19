%% modeling.m

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

%% 2.parameter

%-----------------%
      %Time%
%------------------%
tsid = 10;%Time used for identification
ts = 0.2;%Sample time in modeling with MATLAB
ts_Unity = 0.02;%Sample time with Unity

%-----------------%
    %Delay time%
%------------------%
backmax = 10;%Parameters for identification of driver delay time

%-----------------%
    %Vehicle%
%------------------%
T_plant = 0.25;
umax = 4;

%--------------------------------------%
 %Trajectories used for identification%
%--------------------------------------%
testfirst = 1;
testfinal = 50;
validation = 10;%Number of validation data

%% 3.System identification

RMSE_AVE = [];
list=dir('*.csv');
IDwo = [];

for q = 0:backmax
    back = q
    V_figure = [];
    U_figure = [];
    A_training = [];
    Z_training = [];
    V_training = [];
    U_training = [];
    Z_pml_training = [];
    V_pml_training = [];
    N_identify_training = [];
    N_training = [];
    V_test = [];

    %---------------------------------------%
     %Extraction of data for identification%
    %---------------------------------------%
    for o = testfirst:testfinal

        %-----------------%
              %Import%
        %------------------%
        F = readmatrix(list(o).name);
        [Row_moto Col_moto] = size(F);
        %Extraction of each state
        t_moto = F(:,1);%descrete time
        u_moto = F(:,2);%control action
        v_moto = F(:,3);%vehicle velocity
        v_pre_moto = F(:,4);%P0 velocity

        %identification start time
        deltatime = 0;
        N_identify_pre = 0;
        D = [];
        for i=1:Row_moto
            if deltatime >= 5
                N_identify_pre = i;
                break
            end
            if abs(v_moto(i)-70) <= 3
                deltatime = deltatime + ts_Unity;
            else
                deltatime = 0;
            end
            D = [D;deltatime];
        end
        if N_identify_pre == 0
            [M_id I_id] = max(D);
            N_identify_pre = I_id;
        end
        N_identify = round(N_identify_pre/(ts/ts_Unity));
        if N_identify-N_identify_pre <= 0
            N_identify = N_identify+1;
        end
    
        %----------------------%
         %Various calibrations%
        %----------------------%
        %ts0.02⇒0.2
        t = [t_moto(1)];
        u= [u_moto(1)];
        v = [v_moto(1)];
        v_pre = [v_pre_moto(1)];
        j = 1;
        while j <= Row_moto
            if mod(j,10) == 0
                t = [t;t_moto(j)];
                u= [u;u_moto(j)];
                v = [v;v_moto(j)];
                v_pre = [v_pre;v_pre_moto(j)];
            end
            j = j+1;
        end
        t = t*ts;
        %PML velocity
        [Row Col] = size(t);
        N = Row;
        v_pmlk = 0;
        v_pml = [v_pmlk];
        for i = 1:N-1
            v_pml = [v_pml;v_pml(1)+0.04];
        end
        for i = 1:N
            if v_pml(i) >= 70
                v_pml(i) = 70;
            end
            if i >= N_identify
                v_pml(i) = 80;
            end
        end
        %Vehicle position
        z = [];
        z_t = 0;
        for i = 1:N
            z = [z;z_t];
            z_t = z_t + v(i)*ts*1000/3600;
        end
        %PML position
        z_pml_t = 0;
        z_pml = [];
        for j = 1:N
            z_pml = [z_pml;z_pml_t];
            z_pml_t = z_pml_t + v_pre(j)*ts*1000/3600;
        end

        %----------------------------%
         %Storage of calibrated data%
        %----------------------------%
        V_figure = [V_figure v(N_identify:N_identify+(tsid/ts))];
        U_figure = [U_figure u(N_identify:N_identify+(tsid/ts))];
        if mod(o,5) ~= 0
            Z_training = [Z_training z(N_identify-back:N_identify+(tsid/ts))];
            V_training = [V_training v(N_identify-back:N_identify+(tsid/ts))];
            A_training = [A_training (v(N_identify+1)-v(N_identify))/ts];
            U_training = [U_training u(N_identify)];
            Z_pml_training = [Z_pml_training z_pml(N_identify-back:N_identify+(tsid/ts))];
            V_pml_training = [V_pml_training v_pml(N_identify-back:N_identify+(tsid/ts))];
        else
            V_test = [V_test v(N_identify:N_identify+(tsid/ts))];
        end
    end

    %-----------------------%
     %System identification%
    %-----------------------%
    x0 = [0];
    xmin = fminsearch(@(x) identify_wo_dis(x,U_training,A_training,Z_training,V_training,back,ts,V_pml_training,T_plant,umax,tsid,testfirst,testfinal,validation),x0);
    %
    C = xmin;
    IDwo = [IDwo C];

    %Test data
    V_test = V_figure.';
    V_test_mean = mean(V_test);
    V_test_var = sqrt(var(V_test));
    V_test_min = V_test_mean - V_test_var;
    V_test_max = V_test_mean + V_test_var;
    V_test_result = [V_test_min;2*V_test_var].';

    %----------------------------------%
     %Generation of model trajectories%
    %----------------------------------%
    apre = 0;
    vpre = V_test_mean(1)*ones(back+1,1);
    upre = 0;
    ysim = [];
    uk = C*(70 - vpre(back+1));
    ak = ((T_plant-ts)*apre + ts*upre)/T_plant;
    vk = vpre(back+1) + ts*apre;
    apre = ak;
    vpre = [vpre(2:back+1);vk];
    upre = uk;
    for i = 1:(tsid/ts)+1
        if i <= back
            uk = C*(70 - vpre(1));
        else
            uk = C*(80 - vpre(1));
        end
        if uk >= umax
            uk = umax;
        elseif uk <= -umax
            uk = -umax;
        end
        upre = uk;
        ak = ((T_plant-ts)*apre + ts*upre)/T_plant;
        vk = vpre(back+1) + ts*apre;
        ysim = [ysim;vk];
        apre = ak;
        vpre = [vpre(2:back+1);vk];
    end

    %--------------%
     %Average RMSE%
    %--------------%
    RMSE = [];
    a = zeros(10,1);
    for i = 1:validation
        for j = 1:(tsid/ts)+1
            a(i) = a(i) + (ysim(j)-V_test(i,j))^2; 
        end
        RMSE = [RMSE;sqrt(a(i)/((tsid/ts)+1))];
    end
    RMSE
    RMSE_ave = mean(RMSE)
    C
    RMSE_AVE = [RMSE_AVE;RMSE_ave];
end

%% 4.Optimal parameter and trajectory
[M I] = min(RMSE_AVE);
back = I
RMSE_AVE(I)
C = IDwo(:,I);
backwo = back;
RMSE_wo = RMSE_AVE(I);
Cwo = C;

apre = 0;
vpre = V_test_mean(1)*ones(back+1,1);
upre = 0;
ysim = [];
usim = [];
uk = C*(70 - vpre(back+1));
ak = ((T_plant-ts)*apre + ts*upre)/T_plant;
vk = vpre(back+1) + ts*apre;
apre = ak;
vpre = [vpre(2:back+1);vk];
upre = uk;
for i = 1:(tsid/ts)+1
    if i <= back
        uk = C*(70 - vpre(1));
    else
        uk = C*(80 - vpre(1));
    end
    if uk >= umax
        uk = umax;
    elseif uk <= -umax
        uk = -umax;
    end
    upre = uk;
    ak = ((T_plant-ts)*apre + ts*upre)/T_plant;
    vk = vpre(back+1) + ts*apre;
    ysim = [ysim;vk];
    usim = [usim;uk];
    apre = ak;
    vpre = [vpre(2:back+1);vk];
end

%% 5.figure

T = [0:ts:tsid];

%figure1: region
figure('Position', [0 0 700 450], 'Color', 'white'); 
plot(T,ysim, 'k', 'LineWidth', lineWidth);
hold on
ar = area(T,V_test_result);
set(ar(1),'FaceColor','None')
set(ar(2),'FaceColor',[0.0,0.2,1.0],'FaceAlpha',0.2);
grid on 
box on
yticks([65:5:90])
ylim([65 90])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex'); 
ylabel({'$v[\rm{km/h}]$'}, 'interpreter', 'latex'); 
legend('Identification Model','','Area of validation data','interpreter','latex')
legend('Location','best')
set(gca, 'FontName',fontName,'FontSize', fontSize); 

%figure2: training data v.s. model(velocity)
figure('Position', [0 0 700 450], 'Color', 'white'); 
plot(T,ysim, 'r', 'LineWidth', 5);
hold on
for i = 1:(testfinal-testfirst+1)-validation
    plot(T,V_figure(:,i), 'k', 'LineWidth', 0.6);
end
grid on 
box on
yticks([65:5:100])
ylim([65 100])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
ylabel({'$v[\rm{km/h}]$'}, 'interpreter', 'latex');  
set(gca, 'FontName',fontName,'FontSize', fontSize);

%figure3: training data v.s. model(control action)
figure('Position', [0 0 700 450], 'Color', 'white'); 
plot(T,usim, 'r', 'LineWidth', 5); 
hold on
for i = 1:(testfinal-testfirst+1)-validation
    plot(T,U_figure(:,i), 'k', 'LineWidth', 0.6); 
end
grid on 
box on
yticks([-1:0.5:1])
ylim([-1 1])
xlabel({'$t[\rm{s}]$'}, 'interpreter', 'latex');  
ylabel({'$u$'}, 'interpreter', 'latex');  
set(gca, 'FontName',fontName,'FontSize', fontSize); 

%% function
function J2 = identify_wo_dis(x,U_training,A_training,Z_training,V_training,back,ts,V_pml_training,T_plant,umax,tsid,testfirst,testfinal,validation)
C = x(1);
Error = [];
for i = testfirst:testfinal-validation
    apre = A_training(1,i);
    vpre = V_training(1:back+1,i);
    zpre = Z_training(1:back+1,i);
    upre = U_training(i);
    ysim = V_training(back+1);
    for k = 1:tsid/ts
        uk = C*(V_pml_training(k,i) - vpre(1));
        if uk >= umax
            uk = umax;
        elseif uk <= -umax
            uk = -umax;
        end
        ak = ((T_plant-ts)*apre + ts*upre)/T_plant;
        vk = vpre(back+1) + ts*apre;
        zk = zpre + ts*vpre(back+1);
        ysim = [ysim;vk];
        apre = ak;
        vpre = [vpre(2:back+1);vk];
        zpre = [zpre(2:back+1);zk];
        upre = uk;
    end
    y_real = V_training(1:tsid/ts+1,i);
    Error = [Error;y_real-ysim];
end
J2 = norm(Error,2);
end
%% EOF_fo_modeling.m