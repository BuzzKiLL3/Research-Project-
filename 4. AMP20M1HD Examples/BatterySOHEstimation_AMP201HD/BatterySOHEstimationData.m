%% Parameters for Battery State-of-Health Estimation
% 
% This example shows how to estimate the battery internal resistance and 
% state-of-health (SOH) by using an adaptive Kalman filter. The initial 
% state-of-charge (SOC) of the battery is equal to 0.6. The estimator uses 
% an initial condition for the SOC equal to 0.65. The battery keeps 
% charging and discharging for 10 hours. The unscented Kalman filter
% estimator converges to the real value of the SOC while also estimating 
% the internal resistance. To use a different Kalman filter implementation, 
% in the SOC Estimator (Kalman Filter) block, set the Filter type parameter 
% to the desired value.

% Copyright 2022 The MathWorks, Inc.

%% System Parameters
%SOC_vec = [0, .1, .25, .5, .75, .9, 1]; % Vector of state-of-charge values, SOC
% Vector of state-of-charge values, SOC, (Simplified) | (1x7)
SOC_vec = [0, 0.1667, 0.3333, 0.5000, 0.6667, 0.8333, 1];

%T_vec   = [278, 293, 313];              % Vector of temperatures, T, (K)
% Vector of temperatures, T, (K), (Simplified) | (1x3)
T_vec = [263.15, 283.15, 308.15]; % [-10, 10, 35] (°C)

%AH      = 27;                           % Cell capacity, AH, (A*hr) 
% Cell capacity, AH, (A*hr), (Datasheet Derived) 
AH = 19.5; % Nominal Ah rating

%thermal_mass = 100;                     % Thermal mass (J/K)
% Thermal mass (J/K)
thermal_mass = 446.4;

% initialSOC = 0.6;                      % Battery initial SOC
% Battery initial SOC
initialSOC = 0.1;

%V0_mat  = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64;...
    %3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08;...
    %4.19, 4.19, 4.19];                          % Open-circuit voltage, V0(SOC,T), (V)
% Open-circuit voltage, V0(SOC,T), (V), (Simplified) | (7x3)
V0_mat  = [2.9322, 3.1640, 3.2138;
    3.2449, 3.0131, 3.1632;
    3.2135, 3.2446, 3.0940;
    3.1625, 3.2133, 3.2442;
    3.1749, 3.1617, 3.2131;
    3.2439, 3.2559, 3.1609;
    3.2128, 3.2436, 3.3368];

R0_mat  = [.0117, .0085, .009; .011, .0085, .009;...
    .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091;...
    .0113, .0085, .0089; .0116, .0085, .0089];  % Terminal resistance, R0(SOC,T), (ohm)
% Terminal resistance, R0(SOC,T), (Ohm), (Simplified) | (7x3)
%R0_mat  = [0.0800, 0.0489, 0.0192;
    %0.0158, 0.0621, 0.0250;
    %0.0104, 0.0092, 0.0458;
    %0.0101, 0.0053, 0.0046;
    %0.0021, 0.0017, 0.0015;
    %0.0015, 0.0103, 0.0011;
    %0.0012, 0.0014, 0.0019];

%R1_mat  = [.0109, .0029, .0013; .0069, .0024, .0012;...
    %.0047, .0026, .0013; .0034, .0016, .001; .0033, .0023, .0014;...
    %.0033, .0018, .0011; .0028, .0017, .0011];  % First polarization resistance, R1(SOC,T), (ohm)
% First polarization resistance, R1(SOC,T), (Ohm), (Simplified) | (7x3)
R1_mat  = [0.0109, 0.0069, 0.0047;
    0.0034, 0.0033, 0.0033;
    0.0028, 0.0029, 0.0024;
    0.0026, 0.0016, 0.0023;
    0.0018, 0.0017, 0.0013;
    0.0012, 0.0013, 0.0010;
    0.0014, 0.0011, 0.0011];

%tau1_mat = [20, 36, 39; 31, 45, 39; 109, 105, 61;...
    %36, 29, 26; 59, 77, 67; 40, 33, 29; 25, 39, 33]; % First time constant, tau1(SOC,T), (s)
