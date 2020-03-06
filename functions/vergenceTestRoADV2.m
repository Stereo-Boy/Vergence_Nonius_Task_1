function [thres, expe, lastBreakTime, stairs]=vergenceTestRoADV2()
%------------------------------------------------------------------------
% ALWAYS NO FIXATION (staircases chosing are a bit wrong because it does not allow to choose to run only one condition)
%
% Simplified and corrected version
%
% RoAD Project [Relative or Absolute Disparities]
% Adrien Chopin, Daphne Bavelier, David Knill, Dennis Levi
% May 2013 - Geneva
%-----------------------------------------------------------------------
%
%================== Vergence test ====================================   
%   Called by RoAD main experiment function
%   This function does:
%           - initialization of a vergence test with staircases
%           - display instructions and stimuli, get response
%           
%=======================================================================
% Stimuli: are pairs of dichoptic nonius presented just after the binocular
%   fusion frames with an ISI-mask, including or not a fixation point (whem
%   in fixation condition, there is no mask, to avoid any drift)
% Task: is to tell if upper line is more on right or left compared to lower
%   line
% Specials:
%  Staircase is adaptive stochastic approximation, with restart of the
%  staircases when the two do not converge on same value.
% Warnings:
%   I start with a variable load from main function (temp.mat) - bad practice.
%------------------------------------------------------------------------

load('temp.mat')
lastBreakTime = GetSecs;
%Main part of the staircase function - control everything

%--------------------------------------------------------------------------
%   DISPLAY INSTRUCTIONS 
%--------------------------------------------------------------------------
    displaystereotext3(scr,sc(scr.fontColor,scr.box),expe.instrPosition,expe.instructionsVergence.(language),1);
    %flip(inputMode, scr.w,[],0);
    flip2(expe.inputMode, scr.w,[],0);
    waitForKey(scr.keyboardNum,expe.inputMode);
%--------------------- WAIT  --------------------------------

