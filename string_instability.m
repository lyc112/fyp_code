clear;
format long g

% load MAT-file containing NGSIM dataset
dataset = load('DatasetUS101_0750to0805_wGaps'); 

%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT: mandatory %%%
%%%%%%%%%%%%%%%%%%%%%%%%
lane = 3; % lane number
startTime = 200; % start time relative to start of sampling (sec)
endTime = 350; % end time relative to start of sampling (sec)
%endTime = (max(dataset.GlobalTime)-min(dataset.GlobalTime))/1e3; % get entire duration of sampling (sec)
selectIndex = [40 1 10]; % index [ first multiple ]

% extract vehicle trajectories
[globalTimesAll, vehiclesGlobalX] = fExtractData(dataset,startTime,endTime,lane,dataset.GlobalX,selectIndex);

% extract vehicle velocities
[globalTimes, vehiclesVelocity] = fExtractData(dataset,startTime,endTime,lane,dataset.VehicleVelocity,selectIndex);

% extract vehicle spacings
[~, vehiclesGap] = fExtractData(dataset,startTime,endTime,lane,dataset.Gap,selectIndex);

% extract vehicle IDs
[~, vehiclesId] = fExtractData(dataset,startTime,endTime,lane,dataset.VehicleId,selectIndex);
vehiclesId = unique(vehiclesId);

figure (1)
subplot(3,1,1) % plot trajectories
plot((globalTimesAll-min(dataset.GlobalTime))/1e3, vehiclesGlobalX-min(dataset.GlobalX)); hold on
title('Position-Time Graph of Vehicles on a Lane')
xlabel('time (s)')
ylabel('x-position (ft)')
grid minor

subplot(3,1,2) % plot velocities
plot((globalTimes-min(dataset.GlobalTime))/1e3, vehiclesVelocity); hold on
title('Velocity-Time Graph of Vehicles on a Lane')
xlabel('time (s)')
ylabel('velocity (ft/sec)')
grid minor

subplot(3,1,3) % plot gaps
plot((globalTimes-min(dataset.GlobalTime))/1e3, vehiclesGap); hold on
title('Gap-Time Graph of Vehicles on a Lane')
xlabel('time (s)')
ylabel('gap (ft)')
grid minor