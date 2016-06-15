clear;

% calculate time gaps from dataset

% dataset.Headway is time to travel from the front-center of following
% vehilce to front-center of preceding vehicle

dataset = load('DatasetUS101_0750to0805_wGaps.mat');

% get preceding vehicle lengths
vehicleLengthsById = unique([dataset.VehicleId dataset.VehicleLength],'rows');

precedingIds = dataset.PrecedingVehicle;
                
timeGaps = NaN(size(precedingIds));
for n=1:length(precedingIds),
    if dataset.PrecedingVehicle(n)==0,
        precedingLength = NaN;
    else
        precedingLength = vehicleLengthsById(find(vehicleLengthsById(:,1)==precedingIds(n)),2);
    end
    timeGaps(n,1) = dataset.Headway(n) - (0.5*dataset.VehicleLength(n)+0.5*precedingLength)/dataset.VehicleVelocity(n);
end