%--------------------------------------------------------------------------
%   Display block #
%--------------------------------------------------------------------------
%    displaystereotext3(scr,sc(scr.fontColor,scr.box),expe.instrPosition,['Block ', num2str(block)],1);
%    flip2(expe.inputMode, scr.w,[],0);
%    waitForKey(scr.keyboardNum,inputMode);
%--------------------- WAIT  --------------------------------

      %----- ROBOT MODE ------%
        %when in robot mode, make all timings very short
        if inputMode==2
            stim.mask1Duration                 = 0.001;
            stim.itemDuration                  = 0.001;
            stim.mask2Duration                 = 0.001;
            %stim.responseTrial                = 2000; %not used
            stim.interTrial                    = 0.001;    
        end
        
  %======================================================================
  %           STAIRCASE INITIALIZATION
  %======================================================================
    % Staircase glossary: In an edition, all staircases are started and
    % intermixed until convergence. Other editions begins for non
    % converging staircases. A condition is a set of separate staircases
    % that will be averaged together at the end. A level is one of these
    % staircases: a level has a different starting value than other levels.
    % Levels of same condition that are not converging to same value are
    % redone in a new edition.
    %======================================================================
    % startValues: First values to be displayed; lines are cond (separate averages), 
    %   columns are levels (averaged together); To be more precise, 2 levels for each 
    %   condition are run and if their average is different of more than 3 times their std, the
    %   staircases are run again for that condition.
    % === UPDATE HERE (to adapt to new protocol) ** ===%
        stairs.startValues = [stim.iniValues]; %no fixation  [20arcsec 60arsec] => but in arcmin
        condList=1;
        stairs.maxStepNb = stim.maxStepNb;         % maximum number of steps for each staircase        
        stairs.maxInitialStepSize = stim.maxInitialStepSize; % maximal initial step size
        stairs.stoppingStep = stim.stoppingStep;        % stopping criterion
        stairs.stoppingRevNb =stim.stoppingRevNb;
        stairs.stepSize=stim.stepSize;
        stairs.desiredThreshold = stim.desiredThreshold; % desired threshold
        nbCond=numel(condList);
        
    %======================================================================% 
    % CONVERGING LOOP
    %======================================================================% 
        %run the staircases (ST) as long as all ST have completely converged
        stairs.edition=0;  %each run of all staircases is an edition 
        %(a second edition - and third...- happens for not converging staircases)
        theSize=size(stairs.startValues);
        stairs.notConvergingCond=ones(theSize(1),1);
        
        thres=nan(nbCond,3); stairs.thresLine=nan(nbCond,3); 
        stairs.threslvl=nan([theSize,3]); stairs.thresLvlLine=nan([theSize,3]);
        stairs.values=cell(nbCond,1); stairs.dataResp=cell(nbCond,1);
        stairs.lvlClasses=nan([theSize,7,3]); stairs.valueClasses=nan([nbCond,7,3]);
        stairs.condDoneList=zeros(nbCond,1); stairs.currentStepNb=nan(theSize);
        stairs.valuesArray=nan([theSize, stairs.maxStepNb]); %p1=nan(nbCond,3);
        stairs.respArray=nan([theSize, stairs.maxStepNb]); 
        stairs.yg1=nan(nbCond,425);stairs.yg1lvl=nan([theSize,425]);
        stairs.yg2=nan(nbCond,425);stairs.yg2lvl=nan([theSize,425]);
        stim.stopSignal = 0;
        
        while any(stairs.notConvergingCond)
            if stim.stopSignal; break; end
            %stairs.notConvergingCond
            stairs.edition=stairs.edition+1;
            stairs.currentStartValues=stairs.startValues(logical(stairs.notConvergingCond),:);
            %these are the conditions send for convergence
            currentCondList=condList(logical(stairs.notConvergingCond));
            
            [converging,valuest,dataRespt,valueClassest,lvlClassest,threst,threslvlt,thresLinet,thresLvlLinet,trialListt,...
    yg1t,yg2t, yg1lvlt,yg2lvlt,xx,valuesArrayt,respArrayt,currentStepNbt, expe, lastBreakTime]=staircase(stairs,scr,stim,sounds,inputMode,displayMode,...
                 expe, lastBreakTime,startTime,destrectL, destrectR,language,currentCondList); 
             
                 stairs.values(currentCondList)=valuest;  
                 stairs.dataResp(currentCondList)=dataRespt;
                  thres(currentCondList,:)=threst  ;  
                  stairs.thresLine(currentCondList,:)=thresLinet ;
                  stairs.threslvl(currentCondList,:,:)=threslvlt;
                  stairs.thresLvlLine(currentCondList,:,:)=thresLvlLinet;
                  
                  stairs.valueClasses(currentCondList,:,:)=valueClassest; 
                  stairs.lvlClasses(currentCondList,:,:,:)=lvlClassest;
                  stairs.currentStepNb(currentCondList,:)=currentStepNbt;  
                  stairs.valuesArray(currentCondList,:,:)=valuesArrayt;
                  stairs.respArray(currentCondList,:,:)=respArrayt;
                  stairs.yg1(currentCondList,:)=yg1t; 
                  stairs.yg2(currentCondList,:)=yg2t;
                  stairs.yg1lvl(currentCondList,:,:)=yg1lvlt; 
                  stairs.yg2lvl(currentCondList,:,:)=yg2lvlt;
                  
             %update relevant values if necessary
             if sum(converging)>0 %when one cond at least converged
                 %determine the ones that actually converged
                  convergedBigList=currentCondList(logical(converging));
                  
                  %update the condition to do
                  stairs.notConvergingCond(convergedBigList)=0;
             end  
             stairs.trialList{stairs.edition}=trialListt; stairs.xx=xx;             
             
             %save
             name2=[name,'-vTest-ed',num2str(stairs.edition),'.mat'];
             save(fullfile(datapath,name2))
             %saveAll([name2,'.mat'],[name2,'.txt'])
        end
        disp([num2str(stairs.edition),'e edition'])       
end


