% Code to plot simulation results from BatteryCellBalancingExample
%% Plot Description:
%
% The plot below shows the cell state-of-charge values.

% Copyright 2022 The MathWorks, Inc.

% Generate simulation results if they don't exist
if ~exist('BatteryCellBalancingSimlogSimlog', 'var') || ...
        get_param('BatteryCellBalancing','RTWModifiedTimeStamp') == double(simscape.logging.timestamp(BatteryCellBalancingSimlog)) 
    sim('BatteryCellBalancing')
    % Model StopFcn callback adds a timestamp to the Simscape simulation data log
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_BatteryCellBalancing', 'var') || ...
        ~isgraphics(h1_BatteryCellBalancing, 'figure')
    h1_BatteryCellBalancing = figure('Name', 'BatteryCellBalancing');
end
figure(h1_BatteryCellBalancing)
clf(h1_BatteryCellBalancing)

% Get simulation results
simlog_SOC1 = BatteryCellBalancingLogsout.get('soc1');
simlog_SOC2 = BatteryCellBalancingLogsout.get('soc2');

% Plot results
plot(simlog_SOC1.Values.Time/3600, simlog_SOC1.Values.Data(:)*100, 'LineWidth', 1)
hold on
plot(simlog_SOC2.Values.Time/3600, simlog_SOC2.Values.Data(:)*100, 'LineWidth', 1)
hold off
grid on
title('State-of-charge')
ylabel('SOC (%)')
xlabel('Time (hours)')
legend({'Cell 1','Cell 2'},'Location','Best');

% Remove temporary variables
clear simlog_SOC1 simlog_SOC2