% First time constant, tau(SOC,T), (s), (Simplified) | (7x3)
tau1_mat = [20, 31, 109;
    36, 59, 40;
    25, 36, 45;
   105, 29, 77;
    33, 39, 39;
    39, 61, 26;
    67, 29, 33];

%cell_area = 0.1019; % Cell area (m^2)
% Cell area (m^2)
cell_area = 0.03632; % Length*Width = 0.160*0.227

h_conv    = 5;      % Heat transfer coefficient (W/(K*m^2))

%% Kalman Filter
Q    = [1e-4 0 0;0 1e-4 0;0 0 1e-4]; % Covariance of the process noise, Q
R    = 0.05;                         % Covariance of the measurement noise, R
P0   = [1e-5 0 0; 0 1 0; 0 0 1e-5];  % Initial state error covariance, P0
SOC0 = initialSOC;                   % Estimator initial SOC 
R00  = 0.008;                        % Estimator initial R0 
Ts   = 1;                            % Sample time (s)

%% Fade %%
% Vector of discharge cycle values, (N), (Datasheet Derived) | (100x1)
N0vecDatasheet = [0;66;131;196;261;326;391;456;521;586;651;716;781;846;911;976;1041;1106;1171;1236;1301;1366;1431;1496;1561;1626;1691;1756;1821;1886;1951;2016;2081;2146;2211;2276;2341;2406;2471;2536;2601;2666;2731;2796;2861;2926;2991;3056;3121;3186;3251;3316;3381;3446;3511;3576;3641;3706;3771;3836;3901;3966;4031;4096;4161;4226;4291;4356;4421;4486;4551;4616;4681;4746;4811;4876;4941;5006;5071;5136;5201;5266;5331;5396;5461;5526;5591;5656;5721;5786;5851;5916;5981;6046;6111;6176;6241;6306;6371;6436];

% Vector of discharge cycle values, (N), (Simplified) | (1x6)
N0vec = [0, 1288/100, 2575/100, 3862/100, 5149/100, 6436/100]; % Divided by 100 for simulation purposes

% Vector of temperatures for fade data, Tfade (K), (Datasheet Derived) | (1x4)
Tfadevec = [298.15, 308.15, 318.15, 328.15]; % [25, 35, 45, 55] (°C)

% Percentage change in open-circuit voltage, dV0(N), (Datasheet Derived) | (100x1)
dV0matDatasheet = [0;-0.3227;-0.6453;-0.9509;-1.1187;-1.2594;-1.4;-1.5407;-1.6219;-1.683;-1.7439;-1.8049;-1.8602;-1.9134;-1.9665;-2.0196;-2.0441;-2.0544;-2.0647;-2.075;-2.085;-2.0949;-2.1048;-2.1146;-2.1183;-2.1198;-2.1212;-2.1226;-2.1259;-2.1303;-2.1347;-2.1391;-2.1431;-2.1462;-2.1493;-2.1524;-2.1556;-2.1591;-2.1625;-2.166;-2.1695;-2.1729;-2.1764;-2.1798;-2.1833;-2.1867;-2.1902;-2.1936;-2.197;-2.2002;-2.2034;-2.2067;-2.2106;-2.2156;-2.2206;-2.2256;-2.2316;-2.2405;-2.2493;-2.2582;-2.2676;-2.2798;-2.292;-2.3042;-2.3164;-2.3294;-2.3424;-2.3556;-2.3688;-2.3818;-2.3947;-2.4077;-2.4207;-2.4336;-2.4465;-2.4594;-2.4722;-2.485;-2.4978;-2.5106;-2.5233;-2.5361;-2.5489;-2.5617;-2.5745;-2.5872;-2.5999;-2.6126;-2.6253;-2.6381;-2.6508;-2.6635;-2.6765;-2.6898;-2.703;-2.7163;-2.7295;-2.7428;-2.756;-2.7693];

