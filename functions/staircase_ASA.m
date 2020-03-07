function stairs = staircase_ASA(action, stairs)
% This is a simple 1up-1down staircase converging to 50% correct value.
% Stairs stores the characteristics of the staircase and stores history
% It operates staircaseASA which is an adaptive staircase that follows
% the accelerated stochastic approximation. It is a non-parametric adaptive
% method to find rapidly a threshold, first described by Kesten (1958).
%
% Call the function once with action 'value' to get the intensity to show
% and another time when you have the response
% stairs.current_value is the displayed intensity (we convert it in log scale, so leave it in 
% linear scale), stairs.response is the response to that intensity.
% trial is the real trial id (can be different from stairs.trial which is
% staircase specific, when we have multiple staircases).
% stairs.next_value is the next chosen intensity value for that staircase.
% To use multiple staircase, just manage them outstide of staircase_ASA,
% calling it with a stairs structure for each staircase.
% stairs.history:
%       col 1:  stairs.trial
%       col 2:  intensity in linear units
%       col 3:  response - 0 left, 1 right 
%
% To initialize the staircase, you need: 
%       stairs.trial = 1
%       stairs.initial_value = in positive linear units 
%       stairs.desired_threshold = 0.50; %should converge toward 0.50
%       stairs.maxInitialStepSize 
%       stairs.maxStepNb - our stopping criteria is on the nb of trials by staircase only
% 

if strcmp(action,'value')
    % INITIALIZATION
    if stairs.trial == 1
        stairs.history=nan(stairs.maxStepNb,3);
        stairs.labels = {'stairs.trials','intensity','correct','next trial intensity'};
        stairs.current_value = stairs.initial_value;
        stairs.response = []; % first trial initialization
        stairs.history = []; % first trial initialization
        stairs.end = 0;
    else
    
        % find value to test
        stairs.current_value = staircaseASA((stairs.history(:,2)), stairs.history(:,3), stairs.desired_threshold, (stairs.maxInitialStepSize));
       % stairs.current_value = 10.^stairs.current_value;
       if abs(stairs.current_value)>stairs.max
           stairs.current_value = sign(stairs.current_value).*stairs.max;
       end
    end
elseif strcmp(action,'record') % and update
     stairs.history(stairs.trial,:) = [stairs.trial, stairs.current_value, stairs.response];

    % ENDING
    if stairs.trial == stairs.maxStepNb
        stairs.end = 1;
    else
        stairs.trial = stairs.trial + 1;
    end
end



