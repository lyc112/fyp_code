% LYNN CHAN, EE4, 2016, Imperial College.
% 09/06/2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate Equilibrium Gap for a given Equilibrium Speed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% v_eq = steady-state equilibrium speed [m/s]
% s0 = minimum gap [m]
% T = vector of average equilibrium gaps [m]
% v0 = desired speed [m/s]
% delta = acceleration exponent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% gap_eq = estimated minimum gap s0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [gap_eq] = fCalcEq_gap(v_eq,s0,T,v0,delta) 

gap_eq = (s0+v_eq*T)/sqrt(1-(v_eq/v0)^delta);

end