function [converging,values,dataResp,valueClasses,lvlClasses,thres,threslvl,thresLine,thresLvlLine,trialList,...
    yg1,yg2, yg1lvl,yg2lvl,xx,valuesArray,respArray, currentStepNb, expe, lastBreakTime]=staircase(stairs,scr,stim,sounds,inputMode,displayMode, expe,...
    lastBreakTime,startTime,destrectL, destrectR,language,cond2ToList)
     
    %======================================================================% 
    % Internal staircase variables
    %======================================================================% 
        
        %nb of cond and lvl sent in the function
         nbCondHere=size(stairs.currentStartValues,1);
         nbLevelHere=size(stairs.currentStartValues,2);
        %array of to do staircases
         notDoneArray= ones(nbCondHere,nbLevelHere); 
        %array to tell if a staircase failed according to step nb criterion
         failed= zeros(nbCondHere,nbLevelHere); 
        %array of values already displayed
         valuesArray = nan(nbCondHere, nbLevelHere, stairs.maxStepNb);
        %and of responses
         respArray = nan(nbCondHere, nbLevelHere, stairs.maxStepNb);  
        %array of individual thresholds
         foundThres = nan(nbCondHere, nbLevelHere); 
        %number of current step for each staircase
         currentStepNb = zeros(nbCondHere, nbLevelHere);          
        %initialize values with start values
         valuesArray(:,:, 1) = log(stairs.currentStartValues); %LOG SCALE
        %split notDoneArray into a list of cond and lvl values
         [cond2Do, lvl2Do] = find(notDoneArray);
         t=0;
         goalCounter=nbCondHere*nbLevelHere*stairs.maxStepNb;
         trialList=nan(goalCounter,15); 
         beginInterTrial=GetSecs;
         
         %estimation parameters for latter fit
         %LOG SCALE
         cmin1=[log(10/60) 0.01 1];    %min
         cmax1=[log(700/60) 1000 1];      %max
         p0=(cmin1+cmax1)/2;   %start 
         xx=cmin1(1):0.01:cmax1(1);
         
    %----ACTIVATE STAIRCASES RANDOMLY and run them completely----%
    while (lvl2Do)   
        t=t+1;
        
        %choose one staircase randomly
            nbActiveST = length(lvl2Do);
            chosenST = ceil(nbActiveST * rand);      
            cond = cond2Do(chosenST); %current staircase
            level = lvl2Do(chosenST); %current level
           
       %retrieve step nb, value list and next value to ask 
            stepI = currentStepNb(cond,level) + 1;
            currentStepNb(cond,level) = stepI;
            valueList = squeeze(valuesArray(cond,level, 1:stepI));
            currentValue = valueList(end);

      %--------------------------------------------------------------------------
      %   STIM - RESP LOOP - get rid of that
      %--------------------------------------------------------------------------  
           upRightOffset=randsample([-1,1],1); %1 for upper rightward offset -1 for upper leftward offset 
 
        %decide whether upper line is in left eye (-1) or in right eye (1)
           upFactor=randsample([1,-1],1); %
        
        [expe, lastBreakTime, resp, stuff2save,beginInterTrial, stim]=stimAndRegistrate(exp(currentValue),cond2ToList(cond), lastBreakTime, scr, stim, expe, sounds, startTime, inputMode,...
            displayMode, t,goalCounter, upRightOffset, destrectL, destrectR, language, beginInterTrial,upFactor); %RELINEARIZE (from logscale)
        
        stuff2save([2 5 6 13])=[stairs.edition, level, stepI, upFactor]  ;
         % stuff2save
         %  1   block 
         %  2   edition
         %  3   trial in edition
         %  4   condition cond => 1 for fixation/no mask1 and 2 for 'no fixation'/mask1
         %  5   level - # of staircase
         %  6   stepNb for that staircase
         %  7   currentValue offset in arcmin
         %  8   upRightOffset: 1 for upper right offset -1 for upper left 
         %  9   responseKey (1 left - 2 right)
         %  10  resp (0 fail, 1 success)
         %  11  reaction time RT
         %  12  timing check
         %  13  upFactor - decide whether upper line is in left eye (-1) or in right eye (1)
         %  14  nan
         %  15  jitter
        %--------------------------------------------------------------------------
        
      %resp is 1 if success, 0 if failure here
      % === UPDATE HERE (to adapt to new protocol) ** ===%
        trialList(t,:)=stuff2save;
        
      %save response
        respArray(cond,level, stepI) = resp;
        resplist = squeeze(respArray(cond,level, 1:stepI));

      %---Determine next value-----% => I use a log scale because values cannot be negative
       % ASA: Accelerated Stochastic Approximation 
        [nextValue, done] = staircaseASA(valueList, resplist, stairs.desiredThreshold, log(stairs.maxInitialStepSize), log(stairs.stoppingStep));
       % Basic 1 up / 2 down (decrease difficulty after one failure, increase diff after 2 successes)
       %[nextValue, done] = staircaseUpDown(valueList, resplist, stairs.desiredThreshold, log(stairs.stepSize), stairs.stoppingRevNb);

      %---correct if above possible maximum ----%  
         if nextValue>log(stim.max)       
            nextValue=log(stim.max);
         end
                 
      %if staircase is not finished, ask for next value
        if ((~done) && (stepI < stairs.maxStepNb))
            valuesArray(cond,level, stepI+1) = nextValue;
        else %if done, save threshold
            notDoneArray(cond,level) = 0;
            foundThres(cond,level) = nextValue;
            if ~done
                %say that it did not work
                %failed (cond,level) = 1
            end
        end

      %update list of cond/lvl couples to do
        [cond2Do lvl2Do] = find(notDoneArray);
        if stim.stopSignal; break; end
    end

    %average levels across levels
    final_thres = mean(foundThres, 2);
    total_stepI = nansum(currentStepNb,2);
    fprintf('Final thresholds (direct method)= (%5.3f) obtained in %d measures\n', [final_thres, total_stepI]');

    %==============================================================
    %   Now, we will compute thresholds with three different ways: 
    %      1)  with the mean of last staircase values (direct method)
    %      2)  with a fit using a cumulative distribution function on agregated data (parametrized method)
    %      3)  with a similar fit, but using all raw data (complete method)
    
    % 1) last staircase value (direct method) - does not take into account (response) biases
        thres=nan(nbCondHere,3); thresLine=nan(nbCondHere,3);
        thres(:,1)=final_thres;
        thresLine(:,1)=final_thres;

    % 2) fit the data by a psychometric curve to get a better approximate of
    %the threshold (parametrized method)
        valueClasses=nan(nbCondHere,7,3);
        values=cell(nbCondHere,1);        dataResp=cell(nbCondHere,1);
        p1=nan(nbCondHere,3);       p2=nan(nbCondHere,3); yg1=nan(nbCondHere,numel(xx));  yg2=nan(nbCondHere,numel(xx)); 

        for i=1:nbCondHere
                %first create a matrix of all the data of each cond (so every
                %levels together)
                valuesTemp=[]; dataRespTemp=[];
                    for j=1:nbLevelHere %levels
                        stepI=currentStepNb(i,j);
                        valuesTemp=[valuesTemp;squeeze(valuesArray(i,j,(stim.excludedValues+1):stepI))];
                        dataRespTemp=[dataRespTemp;squeeze(respArray(i,j,(stim.excludedValues+1):stepI))];
                    end
                values{i}=valuesTemp;
                dataResp{i}=dataRespTemp;

                %then split the data for each condition in groups with equal numbers of data
                 valueClassesTmp=makeLevelEqualBounds([valuesTemp,dataRespTemp],7, 'nanmean');
                 valueClasses(i,:,:)=valueClassesTmp;
                
               % === UPDATE HERE (to adapt to new protocol) ** ===%
               %then fit it with a cumulative gaussian
                        
                    %estimate the parameters
                        x1=valueClassesTmp(:,1)';        range=x1(end)-x1(1);            y1=valueClassesTmp(:,2)';
                        % === UPDATE HERE (to adapt to new protocol) ** ===%
                         %correct valueClassesTmp (that is between 0.5 and 1) to go
                         %between 0 and 1:
                         y1=2.*(y1-0.5);
                        p1(i,:) = mlfit('cumulGauss6', p0, cmin1,cmax1,[x1(1)-range,x1,x1(end)+range], [0,y1,1])    ;
                        yg1(i,:) = cumulGauss6(xx, p1(i,1:3));
                        %thres(i,2)=norminv(stairs.desiredThreshold,p1(i,1),p1(i,2))-p1(i,1);
                        %thresLine(i,2)=norminv(stairs.desiredThreshold,p1(i,1),p1(i,2));
                        thres(i,2)=p1(i,1);         thresLine(i,2)=p1(i,1);
                        %inverse correction for yg
                         yg1(i,:) = 0.5 + yg1(i,:)./2 ;
                         
      %3) do the same but with the raw data estimation (complete method)
                    %estimate the parameters
                        x1=valuesTemp';                    y1=dataRespTemp';
                        % === UPDATE HERE (to adapt to new protocol) ** ===%
                         %correct valueClassesTmp (that is between 0.5 and 1) to go
                         %between 0 and 1:
                         y1=2.*(y1-0.5);
                        p2(i,:) =  mlfit('cumulGauss6', p0, cmin1,cmax1,x1,y1);
                        yg2(i,:) = cumulGauss6(xx, p2(i,1:3));
                       % thres(i,3)=norminv(stairs.desiredThreshold,p2(i,1),p2(i,2));
                       %thres(i,3)=norminv(stairs.desiredThreshold,p2(i,1),p2(i,2))-p2(i,1);
                       %thresLine(i,3)=norminv(stairs.desiredThreshold,p2(i,1),p2(i,2));
                       thres(i,3)=p2(i,1);         thresLine(i,3)=p2(i,1);
                       %inverse correction for yg
                         yg2(i,:) = 0.5 + yg2(i,:)./2 ;
        end
        
        % then do the same for each level separately to determine convergence
            lvlClasses=nan(nbCondHere,nbLevelHere,7,3);  p1lvl=nan(nbCondHere,nbLevelHere,3); p2lvl=nan(nbCondHere,nbLevelHere,3);
            threslvl=nan(nbCondHere,nbLevelHere,3);  thresLvlLine=nan(nbCondHere,nbLevelHere,3); 
            for i=1:nbCondHere
                for j=1:nbLevelHere %levels
                    %first create a matrix of all the data of each cond / level
                      stepI=currentStepNb(i,j);
                      valuesTemp=squeeze(valuesArray(i,j,1:stepI));
                      dataRespTemp=squeeze(respArray(i,j,1:stepI));

                    %then split the data in groups with equal numbers of data
                     stairTmp=makeLevelEqualBounds([valuesTemp,dataRespTemp],7, 'nanmean');
                     lvlClasses(i,j,:,:)=stairTmp;

                   %then fit it with a cumulative gaussian
                     %estimate the parameters
                            x1=stairTmp(:,1)';        range=x1(end)-x1(1);            y1=stairTmp(:,2)';
                            % === UPDATE HERE (to adapt to new protocol) ** ===%
                             %correct stairTmp (that is between 0.5 and 1) to go
                             %between 0 and 1:
                             y1=2.*(y1-0.5);
                            p1lvl(i,j,:) = mlfit('cumulGauss6', p0, cmin1,cmax1,[x1(1)-range,x1,x1(end)+range], [0,y1,1])    ;
                            yg1lvl(i,j,:) = cumulGauss6(xx, p1lvl(i,j,1:3));
                            %threslvl(i,j,2)=p1lvl(i,j,2);
                            %threslvl(i,j,2)=norminv(stairs.desiredThreshold,p1lvl(i,j,1),p1lvl(i,j,2))-p1lvl(i,j,1);
                            %thresLvlLine(i,j,2)=norminv(stairs.desiredThreshold,p1lvl(i,j,1),p1lvl(i,j,2));
                            threslvl(i,j,2)=p1lvl(i,j,1);         thresLvlLine(i,j,2)=p1lvl(i,j,1);
                            %inverse correction for yg
                            yg1lvl(i,j,:) = 0.5 + yg1lvl(i,j,:)./2 ;
                            
                     %do the same but with the raw data estimation
                        %estimate the parameters
                            x1=valuesTemp';                    y1=dataRespTemp';
                            % === UPDATE HERE (to adapt to new protocol) ** ===%
                             %correct stairTmp (that is between 0.5 and 1) to go
                             %between 0 and 1:
                             y1=2.*(y1-0.5);
                            p2lvl(i,j,:) =  mlfit('cumulGauss6', p0, cmin1,cmax1,x1,y1);
                            yg2lvl(i,j,:) = cumulGauss6(xx, p2lvl(i,j,1:3));
                           % threslvl(i,j,3)=norminv(stairs.desiredThreshold,p2lvl(i,j,1),p2lvl(i,j,2)); %THE interesting value (first parameter is the gaussian mean, so the 50% value for the cumulated one)
                           %threslvl(i,j,3)=norminv(stairs.desiredThreshold,p2lvl(i,j,1),p2lvl(i,j,2))-p2lvl(i,j,1);
                           %thresLvlLine(i,j,3)=norminv(stairs.desiredThreshold,p2lvl(i,j,1),p2lvl(i,j,2));
                           threslvl(i,j,3)=p2lvl(i,j,1);         thresLvlLine(i,j,3)=p2lvl(i,j,1);
                           %inverse correction for yg
                            yg2lvl(i,j,:) = 0.5 + yg2lvl(i,j,:)./2 ;
                            
