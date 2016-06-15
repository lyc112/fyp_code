clear;

% calculate gaps from dataset

dataset = load('DatasetUS101_0820to0835_wGaps.mat');

vehicleLengthsById = unique([dataset.VehicleId dataset.VehicleLength],'rows');
precedingIds = dataset.PrecedingVehicle;
                
gaps = NaN(size(precedingIds));
for n=1:length(precedingIds),
    if dataset.PrecedingVehicle(n)==0,
        precedingLength = NaN;
    else
        precedingLength = vehicleLengthsById(find(vehicleLengthsById(:,1)==precedingIds(n)),2);
    end
    gaps(n,1) = dataset.Spacing(n) - precedingLength;
end