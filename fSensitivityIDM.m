% LYNN CHAN, EE4, 2016, Imperial College.
% 31/05/2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute IDM sensitivity v_eq'(gap_eq)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% gap_eq = steady-state equilibrium gap [m]
% v_eq =  steady-state equilibrium speed [m/s]
% s0 = minimum gap [m]
% T = desired time gap [s]
% v0 = desired speed [m/s]
% delta = acceleration exponent [m/s^2]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% sensitivity, evaluated at steady-state point (gap_eq, v_eq)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sensitivity] = fSensitivityIDM(gap_eq,v_eq,s0,T,v0,delta)

sensitivity = ((2/gap_eq)*((s0+v_eq*T)/gap_eq)^2) / ...
    ( (delta/v0)*(v_eq/v0)^(delta-1) + ...
    ((2*T*(s0+v_eq*T))/(gap_eq^2)) );

end