%                             if p1lvl(i,j,1)>=cmax1(1)
%                                 failed (i,j) = 1;
%                             end
                end
            end
    %converging=abs(exp(p1lvl(:,1,1))-exp(p1lvl(:,2,1)))<mean(exp(p1lvl(:,:,1)),2).*50./100; %not converging if distance between the 2 staircases is more than 25% of their mean
    %if one ST did stop because of step nb criterion, invalidate
    %convergence anyway
    converging=ones(size(p1lvl,1),1) %always converging
    converging(any(failed')')=0
end

%============ STIMULUS PRESENTATION AND RESPONSE INTAKE ======================================
function [expe, lastBreakTime, resp, stuff2save, beginInterTrial, stim]=stimAndRegistrate(currentValue,cond, lastBreakTime, scr, stim, expe, sounds, startTime, inputMode,...
            displayMode,t,goalCounter, upRightOffset, destrectL, destrectR, language, beginInterTrial,upFactor)

       %cond => 1 for fixation/no mask1 and 2 for 'no fixation'/mask1
        
       %leftFactor=randsample([-1,1],1); %for eccentricity: -1 is left, 1 is right
       offset=upRightOffset*currentValue/2; %offset for upper line, in arcmin - positive values means upper offset is rightward
       % Note that we apply half of the offset to the upper line, half to the lower
       % So upRightOffset = 1 for upper line rightward offset and -1 for upper leftward offset
       offsetPx=(offset./60).*scr.VA2pxConstant; % in px
       jitter=round(((rand(1).*stim.jitterRange)-stim.jitterRange/2)); 
       masks=nan(stim.frameSize,stim.frameSize,2);

      %--------------------------------------------------------------------------
      %=====  Check BREAK TIME  ====================
      %--------------------------------------------------------------------------
       if (GetSecs-lastBreakTime)/60>=expe.breakTime
           Screen('FillRect',scr.w, sc(scr.backgr,scr.box));
           %stereo: 
           displaystereotext3(scr,sc(scr.fontColor,scr.box),expe.instrPosition,expe.breaktime.(language),1);
           %or normal:
           %displayText(scr,sc(scr.fontColor,scr.box),[scr.res(3)/2-250,100,stim.colorFixation,900],instructions.(expe.language))  
           flip2(expe.inputMode, scr.w);
           %beginbreak=GetSecs;
           waitForKey(scr.keyboardNum,inputMode);
           %-------------------- WAIT ------------------------------------------
           %expe.breaks(breakNb,:)=[breakNb, 0, t, (GetSecs-beginbreak)/60]; %block, trial and duration of the break
           lastBreakTime=GetSecs;
       end

        % ------------- ALLOWED RESPONSES as a function of TIME (allows escape in the first 10 min)-----%
        %       Response Code Table:
        %               0: no keypress before time limit
        %               1: left 
        %               2: right 
        %               3: space
        %               4: escape
        %               5: up
        %               6: down
             if ((startTime-GetSecs)/60)<10 %the first 10 min, allows for esc button
                  allowR=[1,2,4];
             else                             %but not after
                  allowR=[1,2];
             end

        %--------------------------------------------------------------------------
        %   PRELOADING OF TEXTURES DURING INTERTRIAL 
        %--------------------------------------------------------------------------
            if ~exist('beginInterTrial','var'); beginInterTrial=GetSecs;end
            masks(:,:,1)=sc(stim.maskLum.*rand(stim.frameSize),scr.box);
            masks(:,:,2)=sc(stim.maskLum.*rand(stim.frameSize),scr.box);
            text1 = Screen('MakeTexture', scr.w, masks(:,:,1));
            text2 = Screen('MakeTexture', scr.w, masks(:,:,2));
            clear masks             
            feuRouge(beginInterTrial+stim.interTrial/1000,inputMode);
            
        %--------------------------------------------------------------------------
        %   DISPLAY FRAMES + NONIUS 
        %--------------------------------------------------------------------------
            %---- frames
            Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
            framesAutoFast(0,[stim.frameSize stim.frameSize 60 60],scr,stim.squareS,stim.frameLum,[],0.75,scr.centerY);
             
             %--------------------------------------------------------------------------
             %   Nonius
             %--------------------------------------------------------------------------
%                  %vertical lines
%                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterXLine, scr.centerYLine+stim.noniusOffset ,  scr.LcenterXLine, scr.centerYLine+stim.noniusLineSize+stim.noniusOffset , stim.noniusLineWidth);   %Left eye up line
%                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.RcenterXLine, scr.centerYLine-stim.noniusOffset,  scr.RcenterXLine, scr.centerYLine-stim.noniusLineSize-stim.noniusOffset , stim.noniusLineWidth);   %right eye down line
%                 %horizontal 
%                   Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterXLine-stim.noniusLineSize/2, scr.centerYLine,  scr.LcenterXLine-stim.noniusOffset, scr.centerYLine , stim.noniusLineWidth);   %Left eye left horizontal line
%                   Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterXLine+stim.noniusOffset, scr.centerYLine,  scr.LcenterXLine+stim.noniusLineSize/2, scr.centerYLine , stim.noniusLineWidth);   %Left eye right horizontal line
%                   Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.RcenterXLine+stim.noniusLineSize/2, scr.centerYLine,  scr.RcenterXLine+stim.noniusOffset, scr.centerYLine , stim.noniusLineWidth);   %right eye left horizontal line
%                   Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.RcenterXLine-stim.noniusOffset, scr.centerYLine,  scr.RcenterXLine-stim.noniusLineSize/2, scr.centerYLine , stim.noniusLineWidth);   %right eye right horizontal line
%                 %Middle binocular fixation dot
%                   Screen('DrawDots', scr.w, [scr.LcenterXDot,scr.RcenterXDot;scr.centerYDot,scr.centerYDot], stim.fixationSize,sc(stim.colorFixation,scr.box));
% %                   %tests
% %                   Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), 0, scr.centerY,  0, scr.centerY+10 , stim.noniusLineWidth)
% %                   Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterX-10, 0,  scr.LcenterX, 0 , stim.noniusLineWidth)
% %                   
% %                   Screen('DrawDots', scr.w, [0,0;scr.centerY,scr.centerY], 1,sc(stim.colorFixation,scr.box));
% %                   Screen('DrawDots', scr.w, [scr.LcenterX,scr.LcenterX;0,0], 1,sc(stim.colorFixation,scr.box));
% %                   
% %                  Screen('FrameRect', scr.w ,sc(stim.colorFixation,scr.box) ,[0 0 1 1] ,1)
% %                   Screen('DrawTextures', scr.w, Screen('MakeTexture', scr.w, sc(100*ones(1,1),scr.box)), [], [0 1 1 2]);
%                   %Screen('FillOval',scr.w, sc(stim.colorFixation,scr.box), CenterRectOnPoint([1 1 3 3],scr.LcenterX, scr.centerY));
%                   %Screen('FillOval',scr.w, sc(stim.colorFixation,scr.box), CenterRectOnPoint([1 1 3 3],scr.RcenterX, scr.centerY));
%                 %Binocular outer dots
%                 Screen('DrawDots', scr.w, [scr.LcenterXDot-stim.noniusLineSize/2, scr.LcenterXDot+stim.noniusLineSize/2, scr.LcenterXDot-stim.noniusLineSize/2, scr.LcenterXDot+stim.noniusLineSize/2,...
%                    scr.RcenterXDot-stim.noniusLineSize/2, scr.RcenterXDot+stim.noniusLineSize/2, scr.RcenterXDot-stim.noniusLineSize/2, scr.RcenterXDot+stim.noniusLineSize/2;...
%                    scr.centerYDot-stim.noniusLineSize-stim.noniusOffset, scr.centerYDot-stim.noniusLineSize-stim.noniusOffset, scr.centerYDot+stim.noniusLineSize+stim.noniusOffset, scr.centerYDot+stim.noniusLineSize+stim.noniusOffset,...
%                    scr.centerYDot-stim.noniusLineSize-stim.noniusOffset, scr.centerYDot-stim.noniusLineSize-stim.noniusOffset, scr.centerYDot+stim.noniusLineSize+stim.noniusOffset, scr.centerYDot+stim.noniusLineSize+stim.noniusOffset], 7,...
%                    [sc(stim.colorFixation,scr.box),sc(stim.colorFixation,scr.box),0]); 

                 %vertical lines
                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterXLine, scr.centerYLine+stim.noniusOffset ,  scr.LcenterXLine, scr.centerYLine+stim.noniusLineSize+stim.noniusOffset , stim.noniusLineWidth);   %Left eye up line
                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.RcenterXLine, scr.centerYLine-stim.noniusOffset,  scr.RcenterXLine, scr.centerYLine-stim.noniusLineSize-stim.noniusOffset , stim.noniusLineWidth);   %right eye down line
                %horizontal 
                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterXLine-round(stim.noniusLineSize/2), scr.centerYLine,  scr.LcenterXLine-stim.noniusOffset, scr.centerYLine , stim.noniusLineWidth);   %Left eye left horizontal line
                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.LcenterXLine+stim.noniusOffset, scr.centerYLine,  scr.LcenterXLine+round(stim.noniusLineSize/2), scr.centerYLine , stim.noniusLineWidth);   %Left eye right horizontal line
                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.RcenterXLine+round(stim.noniusLineSize/2), scr.centerYLine,  scr.RcenterXLine+stim.noniusOffset, scr.centerYLine , stim.noniusLineWidth);   %right eye left horizontal line
                  Screen('DrawLine', scr.w, sc(stim.noniusLum,scr.box), scr.RcenterXLine-stim.noniusOffset, scr.centerYLine,  scr.RcenterXLine-round(stim.noniusLineSize/2), scr.centerYLine , stim.noniusLineWidth);   %right eye right horizontal line
                %centre frame
                  maxi=round(stim.noniusLineSize+2*stim.noniusOffset);
                  Screen('FrameRect', scr.w ,sc(stim.noniusLum,scr.box) ,[scr.LcenterXLine-1-maxi scr.centerYLine-1-maxi scr.LcenterXLine+1+maxi scr.centerYLine+1+maxi] ,1) ;   
                  Screen('FrameRect', scr.w ,sc(stim.noniusLum,scr.box) ,[scr.RcenterXLine-1-maxi scr.centerYLine-1-maxi scr.RcenterXLine+1+maxi scr.centerYLine+1+maxi] ,1);                 
                %Middle binocular fixation dot
                  Screen('DrawDots', scr.w, [scr.LcenterXDot,scr.RcenterXDot;scr.centerYDot,scr.centerYDot], stim.fixationSize,sc(stim.noniusLum,scr.box));

                flip2(expe.inputMode, scr.w);
                waitForKey(scr.keyboardNum,inputMode); 
                Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
        %-------------------- WAIT ------------------------------------------

        %--------------------------------------------------------------------------
        %   DISPLAY MASK 1
        %--------------------------------------------------------------------------
             Screen('DrawTextures', scr.w, [text1,text2], [], [destrectL',destrectR']);
              [~, onsetMask1] = flip2(expe.inputMode, scr.w,[]);
             %waitForT(stim.mask1Duration,inputMode);
              %ACTUALLY, instead of waiting, draw stuff and wait on next flip
             Screen('FillRect', scr.w, sc(scr.backgr,scr.box));

        %--------------------------------------------------------------------------
        %   DISPLAY STIMULUS - NONIUS LINEs
        %--------------------------------------------------------------------------
          if upFactor==-1 
            %upper line in left eye
            drawStereoLine(scr.w, scr.LcenterXLine+jitter, 0,  scr.centerYLine-stim.vertEcc, 0,offsetPx,0,stim.lineLum, stim.lineSize, scr.box,scr.backgr,1);             
            %lower line in right eye
            drawStereoLine(scr.w, 0, scr.RcenterXLine+jitter,   0, scr.centerYLine+stim.vertEcc,0,-offsetPx,stim.lineLum, stim.lineSize, scr.box,scr.backgr,1);   
          else
              %upper line in right eye
            drawStereoLine(scr.w, scr.RcenterXLine+jitter, 0, scr.centerYLine-stim.vertEcc, 0,offsetPx,0,stim.lineLum, stim.lineSize, scr.box,scr.backgr,1);             
            %lower line in left eye
            drawStereoLine(scr.w, 0, scr.LcenterXLine+jitter, 0, scr.centerYLine+stim.vertEcc,0,-offsetPx,stim.lineLum, stim.lineSize, scr.box,scr.backgr,1); 
          end
            
