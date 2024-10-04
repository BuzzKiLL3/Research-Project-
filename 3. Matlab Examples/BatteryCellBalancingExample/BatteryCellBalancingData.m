%% Parameters for Battery Passive Cell Balancing
% 
% This example shows how to balance a battery with two cells connected in 
% series by using a passive cell balancing algorithm. The initial 
% state-of-charge (SOC) for the two cells are equal to 0.7 and 0.75. The 
% balancing procedure depends on the cell voltages. Alternatively, you can 
% use the SOC values for balancing. When the balancing is active, a 
% bleeding resistor switches on to bleed the cells with higher charge. You 
% can use the objects and functions in the Battery Pack Model Builder to 
% generate more complex battery packs.

% Copyright 2022 The MathWorks, Inc.

%% System Parameters
SOC_vec = [0, .1, .25, .5, .75, .9, 1]; % Vector of state-of-charge values, SOC
T_vec   = [278, 293, 313];              % Vector of temperatures, T, (K)
AH      = 27;                           % Cell capacity, AH, (A*hr) 
thermal_mass = 100;                     % Thermal mass (J/K)
initialSOC1 = 0.7;                      % Cell 1 initial SOC
initialSOC2 = 0.75;                     % Cell 2 initial SOC
V0_mat  = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64;...
    3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08;...
    4.19, 4.19, 4.19];                          % Open-circuit voltage, V0(SOC,T), (V)
R0_mat  = [.0117, .0085, .009; .011, .0085, .009;...
    .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091;...
    .0113, .0085, .0089; .0116, .0085, .0089];  % Terminal resistance, R0(SOC,T), (ohm)

R1_mat  = [.0109, .0029, .0013; .0069, .0024, .0012;...
    .0047, .0026, .0013; .0034, .0016, .001; .0033, .0023, .0014;...
    .0033, .0018, .0011; .0028, .0017, .0011];  % First polarization resistance, R1(SOC,T), (ohm)
tau1_mat = [20, 36, 39; 31, 45, 39; 109, 105, 61;...
    36, 29, 26; 59, 77, 67; 40, 33, 29; 25, 39, 33]; % First time constant, tau1(SOC,T), (s)

cell_area = 0.1019; % Cell area (m^2)
h_conv    = 5;      % Heat transfer coefficient (W/(K*m^2))

%% Balancing Parameters
BalThreshold = 0.005;   % Threshold for cell balancing (V)
vMax         = 4.1;     % Maximum cell voltage
Ts           = 1;       % Sample time