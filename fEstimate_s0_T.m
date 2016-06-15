% LYNN CHAN, EE4, 2016, Imperial College.
% 28/05/2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate IDM Parameters s0 and T at Steady-State Equilibrium
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% v = vector of average equilibrium speeds [m/s]
% gap = vector of average equilibrium gaps [m]
% v0 = desired speed [m/s]
% delta = acceleration exponent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% est_s0 = estimated minimum gap s0
% est_T = estimated time gap T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [est_s0, est_T] = fEstimate_s0_T(v,gap,v0,delta) 

% The MATLAB function fmincon minimises the objective function
%   abs((s0+v*T)/sqrt(1-(v/v0)^delta)-gap)
%  with constraints 
%   s0 = [0,2.5] and T = [0,2]

% For each pair of equilibrium speed and gap, estimate the corresponding
% minimum gap and time gap. 

lb = [0.3,0.3]; % lower bound of [s0, T]
ub = [3,3]; % upper bound of [s0, T]
A = []; b = []; Aeq = []; beq = []; % no linear constraints
x0 = [1.5,1]; % try initial points s0=1.5 and T = 1

for n=1:length(v),
    % objective function with x(1)=s0, x(2)=T
    fun = @(x)abs((x(1)+v(n)*x(2))/sqrt(1-(v(n)/v0)^delta)-gap(n));
    x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub); % find minimum
    est_s0(n) = x(1);
    est_T(n) = x(2);
end

end