%         %--------------------------------------------------------------------------
%         %   SCREEN CAPTURE
%         %--------------------------------------------------------------------------
%             theFrame=[150 0 650 500];
%             Screen('FrameRect', scr.w, 255, theFrame)
%             flip(inputMode, scr.w, [], 1); 
%             %WaitSecs(1)
%             %im=Screen('GetImage', scr.w, theFrame);
%             %save('im2.mat','im')
%             
                %--------------------------------------------------------------------------
                %   DISPLAY MODE STUFF
                %--------------------------------------------------------------------------
                    if displayMode==1
                         Screen('DrawDots', scr.w, [scr.LcenterXDot,scr.RcenterXDot;scr.centerYDot,scr.centerYDot], 1,sc(stim.noniusLum,scr.box));

                          displayText(scr,sc(scr.fontColor,scr.box),[0,0,scr.res(3),200],['/t:',num2str(t),'/c:',num2str(cond),' /ofst: ', num2str(offset),' /ofp ', num2str(offsetPx), '/upRO:', num2str(upRightOffset),'/jit:',num2str(jitter),'/upF:',num2str(upFactor)]);
                    end
            %[dummy onsetStim]=flip(inputMode, scr.w,onsetMask1+stim.mask1Duration/1000);
            [~, onsetStim] = flip2(expe.inputMode, scr.w,onsetMask1+stim.mask1Duration/1000);
                     if displayMode==1; waitForKey(scr.keyboardNum,inputMode); end
            %waitForT(stim.itemDuration,inputMode);
            %ACTUALLY, instead of waiting, draw stuff and wait on next flip
            Screen('FillRect', scr.w, sc(scr.backgr,scr.box));

