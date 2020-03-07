function vergenceNonius1(parameters)


try

    clc
    [expe.vntpath,~]=fileparts(mfilename('fullpath')); %path to vergence nonius folder
    expe.datapath = fullfile(expe.vntpath,'dataFiles');
    addpath(fullfile(expe.vntpath,'functions'))
    addpath(fullfile(expe.vntpath,'screen'))
    addpath(fullfile(expe.vntpath,'analysis'))
    cd(expe.vntpath)
    expe.DSTpath = fullfile(fileparts(expe.vntpath),'DST8','dataFiles'); % dst datafile path

    %==========================================================================
    %                           QUICK PARAMETERS
    %==========================================================================

           %===================== INPUT MODE ==============================
            %1: User  ; 2: Robot 
            %The robot mode allows to test the experiment with no user awaitings
            %or long graphical outputs, just to test for obvious bugs
            inputMode=1; 
            %==================== QUICK MODE ==============================
            %1: ON  ; 2: OFF 
            %The quick mode allows to skip all the input part at the beginning of
            %the experiment to test faster for what the experiment is.
            quickMode=1; 
            %==================== DISPLAY MODE ==============================
            %1: ON  ; 2: OFF 
            %In Display mode, some chosen variables are displayed on the screen
            displayMode=2; 
            %===============================================================
            
            %----- mode related stuff ---%
            if quickMode==2
                name=nameInput(expe.datapath);
                %language=input('Language (fr for french; en for english):  ', 's');
                expe.language='fr';
                expe.nameDST=input('Enter name given during last DST: ','s');    %dst name
            else
                name='default';
                expe.nameDST='default';
                expe.language='fr';
            end

            
    %=========  STARTERS =================================================== %
    %Initialize and load experiment settings (window and stimulus)
               [expe, scr, stim, sounds, stairs1, stairs2, stairs3, stairs4] = globalParametersVNT1(expe); 
                if exist('parameters','var')
                    stim.stoppingRevNb=parameters(1);
                    stim.stepSize=parameters(2); 
                    stim.robotThr=parameters(3);
                    disp parameters
                end
                expe.inputMode = inputMode;
                expe.displayMode = displayMode;
                stim.destrectL = CenterRectOnPoint([0 0 stim.frameWidth stim.frameHeight], scr.LcenterX, scr.centerY);
                stim.destrectR = CenterRectOnPoint([0 0 stim.frameWidth stim.frameHeight], scr.RcenterX,scr.centerY);
                stim.destRectL1 = CenterRectOnPoint([0 0 stim.frameWidth stim.frameHeight], scr.LcenterX, scr.centerY+stim.vertEcc);
                stim.destRectR1 = CenterRectOnPoint([0 0 stim.frameWidth stim.frameHeight], scr.RcenterX, scr.centerY+stim.vertEcc);
                stim.destRectL2 = CenterRectOnPoint([0 0 stim.frameWidth stim.frameHeight], scr.LcenterX, scr.centerY-stim.vertEcc);
                stim.destRectR2 = CenterRectOnPoint([0 0 stim.frameWidth stim.frameHeight], scr.RcenterX, scr.centerY-stim.vertEcc);
                dispi('Loading DST file ',expe.nameDST)
                  load(fullfile(expe.DSTpath, [expe.nameDST,'.mat']),'DE','leftContr','rightContr', 'leftUpShift', 'rightUpShift', 'leftLeftShift', 'rightLeftShift')
                  expe.leftContr = leftContr; expe.rightContr =rightContr; expe.leftUpShift =leftUpShift; expe.rightUpShift =rightUpShift;
                  expe.leftLeftShift=leftLeftShift; expe.rightLeftShift=rightLeftShift; expe.DE = DE;
                 
     %----------------------------------------------------------------------------
     %   UPDATE LEFT AND RIGHT EYE COORDINATES AND CONTRAST from DST / initialize
     %----------------------------------------------------------------------------
         scr.LcenterXLine= scr.LcenterXLine - expe.leftLeftShift;
         scr.LcenterXDot = scr.LcenterXDot - expe.leftLeftShift;
         scr.RcenterXLine= scr.RcenterXLine - expe.rightLeftShift;
         scr.RcenterXDot = scr.RcenterXDot - expe.rightLeftShift;
         scr.LcenterYLine = scr.centerYLine - expe.leftUpShift;
         scr.RcenterYLine = scr.centerYLine - expe.rightUpShift;
         scr.LcenterYDot = scr.centerYDot - expe.leftUpShift;
         scr.RcenterYDot = scr.centerYDot - expe.rightUpShift;

            disp(expe.name)
            expe.startTime=GetSecs;
            expe.date(end+1)={dateTime};
            expe.goalCounter=1140; 
      
            % outer frames (for fusion) space
            [stim.LmaxL,stim.LminL]=contrSym2Lum(expe.leftContr,15); %white and black, left eye (frames)
            [stim.LmaxR,stim.LminR]=contrSym2Lum(expe.rightContr,15); %white and black, right eye (frames)
            stim.leftFrameLum = stim.LmaxL;
            stim.rightFrameLum = stim.LmaxR;
            stim.frameL = [scr.LcenterXLine-stim.frameWidth/2,scr.LcenterYLine-stim.frameHeight/2,scr.LcenterXLine+stim.frameWidth/2,scr.LcenterYLine+stim.frameHeight/2];
            stim.frameR = [scr.RcenterXLine-stim.frameWidth/2,scr.RcenterYLine-stim.frameHeight/2,scr.RcenterXLine+stim.frameWidth/2,scr.RcenterYLine+stim.frameHeight/2];

            
      %----- ROBOT MODE ------%
        %when in robot mode, make all timings very short
        if expe.inputMode==2
            stim.mask1Duration                 = 0.01;
            stim.itemDuration                  = 0.01;
            stim.mask2Duration                 = 0.01;
            stim.interTrial                    = 0.01;    
            expe.verbose = 'verboseOFF';
        end
        
      %--------- VERGENCE TEST --------% 
      disp('VERGENCE TEST')
      stim.escapeTimeLimit=10;
      expe.lastBreakTime = GetSecs;
              
	%--------------------------------------------------------------------------
    %   DISPLAY INSTRUCTIONS 
    %--------------------------------------------------------------------------
        displaystereotext3(scr,sc(scr.fontColor,scr.box),expe.instrPosition,expe.instructionsVergence.(expe.language),1);
        flip2(expe.inputMode, scr.w,[],0);
        waitForKey(scr.keyboardNum,expe.inputMode);
    %--------------------- WAIT  --------------------------------

          %----- ROBOT MODE ------%
            %when in robot mode, make all timings very short
            if expe.inputMode==2
                stim.mask1Duration                 = 0.001;
                stim.itemDuration                  = 0.001;
                stim.mask2Duration                 = 0.001;
                %stim.responseTrial                = 2000; %not used
                stim.interTrial                    = 0.001;    
            end
      
        
        stim.stopSignal = 0;
        expe.results = nan(4.*stairs1.maxStepNb,12);
        staircase_trial_list = Shuffle([ones(1,stairs1.maxStepNb),2.*ones(1,stairs2.maxStepNb),3.*ones(1,stairs3.maxStepNb),4.*ones(1,stairs4.maxStepNb),]);
        % stairs1 and stairs2 have different starting values and are for the case that we present the upper line in the RE
        % stairs3 and stairs4 too but for the case that the upper line is in the LE
        
      % TRIAL LOOP
        for trial=1:numel(staircase_trial_list)
            if stim.stopSignal; break; end
            dispi('Trial ', trial, expe.verbose)
            current_staircase = staircase_trial_list(trial);
            switch current_staircase
                case 1
                    upper_line_eye = 1; % 1 for RE, -1 for LE
                    [stairs1, expe, stim] = vergenceTestTrial(trial, scr, stim, expe, sounds, stairs1, upper_line_eye,1);                   
                 case 2
                    upper_line_eye = 1; % 1 for RE, -1 for LE
                    [stairs2, expe, stim] = vergenceTestTrial(trial, scr, stim, expe, sounds, stairs2, upper_line_eye,2);
                case 3
                    upper_line_eye = -1; % 1 for RE, -1 for LE
                    [stairs3, expe, stim] = vergenceTestTrial(trial, scr, stim, expe, sounds, stairs3, upper_line_eye,3);
                case 4
                    upper_line_eye = -1; % 1 for RE, -1 for LE
                    [stairs4, expe, stim] = vergenceTestTrial(trial, scr, stim, expe, sounds, stairs4, upper_line_eye,4);
            end
        end      
 
             
        % SAVE DATA
        expe.duration = (GetSecs-expe.startTime)/60;
        dispi('Duration:',expe.duration);
        save(fullfile(expe.datapath,name))
        disp('End of staircases, data saved')       
        

        %===== THANKS ===%
        Screen('FillRect',scr.w, sc(scr.backgr,scr.box));
        displaystereotext3(scr,sc(scr.fontColor,scr.box),[0,500,500,400],expe.thx.(expe.language),1);
        flip2(expe.inputMode, scr.w);
        waitForKey(scr.keyboardNum,expe.inputMode);
        
        %===== QUIT =====%
        precautions(scr.w, 'off');
       
        % PLOT ANALYSIS
        plotVergenceTestV2(fullfile(expe.datapath,name))

catch err   %===== DEBUGING =====%
    sca
    keyboard
    if exist('scr','var'); precautions(scr.w, 'off'); end
    disp(err)
    save(fullfile(expe.datapath,[name,'-crashlog']))
    saveAll([name,'-crashlog.mat'],[name,'-crashlog.txt'])
    rethrow(err);
end
%============================================================================
end

