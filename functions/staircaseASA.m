function [int_next, done] = staircaseASA(int_list, resp_list, desiredThreshold, maxInitialStepSize, stoppingStep)
%
% Adaptive staircase -- accelerated stochastic approximation
%
% the accelerated stochastic approximation is a non-parametric adaptive
% method to find rapidly a threshold. it was described by Kesten (1958).
%
% input:
%   int_list = list of intensities, including current intensity being displayed
%   resp_list = list of responses, including response to current intensity (0 = miss, 1 = hit)
%   desiredThreshold = desired threshold
%   maxInitialStepSize = maximum initial step size (in units of intensity)
%
% optional argument:
%   stoppingStep = lower limit for step as stopping criterion
%
% output:
%   int_next = next intensity to display
%   done = converged (1) or not yet (0)
%
% history:
% 2 nov 2007 -- pascal mamassian - wrote it


nn = length(int_list);      % number of intensities displayed so far (including current)
int_curr = int_list(end);   % current intensity being displayed
cc = maxInitialStepSize / max(desiredThreshold, 1-desiredThreshold);

mm = 0;                     % number of shifts in response categories
resp_prev = resp_list(1);
for ii = 2:nn
    resp_curr = resp_list(ii);
    if (resp_curr ~= resp_prev)
        mm = mm + 1;
    end
    resp_prev = resp_curr;
end

resp_curr = resp_list(end);

if (nn <= 2)
    int_next = int_curr - (cc / nn) * (resp_curr - desiredThreshold);
else
    int_next = int_curr - (cc / (2 + mm)) * (resp_curr - desiredThreshold);
end

if (nargin > 4)
    done = (abs(int_next - int_curr) < stoppingStep);
end