%         %--------------------------------------------------------------------------
%         %   DISPLAY MASK 2
%         %--------------------------------------------------------------------------
%              Screen('DrawTextures', scr.w, [text2,text1], [], [destrectL',destrectR']);
               %[dummy offsetStim]=flip(inputMode, scr.w,onsetStim+stim.itemDuration/1000);
                [~, offsetStim] = flip2(expe.inputMode, scr.w,onsetStim+stim.itemDuration/1000);
%              %waitForT(stim.mask1Duration,inputMode);
%              %ACTUALLY, instead of waiting, draw stuff and wait on next flip
%              Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
             

        %--------------------------------------------------------------------------
        %   GET RESPONSE
        %--------------------------------------------------------------------------
          % [dummy offsetMask2]=flip(inputMode, scr.w,offsetStim+stim.mask2Duration/1000);
           [responseKey, RT]=getResponseKb(scr.keyboardNum,0,inputMode,allowR,'robotModeRoADvTestV2',[offset stim.robotThr/0.95 stim.robotBias upFactor]);

           if responseKey==4 
               disp('Voluntary Interruption')
               stim.stopSignal = 1;
           end

           resp=(responseKey==upRightOffset/2+1.5);
           
           if inputMode==1
             play(sounds.success.obj);
           end

           if displayMode==1
                Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
                displayText(scr,sc(scr.fontColor,scr.box),[0,100,scr.res(3),200],['responseKey:',num2str(responseKey),'/resp: ',num2str(resp),'/RT:',num2str(RT)]);
                flip2(expe.inputMode, scr.w,[],1);
                waitForKey(scr.keyboardNum,inputMode);
                Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
                flip2(expe.inputMode, scr.w,[],1);
           end
         
        %--------------------------------------------------------------------------
        %  SAVE STUFF
        %--------------------------------------------------------------------------
         stuff2save=[0, nan, t, cond, nan, nan, currentValue, upRightOffset, responseKey, resp, RT, offsetStim-onsetStim, nan, nan jitter];  
         % stuff2save
         %  1   block - always 0
         %  2   edition
         %  3   trial
         %  4   condition cond => 1 for fixation/no mask1 and 2 for 'no fixation'/mask1
         %  5   level - startValue
         %  6   stepNb for that staircase
         %  7   currentValue offset in arcmin
         %  8   upRightOffset: 1 for upper right offset -1 for upper left 
         %  9   responseKey (1 left - 2 right)
         %  10  resp (0 fail, 1 success)
         %  11  reaction time RT
         %  12  timing check - stimulus duration
         %  13  upFactor - decide whether upper line is in left eye (-1) or in right eye (1)
         %  14  nan
         %  15  jitter
        %--------------------------------------------------------------------------
        %   INTER TRIAL
        %--------------------------------------------------------------------------
           %inter-trial is actually at the begistepIing of next trial to allow pre-loading of textures in the meantime.
           %to be able to do that, we have to start counting time
           %from now on:
           beginInterTrial=GetSecs;

        %------ Progression bar for robotMode ----%
            if inputMode==2
                Screen('FillRect',scr.w, sc([scr.fontColor,0,0],scr.box),[0 0 scr.res(3)*t/goalCounter 10]);
                Screen('Flip',scr.w);
            end
            if stim.stopSignal==1; return; end
end

 