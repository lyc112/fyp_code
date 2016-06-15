clear all;
format long g

% load MAT-file containing NGSIM dataset
dataset = load('DatasetUS101_0820to0835_wGaps'); 

%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT: mandatory %%%
%%%%%%%%%%%%%%%%%%%%%%%%
lane = 4; % lane number
startTime = 750; % start time relative to start of sampling (sec)
endTime = 950; % end time relative to start of sampling (sec)
%endTime = (max(dataset.GlobalTime)-min(dataset.GlobalTime))/1e3; % get entire duration of sampling (sec)

% calculate epoch startTime and endTime (ms)
eStartTime = startTime*1e3 + dataset.GlobalTime(1,1);
eEndTime = endTime*1e3 + min(dataset.GlobalTime);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT: (optional) %%%
% append below to set additional constraints here (e.g. specific VehicleIds to observe)
%%%%%%%%%%%%%%%%%%%%%%%%%
selectedDatasetRows = ( dataset.GlobalTime(:,1)>eStartTime & ... % start time
                        dataset.GlobalTime(:,1)<eEndTime & ... % end time
                        dataset.LaneIdentification==lane ... % lane 
                       );
frontVehicleId = 1679; % choose '0' to select none

% selected dataset based on input constraints
selectedDataset = [ dataset.GlobalTime(selectedDatasetRows,1) dataset.VehicleId(selectedDatasetRows,1) dataset.GlobalX(selectedDatasetRows,1) ];
% set of GlobalTimes in selected timeframe
selectedSampleTimes = unique(dataset.GlobalTime(selectedDatasetRows,1)); 
% set of VehicleIds in selected timeframe
selectedVehicleIds = unique(dataset.VehicleId(selectedDatasetRows,1)); 
% create a table with a single column of selectedSampleTimes
selectedSampleTimesTable = table(selectedSampleTimes); 

% following vehicle ID
if frontVehicleId~=0,
    frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 & dataset.GlobalTime(:,1)>eStartTime & dataset.GlobalTime(:,1)<eEndTime );
    
    % COMMENT NEXT 1 LINE if more than one following vehicle is present
    followingVehicleId = unique(dataset.FollowingVehicle(frontVehicleDatasetRows));
    
    % UNCOMMENT NEXT 1 LINE if more than one following vehicle is present
    %followingVehicleId = 1720 % enter ID of one following vehicle
end

vehiclesGlobalX = NaN(length(selectedVehicleIds),length(selectedSampleTimes));
for n=1:length(selectedVehicleIds), 
    nFilteredSelectedDataset = selectedDataset( selectedDataset(:,2)==selectedVehicleIds(n),: );
    selectedSampleTimes = nFilteredSelectedDataset(:,1);
    nGlobalX = nFilteredSelectedDataset(:,end); % GlobalX values of VehicleId(n)
    % outerjoin matches GlobalX values to (initial) selectedSampleTimes
    % if GlobalX does not exist at a sample time, GlobalX is assigned NaN 
    outerjoinTables = outerjoin( selectedSampleTimesTable,table(selectedSampleTimes, nGlobalX) ); 
    vehiclesGlobalX(n,:) = table2array(outerjoinTables(:,3))';
end

figure (2)
plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX-min(dataset.GlobalX),'g'); hold on
if frontVehicleId~=0,
    plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX(find(selectedVehicleIds==frontVehicleId),:)-min(dataset.GlobalX),'b'); hold on
    plot((unique(dataset.GlobalTime(selectedDatasetRows,1))-min(dataset.GlobalTime))/1e3, vehiclesGlobalX(find(selectedVehicleIds==followingVehicleId),:)-min(dataset.GlobalX),'r'); 
end
title('Position-Time Graph of Vehicles on a Lane')
xlabel('time (s)')
ylabel('x-position (ft)')