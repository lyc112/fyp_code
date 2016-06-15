% LYNN CHAN, EE4, 2016, Imperial College.
% 22/05/2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate string stability criterion for Intelligent Driver Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% T = time gap [s]
% s0 = minimum gap [m]
% a = acceleration [m/s^2]
% b = comfortable decceleration [m/s^2]
% v_eq = steady-state equilibrium speed [m/s]
% gap_eq = steady-state equilibrium gap [m]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% ssCriterion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sensitivity2,ssCriterion,stable] = fStringStabilityCriterionIDM(T,s0,a,b,v_eq,gap_eq,sensitivity) 
    sensitivity2 = sensitivity^2;
    ssCriterion = (a*(s0+v_eq*T)/gap_eq^2)*( (s0+v_eq*T)/gap_eq + (v_eq*sensitivity)/sqrt(a*b) );
    if sensitivity2<=ssCriterion,
        stable = true;
    else
        stable = false;
    end
end