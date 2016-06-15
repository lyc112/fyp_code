% LYNN CHAN, EE4, 2016, Imperial College.
% 19/05/2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extracts Data from Dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% dataset = dataset containing trajectory data [struct]
% startTime = start time of data to extract [s]
% endTime = end time of data to extract [s]
% lane = lane identification number
% datasetVariable = dataset.[fieldName] 
% selectIndex = [ beginningIndex, multiple ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% GlobalTimeOut = GlobalTime values from dataset (epoch)
% DataOut = values of dataset.[fieldName]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [GlobalTimeOut,DataOut]=fExtractData(dataset,startTime,endTime,lane,datasetVariable,selectIndex)

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
                   
% selected dataset based on input constraints
selectedDataset = [ dataset.GlobalTime(selectedDatasetRows,1) dataset.VehicleId(selectedDatasetRows,1) datasetVariable(selectedDatasetRows,1) ];
% set of GlobalTimes in selected timeframe
selectedSampleTimes = unique(dataset.GlobalTime(selectedDatasetRows,1)); 
% set of VehicleIds in selected timeframe
selectedVehicleIds = unique(dataset.VehicleId(selectedDatasetRows,1)); 
selectedVehicleIds = selectedVehicleIds(selectIndex(1):selectIndex(2):end-selectIndex(3));
% create a table with a single column of selectedSampleTimes
selectedSampleTimesTable = table(selectedSampleTimes); 

% extract vehicle data
DataOut = NaN(length(selectedVehicleIds),length(selectedSampleTimes));
for n=1:length(selectedVehicleIds), 
    nFilteredSelectedDataset = selectedDataset( selectedDataset(:,2)==selectedVehicleIds(n),: );
    selectedSampleTimes = nFilteredSelectedDataset(:,1);
    nDataOut = nFilteredSelectedDataset(:,end); % DataOut values of VehicleId(n)
    % outerjoin matches DataOut values to (initial) selectedSampleTimes
    % if DataOut does not exist at a sample time, DataOut is assigned NaN 
    outerjoinTables = outerjoin( selectedSampleTimesTable,table(selectedSampleTimes, nDataOut) ); 
    DataOut(n,:) = table2array(outerjoinTables(:,3))';
end

GlobalTimeOut = unique(dataset.GlobalTime(selectedDatasetRows,1));

end