clear;

% INPUT: Dataset 
dataset = load('DatasetUS101_0820to0835_wGaps'); % MAT-file NGSIM dataset
lane = 4; % lane number
startTime = 750; % start time relative to start of sampling (sec)
endTime = 950; % end time relative to start of sampling (sec)

% INPUT: IDM Parameters
a = 1.1; % acceleration [m/s^2]
b = 1.5; % comfortable decceleration [m/s^2]
v0 = 120/3.6; % desired speed [m/s]
delta = 4; % acceleration exponent
frontVehicleId = 1716;

% calculate epoch startTime and endTime (ms)
eStartTime = startTime*1e3 + dataset.GlobalTime(1,1);
eEndTime = endTime*1e3 + min(dataset.GlobalTime);

% UNCOMMENT NEXT 2 LINES if more than one following vehicle is present
%followingVehicleId = 1720
%frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 & dataset.FollowingVehicle(:,1)==followingVehicleId );
% COMMENT NEXT 1 LINE if more than one following vehicle is present
frontVehicleDatasetRows = ( dataset.VehicleId(:,1)==frontVehicleId & dataset.FollowingVehicle~=0 );
followingVehicleId = unique(dataset.FollowingVehicle(frontVehicleDatasetRows));
if length(followingVehicleId)> 1, % check that there is only one following vehicle for the selected time frame
    fprintf('ERROR: more than one following vehicle is present for the selected time frame.\n');
    return;
end
followingVehicleDatasetRows = ( dataset.VehicleId(:,1)==followingVehicleId & dataset.PrecedingVehicle(:,1)==frontVehicleId & dataset.GlobalTime(:,1)>eStartTime & dataset.GlobalTime(:,1)<eEndTime );

% Extract Front and Following Vehicle Data from Dataset %%%
followingVehicleSpeed = dataset.VehicleVelocity(followingVehicleDatasetRows);
frontVehicleSpeed = dataset.VehicleVelocity(frontVehicleDatasetRows);
followingVehicleGap = dataset.Gap(followingVehicleDatasetRows);
selectedSampleTimes = dataset.GlobalTime(followingVehicleDatasetRows);

% Average steady-state equilibrium gap and speed
minEqInterval = 1;
maxAbsRelSpeed = 0.2;
maxGapChange = 0.2;
maxSpeedChange = 0.2;
% Get estimates of steady-state equilibrium gaps and speeds
[gap_eq, v_eq] = fEstimateEq_gap_v(ft2m(followingVehicleGap),ft2m(followingVehicleSpeed),...
    ft2m(frontVehicleSpeed),minEqInterval,maxAbsRelSpeed,maxGapChange,...
    maxSpeedChange);
% check that there was an approximate steady-state equilibrium
if isempty(gap_eq), 
    fprintf('ERROR: No approximate steady-state equilibrium for given constraints.\n');
    return;
end

% Estimate values of s0 and T
[est_s0, est_T] = fEstimate_s0_T(v_eq,gap_eq,v0,delta);

%est_s0=2; est_T=1.5; a=1.4; b=2; gap_eq=39.4430456;

% Compute IDM sensitivity from partial derivatives of acceleration function
index = 1;
sensitivity = fSensitivityIDM(gap_eq(index),v_eq(index),est_s0(index),...
    est_T(index),v0,delta);

% Compute IDM string stability criterion (using most recent equilibrium estimates)
[sensitivity2,ssCriterion,stable] = fStringStabilityCriterionIDM(...
    est_T(index),est_s0(index),a,b,v_eq(index),gap_eq(index),sensitivity);

% % Estimate IDM 
% lb = [0]; % lower bound of [a, b]
% ub = [3]; % upper bound of [a, b]
% A = []; bb = []; Aeq = []; beq = []; % no linear constraints
% x0 = [1.5]; % try initial points
% followingVehicleAcc = dataset.VehicleAcceleration(followingVehicleDatasetRows);
% relativeSpeed = followingVehicleSpeed-frontVehicleSpeed;
% index1 = 247;
% acc = ft2m(followingVehicleAcc(index1));
% v = ft2m(followingVehicleSpeed(index1));
% gap = ft2m(followingVehicleGap(index1));
% relSpeed = ft2m(followingVehicleSpeed(index1)-frontVehicleSpeed(index1));
% %idm = x(1)*( 1 - (v/v0)^delta - ( est_s0(index)+v*est_T+(v*relSpeed)/(2*sqrt(x(1)*x(2))) / gap )^2 );
% 
% % objective function with x(1)=a, x(2)=b
% fun = @(x)acc - x(1)*( 1 - (v/v0)^delta - ( ( est_s0(index)+v*est_T(index)+(v*relSpeed)/(2*sqrt(x(1)*b)) ) / gap )^2 );
% x = fmincon(fun,x0,A,bb,Aeq,beq,lb,ub); % find minimum
% est_a = x(1);
% est_b = x(2);


