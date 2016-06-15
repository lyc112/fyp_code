clear all;
format long g

% load MAT-file containing NGSIM dataset
dataset = load('DatasetUS101_0750to0805_wGaps'); 

%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT: mandatory %%%
%%%%%%%%%%%%%%%%%%%%%%%%
lane = 1; % lane number
startTime = 120; % start time relative to start of sampling (sec)
endTime = 280; % end time relative to start of sampling (sec)
%endTime = (max(dataset.GlobalTime)-min(dataset.GlobalTime))/1e3; % get entire duration of sampling (sec)
frontVehicleId = 756;

% calculate epoch startTime and endTime (ms)
eStartTime = startTime*1e3 + dataset.GlobalTime(1,1);
eEndTime = endTime*1e3 + min(dataset.GlobalTime);

%%% OPTION A: set vehicle ID and start/end time
%frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 & dataset.GlobalTime(:,1)>eStartTime & dataset.GlobalTime(:,1)<eEndTime );
%%% OPTION B: set vehicle ID
frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 );

followingVehicleId = unique(dataset.FollowingVehicle(frontVehicleDatasetRows));

if length(followingVehicleId)> 1, % check that there is only one following vehicle for the selected time frame
    fprintf('ERROR: more than one following vehicle is present for the selected time frame.\n');
    return;
end

%%% OPTION A: set vehicle ID and start/end time
followingVehicleDatasetRows = ( dataset.VehicleId(:,1)==followingVehicleId & dataset.PrecedingVehicle(:,1)==frontVehicleId & dataset.GlobalTime(:,1)>eStartTime & dataset.GlobalTime(:,1)<eEndTime );
%%% OPTION B: set vehicle ID only
%followingVehicleDatasetRows = ( dataset.VehicleId(:,1)==followingVehicleId & dataset.PrecedingVehicle(:,1)==frontVehicleId );


%%% Extract Front and Following Vehicle Data from Dataset %%%
followingVehicleSpeed = dataset.VehicleVelocity(followingVehicleDatasetRows);
frontVehicleSpeed = dataset.VehicleVelocity(frontVehicleDatasetRows);
relativeSpeed = followingVehicleSpeed-frontVehicleSpeed;
selectedSampleSpacings = dataset.Spacing(frontVehicleDatasetRows);
selectedSampleHeadways = dataset.Headway(followingVehicleDatasetRows);
selectedLane = dataset.LaneIdentification(frontVehicleDatasetRows); %front
frontVehicleGlobalX = dataset.GlobalX(frontVehicleDatasetRows);
followingVehicleGlobalX = dataset.GlobalX(followingVehicleDatasetRows);
selectedSampleTimes = dataset.GlobalTime(frontVehicleDatasetRows);

%%% Extract Trajectories of All Vehicles in Timeframe from Dataset %%%
selectedDatasetRows = ( dataset.GlobalTime(:,1)>=selectedSampleTimes(1) & dataset.GlobalTime(:,1)<=selectedSampleTimes(end) & dataset.LaneIdentification==unique(selectedLane) );
selectedDataset = [ dataset.GlobalTime(selectedDatasetRows,1) dataset.VehicleId(selectedDatasetRows,1) dataset.GlobalX(selectedDatasetRows,1) ];
allSelectedSampleTimes = unique(dataset.GlobalTime(selectedDatasetRows,1)); 
selectedVehicleIds = unique(dataset.VehicleId(selectedDatasetRows,1)); 
selectedSampleTimesTable = table(allSelectedSampleTimes); 
vehiclesGlobalX = NaN(length(selectedVehicleIds),length(allSelectedSampleTimes));
for n=1:length(selectedVehicleIds), 
    nFilteredSelectedDataset = selectedDataset( selectedDataset(:,2)==selectedVehicleIds(n),: );
    allSelectedSampleTimes = nFilteredSelectedDataset(:,1);
    nGlobalX = nFilteredSelectedDataset(:,end); % GlobalX values of VehicleId(n)
    % outerjoin matches GlobalX values to (initial) selectedSampleTimes
    % if GlobalX does not exist at a sample time, GlobalX is assigned NaN 
    outerjoinTables = outerjoin( selectedSampleTimesTable,table(allSelectedSampleTimes, nGlobalX) ); 
    vehiclesGlobalX(n,:) = table2array(outerjoinTables(:,3))';