% Percentage change in open-circuit voltage, dV0(N), (Simplified) | (6x4)
dV0mat = [0, -1.1615, -1.6591, -1.9088;
   -2.0566, -2.1001, -2.1210, -2.1353;
   -2.1506, -2.1651, -2.1800, -2.1948;
   -2.2092, -2.2313, -2.2708, -2.3237;
   -2.3801, -2.4358, -2.4911, -2.5461;
   -2.6010, -2.6558, -2.7123, -2.7693];

% Percentage change in terminal resistance, dR0(N), (Parameter Assumed) | (100x1) 
dR0matDatasheet = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];

% Percentage change in terminal resistance, dR0(N), (Simplified) | (6x4)
dR0mat = [0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0];

% Percentage change in cell capacity, dAH(N), (Datasheet) | (100x1)
dAHmatDatasheet = [0;-0.319;-0.638;-0.939;-1.189;-1.439;-1.688;-1.938;-2.188;-2.435;-2.682;-2.93;-3.177;-3.424;-3.671;-3.918;-4.169;-4.421;-4.673;-4.925;-5.177;-5.429;-5.681;-5.933;-6.185;-6.437;-6.683;-6.917;-7.152;-7.386;-7.621;-7.855;-8.09;-8.324;-8.558;-8.793;-9.033;-9.292;-9.551;-9.809;-10.068;-10.327;-10.586;-10.845;-11.104;-11.363;-11.622;-11.88;-12.132;-12.374;-12.616;-12.857;-13.099;-13.341;-13.582;-13.824;-14.066;-14.307;-14.549;-14.791;-15.035;-15.281;-15.526;-15.772;-16.017;-16.263;-16.508;-16.757;-17.007;-17.256;-17.506;-17.755;-18.005;-18.254;-18.504;-18.752;-18.999;-19.246;-19.493;-19.74;-19.986;-20.233;-20.48;-20.727;-20.973;-21.219;-21.464;-21.71;-21.955;-22.201;-22.446;-22.692;-22.943;-23.199;-23.455;-23.711;-23.966;-24.222;-24.478;-24.733];

% Percentage change in cell capacity, dAH(N), (Datasheet) | (6x4)
dAHmat = [ 0, -1.2651, -2.3383, -3.4025;
   -4.4758, -5.5605, -6.6402, -7.6515;
   -8.6602, -9.7417, -10.8563, -11.9677;
  -13.0148, -14.0555, -15.0992, -16.1560;
  -17.2235, -18.2975, -19.3641, -20.4263;
  -21.4854, -22.5423, -23.6331, -24.7330];

% Percentage change in first polarization resistance, dR1(N, Tfade)
dR1mat = [0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0;
     0, 0, 0, 0];

%% Calendar Aging %%
% Simplified vector of time intervals, (Days), (Datasheet) | (1x3)
storage_dt_age_vec = [0, 500, 1000]; % [0, 43200000, 86400000] Seconds

% Vector of storage temperatures, (K), (Datasheet) | (1x3)
storage_T_age_vec = [296.15, 308.15, 318.15]; % [23, 35, 45] °C 

% Vector of sampled temperatures for capacity calendar aging, T_ac, (K)
T_age_vec_capacity = storage_T_age_vec;  % Same as storage temperatures

% Vector of sampled storage time intervals for capacity calendar aging, t_ac, (s), (Datasheet) | (1x3)
dt_age_vec_capacity = storage_dt_age_vec;

% Percentage change in capacity due to calendar aging, dAH(t_ac,T_ac), (Datasheet) | (3x3)
dAH_age_mat = [
    0, -2, -5;     % 23°C
    0, -3.5, -9;   % 35°C
    0, -6, -12     % 45°C
];

%% Initial Targets %%
% Current (positive in), (A)
i = 6;

% Terminal voltage, (V)
v = 2.9322;

% Discharge cycles
num_cycles = 0;

% Temperature, (K)
cell_temperature = 298.15; % 25 °C

%% Nominal Values %%
% Terminal voltage, (V)
v_nominal_value = 3.3;

% State of charge
% Battery final SOC
finalSOC = 1;

% Discharge cycles
num_cycles_nominal_value = 6436/100; % Divided by 100 for simulation purposes