clear;
format long g

% load MAT-file containing NGSIM dataset
dataset = load('DatasetUS101_0820to0835_wGaps'); 

%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT: mandatory %%%
%%%%%%%%%%%%%%%%%%%%%%%%
lane = 4; % lane number
startTime = 750; % start time relative to start of sampling (sec)
endTime = 900; % end time relative to start of sampling (sec)
frontVehicleId = 1716; 

% calculate epoch startTime and endTime (ms)
eStartTime = startTime*1e3 + dataset.GlobalTime(1,1);
eEndTime = endTime*1e3 + min(dataset.GlobalTime);

% UNCOMMENT NEXT 2 LINES if more than one following vehicle is present
followingVehicleId = 1720
frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 & dataset.FollowingVehicle(:,1)==followingVehicleId );

% COMMENT NEXT 1 LINE if more than one following vehicle is present
%frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 );

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
%relativeSpeed = followingVehicleSpeed-frontVehicleSpeed;
selectedLane = dataset.LaneIdentification(frontVehicleDatasetRows); %front
frontVehicleGlobalX = dataset.GlobalX(frontVehicleDatasetRows);
followingVehicleGlobalX = dataset.GlobalX(followingVehicleDatasetRows);
followingVehicleGap = dataset.Gap(followingVehicleDatasetRows);
selectedSampleTimes = dataset.GlobalTime(followingVehicleDatasetRows);


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

%%% Position, Headway, Relative Speed vs Time %%%
figure (3)

% position-time graph
subplot(3,1,1)
plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX-min(dataset.GlobalX),'g'); hold on
if frontVehicleId~=0,
    plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX(find(selectedVehicleIds==frontVehicleId),:)-min(dataset.GlobalX),'b'); hold on
    plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX(find(selectedVehicleIds==followingVehicleId),:)-min(dataset.GlobalX),'r'); 
end
title('Position-Time Graph of Vehicles on a Lane')
xlabel('time (s)')
ylabel('x-position (ft)')
grid minor

% gap-time graph
subplot(3,1,2)
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,ft2m(followingVehicleGap),'.');
title('Gap-Time Relationship');
xlabel('Time (s)');
ylabel('Gap (m)');
grid minor

% speed-time graph
subplot(3,1,3)
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,ft2m(frontVehicleSpeed),'.'); hold on
plot((selectedSampleTimes-min(dataset.GlobalTime))/1e3,ft2m(followingVehicleSpeed),'.'); hold on
title('Speed-Time relationship');
xlabel('Time (s)');
ylabel('Speed (m/s)');
legend('front car','following car')
grid minor

