% LYNN CHAN, EE4, 2016, Imperial College.
% 22/05/2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimates of steady-state equilibrium speed and gap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% followingVehicleGap [m/s] = vector of gaps between leading and 
% followingVehicleSpeed [m/s] = vector of following vehicle speeds
% frontVehicleSpeed [m/s] = vector of leading vehicle speeds
%   following vehicle
% minEqInterval [s] = minimum interval over which speeds and gaps are
%   approximately at steady-state equilibrium
% maxAbsRelSpeed [m/s] = maximum tolerable absolute relative speed between
%   leading and following vehicle per unit time
% maxGapChange [m] = maximum tolerable deviation in gaps between leading
%   and following vehicle within minEqInterval
% maxSpeedChange [m/s] = maximum tolerable deviation in following
%   vehicle speeds within minEqInterval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% v_eq = vector of steady-state equilibrium speeds
% gap_eq = vector of steady-state equilibrium gaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [gap_eq, v_eq] = fEstimateEq_gap_v(followingVehicleGap,...
    followingVehicleSpeed,frontVehicleSpeed,minEqInterval,...
    maxAbsRelSpeed,maxGapChange,maxSpeedChange)

% initialise counters and stores
minCount = minEqInterval*10;
count = 0;
gap_store = []; v_store = [];
count2 = 0;
gap_eq = []; v_eq = [];

% calculate absolute relative speed
absRelSpeed = abs(followingVehicleSpeed-frontVehicleSpeed);

for n=1:length(followingVehicleSpeed),

    % IF relative speed not ok, reset count and v_store
    if absRelSpeed(n)>maxAbsRelSpeed,
        % if sufficient equiblibrium interval, calculate eq gap and speed
        if count >= minCount,
            count2 = count2+1;
            % calculate average speed in equilibrium interval
            v_eq(count2) = mean(v_store);
            gap_eq(count2) = mean(gap_store);
        end
        
        count = 0;
        v_store = [];
        gap_store = [];
    end
    
    % IF speed difference between the leader and follower is less than the
    % maximum tolerable speed difference, and count=0, store the current 
    % following vehicle speed and gap
    if absRelSpeed(n)<=maxAbsRelSpeed & count==0,
        count = 1;
        v_store(count) = followingVehicleSpeed(n);
        gap_store(count) = followingVehicleGap(n);
    
    % IF relative speed is still ok, next gap is ok
    elseif count > 0 & absRelSpeed(n)<=maxAbsRelSpeed ...
            & abs(v_store(1)-followingVehicleSpeed(n))<=maxSpeedChange ...
            & abs(gap_store(1)-followingVehicleGap(n))<maxGapChange,
        count = count + 1;
        v_store(count) = followingVehicleSpeed(n);
        gap_store(count) = followingVehicleGap(n);
    end
    
end

end