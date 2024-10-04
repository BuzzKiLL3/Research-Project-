%% Battery Passive Cell Balancing
% This example shows how to balance a battery with two cells connected in 
% series by using a passive cell balancing algorithm. The initial 
% state-of-charge (SOC) for the two cells are equal to 0.7 and 0.75. The 
% balancing procedure depends on the cell voltages. Alternatively, you can 
% use the SOC values for balancing. When the balancing is active, a 
% bleeding resistor switches on to bleed the cells with higher charge. You 
% can use the objects and functions in the Battery Pack Model Builder to 
% generate more complex battery packs.

% Copyright 2022 The MathWorks, Inc.

%% Model

open_system('BatteryCellBalancing')

set_param(find_system('BatteryCellBalancing','FindAll', 'on','type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Simulation Results
%
% The plot below shows the cell state-of-charge values.
%


BatteryCellBalancingPlotSOC;

%% Results from Real-Time Simulation
%%
%
% This example has been tested on a Speedgoat Performance real-time target 
% machine with an Intel(R) 3.5 GHz i7 multi-core CPU. This model can run 
% in real time with a step size of 70 microseconds.
