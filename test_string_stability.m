clear;

% IDM Parameters
v0 = kmh2ms(120); % convert [km/h] to [m/s]
T = 1.7; % [s]
s0 = 2; % [m]
a = 1; % [m/s^2]
b = 1.5; % [m/s^2]
delta = 4;


v_eq = kmh2ms(60); % steady-state equilibrium speed [km/h] -> [m/s]
gap_eq = fCalcEq_gap(v_eq,s0,T,v0,delta); % steady-state equilibrium gap [m]

% calculate stability criterion
% (gap_eq,v_eq,s0,T,v0,delta)
sensitivity = fSensitivityIDM(gap_eq,v_eq,s0,T,v0,delta);

% calculate IDM string stability criterion
% (T,s0,a,b,v_eq,gap_eq,sensitivity)
[sensitivity2,ssCriterion,stable] = fStringStabilityCriterionIDM(T,s0,a,b,v_eq,gap_eq,sensitivity);