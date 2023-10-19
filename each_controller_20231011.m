%% controller.m

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

%% 2.Parameter

%-----------------%
      %Time%
%------------------%
ts_Unity = 0.02;
ts = 0.2;
t = 10;
N = t/ts;
T = (0:N)*ts;

%-----------------%
    %Vehicle%
%------------------%
T_plant = 0.25;
umax = 4;
L = 4;

%-----------------%
     %Driver%
%------------------%
%Assign parameters obtained by modeling
% Hl
cl = 0.719;
dl = 2;
Ll = 40;
% Hm
km = 0.135;
cm = 0.142;
hm = 0.211;
cm2 = 0.258;
Lv = 10;
Lv2 = 40;
dm = 7;

%% data

%parameter of Hm
CM = [0.132; 0.096; 0.100; 0.035; 0.024; 0.069; 0.057; 0.072; 0.057; 0.064]*4;
DM = [6; 6; 8; 3; 13; 9; 9; 10; 15; 8];

%parameter of Hl
CL = [0.282; 0.246; 0.084; 0.106; 0.057; 0.142; 0.188; 0.231; 0.172; 0.134]*4;
DL = [2; 2; 7; 2; 7; 5; 3; 3; 4; 4];

%% 3.controller parameter

%------------------------%
 %Adjustment Parameters%
%-----------------------%
H = 5;%prediction horizon
wQ1 = 50;%Weights for the current time state
wQ2 = 20;%terminal cost
wR = 10;%Weights for the current time PML's velocity differencial
omega = 1;%Weights for the integral of the velocity error

%----------------------------------%
 %Weight matrix for velocity error% 
%----------------------------------%
Q = diag(5*ones(H+1,1));
Q(1,1) = wQ1;
Q(H+1,H+1) = wQ2;
for i = 1:H
    for j = 1:H
        if i==j
            Q(i,j) = Q(i,j) + omega*(H+1-i);
        elseif i>j
            Q(i,j) = omega*(H+1-i);
        else
            Q(i,j) = omega*(H+1-j);
        end
    end
end

%-----------------------------------%
 %Weight matrix for velocity change% 
%-----------------------------------%
R = diag(ones(H,1));
R(1,1) = wR;

%---------------------------------%
 %Definition of difference matrix% 
%---------------------------------%
a1 = (-1)*ones(1,H);
a2 = ones(1,H-1);
Phi_pre1 = diag(a1) + diag(a2,1); 
Phi_pre2 = zeros(H,1);
Phi_pre2(H) = 1;
Phi = [Phi_pre1 Phi_pre2];

%---------------------------------%
           %Constraints 
%---------------------------------%
a_max = 4;%Upper bound of change in PML in 1 second
l_min = 60;%Lower bound of PML speed
l_max = 100;%Upper bound of PML speed