end
                   
%%%%%%%%%%%%%%%%%%%
%%% Plot Graphs %%%
%%%%%%%%%%%%%%%%%%%
figure (2)

% speed-space relationship
subplot(2,3,2)
plot(frontVehicleSpeed,selectedSampleSpacings); hold on;
plot(frontVehicleSpeed(1),selectedSampleSpacings(1),'g*'); % marker at start point
plot(frontVehicleSpeed(end),selectedSampleSpacings(end),'r*'); % marker at end point
%plot(followingVehicleSpeed,selectedSampleSpacings);
title('Speed-Space relationship');
xlabel('Speed (ft/s)');
ylabel('Space (ft)');



subplot(2,3,1)
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,frontVehicleGlobalX-min(dataset.GlobalX)); hold on;
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,followingVehicleGlobalX-min(dataset.GlobalX));
title('Position-Time relationship');
xlabel('Time (s)');
ylabel('x-position (ft)');
legend('front car', 'following car');
grid on

% speed-headway relationship
subplot(2,3,3)
plot(followingVehicleSpeed,selectedSampleHeadways); hold on;
plot(followingVehicleSpeed(1),selectedSampleHeadways(1),'g*'); % marker at start point
plot(followingVehicleSpeed(end),selectedSampleHeadways(end),'r*'); % marker at end point
title('Speed-Headway relationship');
xlabel('Speed (ft/s)');
ylabel('Headway (s)');

% relative speed-space relationship
subplot(2,3,5)
plot(relativeSpeed,selectedSampleSpacings); hold on;
plot(relativeSpeed(1),selectedSampleSpacings(1),'g*'); % marker at start point
plot(relativeSpeed(end),selectedSampleSpacings(end),'r*'); % marker at end point
title('Relative Speed-Space relationship');
xlabel('Relative Speed (ft/s)');
ylabel('Space (ft)');

% relative speed-headway relationship
subplot(2,3,6)
plot(relativeSpeed,selectedSampleHeadways); hold on;
plot(relativeSpeed(1),selectedSampleHeadways(1),'g*'); % marker at start point
plot(relativeSpeed(end),selectedSampleHeadways(end),'r*'); % marker at end point
title('Relative Speed-Space relationship');
xlabel('Relative Speed (ft/s)');
ylabel('Headway (s)');

% headway-time graph
subplot(2,3,4)
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,selectedSampleHeadways,'.');
title('Headway-Time Relationship');
xlabel('Time (s)');
ylabel('Headway (s)');
grid on


%%% Position, Headway, Relative Speed vs Time %%%
figure (3)

% position-time graph
subplot(3,1,1)
% plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,frontVehicleGlobalX-min(dataset.GlobalX)); hold on;
% plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,followingVehicleGlobalX-min(dataset.GlobalX));
% title('Position-Time relationship');
% xlabel('Time (s)');
% ylabel('x-position (ft)');
% legend('front car', 'following car');
% grid on

plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX-min(dataset.GlobalX),'g'); hold on
if frontVehicleId~=0,
    plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX(find(selectedVehicleIds==frontVehicleId),:)-min(dataset.GlobalX),'b'); hold on
    plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX(find(selectedVehicleIds==followingVehicleId),:)-min(dataset.GlobalX),'r'); 
end
title('Position-Time Graph of Vehicles on a Lane')
xlabel('time (s)')
ylabel('x-position (ft)')

% headway-time graph
subplot(3,1,2)
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,selectedSampleHeadways,'.');
title('Headway-Time Relationship');
xlabel('Time (s)');
ylabel('Headway (s)');
grid on

% relative speed-time graph
subplot(3,1,3)
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,frontVehicleSpeed,'.'); hold on
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,followingVehicleSpeed,'.'); hold on
title('Speed-Time relationship');
xlabel('Time (s)');
ylabel('Speed (ft/s)');
legend('front car','following car')
grid on