%% 4.Data collection for approximate controller creation
tic
Wminmarge = [];
for o = 1:10
    data_input = [];
    data_output = [];
    for q = 1:61
        dl = DL(o);
        cl = CL(o);
        if DM(o) >= DL(o)
            d = DM(o);
        else
            d = DL(o);
        end
        %-----------------%
          %initial value% 
        %-----------------%
        A1 = zeros(N+1,1);
        v1_start = 67 + 0.1*(q-1);
        v1 = v1_start;
        V1 = zeros(N+1,1);
        V1(1) = v1;
        z1 = 0;
        Z1 = zeros(N+1,1);
        Z1(1) = z1;
        
        % Preceding vehicle
        vref = 80;
        v0 = vref;
        V0 = v0*ones(N+1,1);
        z0 = z1 + 20 + L;
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
    
        Time = zeros(N,1);
    
        % Controlled vehicle
        upre = 0;
        U = zeros(N+1,1);
        apre = 0;
        vpre = v1*ones(d,1);
        zpre = zeros(d,1);
        for i = 1:d-1
            zpre(d-i) = zpre(d-i+1) - ts*vpre(d-i+1)/3.6;
        end
        
        % 0台目
        v0pre = v1*ones(dm,1);
        z0pre = z0*ones(dm,1);
        for i = 1:dm-1
            z0pre(dm-i) = z0pre(dm-i+1) - ts*v0pre(dm-i+1)/3.6;
        end
        
        % PML
        zpmlpre = zeros(dl,1);
        vpmlpre = vpml*ones(dl,1);
        
        %-----------------%
          %Simulation% 
        %-----------------%
        for i = 1:N
            q
            i
            %-----%
             %MPC% 
            %-----%
            cvx_begin
                variables VpmlI(H+dl) VI(H+dl+1) AI(H+1)
                minimize ( ( vref * ones(H+1,1) - VI(dl+1:H+dl+1) ).'*Q*( vref * ones(H+1,1) - VI(dl+1:H+dl+1) ) + norm ( R * Phi * VpmlI(dl:H+dl),2) )
                subject to
                    VpmlI(1:dl) == vpmlpre(dl);
                    for k = 1:H
                        abs( VpmlI(k+dl) - VpmlI(k+dl-1) ) <= a_max*ts;
                        VpmlI(k+dl) <= l_max;
                        VpmlI(k+dl) >= l_min;
                    end
                    VI(1:dl) == vpre(d-1)*ones(dl,1);
                    VI(dl+1) == vpre(d);
                    AI(1) == 0;
                    for k = 1:H
                        u = CL(o)*( VpmlI(k) - VI(k) );
                        AI(k+1) == ( T_plant - ts )*AI(k)/T_plant + ts*u/T_plant;
                        VI(k+dl+1) == VI(k+dl) + ts*AI(k);
                    end
            cvx_end
            %Current Status Update
            zpml = zpml + vpml*ts/3.6;
            vpml = VpmlI(dl+1);
            u1 = CL(o) * ( vpmlpre(1) - vpre(d-dl+1) );
            if u1 >= 1
                u1 = 1;
            elseif u1 <= -1
                u1 = -1;
            end
            a1 =  ((T_plant-ts)*apre + ts*upre)/T_plant;
            v1 = vpre(d) + ts*apre + 2*ts*(rand-0.5);
            z1 = z1 + ts*vpre(d)/3.6;
            % Update of historical values
            upre = u1;
            apre = a1;
            z0pre = [z0pre(2:dm);Z0(i+1)];
            v0pre = [v0pre(2:dm);V0(i+1)];
            zpre = [zpre(2:d);z1];
            vpre = [vpre(2:d);v1];
            zpmlpre = [zpmlpre(2:dl);zpml];
            vpmlpre = [vpmlpre(2:dl);vpml];
            Z1(i+1) = z1;
            V1(i+1) = v1;
            A1(i+1) = a1;
            Zpml(i+1) = zpml;
            Vpml(i+1) = vpml;
            U(i+1) = upre;
        end
        data_input = [data_input;Vpml(1:N-dl+1)-V1(1:N-dl+1) vref*ones(N-dl+1,1)-V1(dl:N) Vpml(dl-1:N-1)-Vpml(dl:N) Vpml(dl:N)];
        data_output = [data_output;Vpml(dl+1:N+1)];
    end
    %% 5.save data
    %save('each_controller_data_20231008.mat','data_input','data_output')
    
    %% 6.Approximation
    
    % 6.1 Import
    
    %load('controller_data_20231008.mat'); 
    x = data_input;
    y = data_output;
    [Row,Col] = size(x);
    Time = 10;
    N_end = Time/ts - dl + 1;%Number of simulation steps per scenario
    N = Row/N_end;%NUmber of scenario
    
    % 6.2 RBF parameter
    R2 = [0:0.15:15;
        0:0.1:10];
    
    % 6.3 least-squares method
    options = optimset('MaxFunEvals',100000000000,'MaxIter',100000000000);
    W0 = zeros(2,101);
    Aeq = zeros(5,5);
    tic;
    Wmin = fminsearch(@(W) identify(x,y,N,N_end,R2,W),W0,options);
    toc;
    Wmin
    Wminmarge = [Wminmarge;Wmin];
end

   
    save('all_Wmin.mat','Wminmarge')

    %% 7.file change
    %Changed notation for Unity (C#)
    
    W = string(Wminmarge);
    
    [Row,Col] = size(W);
    Wneoeach = string(W);
    for i = 1:Row
        for j = 1:Col
            Wneoeach(i,j) = append(Wneoeach(i,j),'f');
        end
    end
    writematrix(Wneoeach)
    type 'Wneoeach.txt'
    [Row,Col] = size(R2);
    Rneoeach = string(R2);
    for i = 1:Row
        for j = 1:Col
            Rneoeach(i,j) = append(Rneoeach(i,j),'f');
        end
    end
    writematrix(Rneoeach)
    type 'Rneoeach.txt'

    %save('each_con_para_20231011','Rneo','Wneo');

%% function
function J = identify(x,y,N,N_end,R,W)
    Error = [];
    for m = 1:N
        x_now = x(N_end*(m-1)+1:N_end*m,:);%evl,evm
        y_now = y(N_end*(m-1)+1:N_end*m,:);
        vpml = x_now(:,4);% k = dl+2 ~ N
        X = [x_now(:,1) x_now(:,2)];
        for k = 1:N_end-1
            sum = 0;
            for i = 1:2
                for j = 1:101
                    sum = sum + W(i,j)*exp( -(X(k,i)-R(i,j))^2);
                end
            end
            Error = [Error;y_now(k) - vpml(k) - sum];
        end
    end
    J = norm(Error,2) + norm(W,2);
end
%% EOF_of_controller.m