function vergenceNonius1(parameters)


try

    clc
    [vgnpath,~]=fileparts(mfilename('fullpath')); %path to vergence nonius folder
    datapath = fullfile(vgnpath,'dataFiles');
    addpath(fullfile(vgnpath,'functions'))
    cd(vgnpath)

    %==========================================================================
    %                           QUICK PARAMETERS
    %==========================================================================

           %===================== INPUT MODE ==============================
            %1: User  ; 2: Robot 
            %The robot mode allows to test the experiment with no user awaitings
            %or long graphical outputs, just to test for obvious bugs
            inputMode=2; 
            %==================== QUICK MODE ==============================
            %1: ON  ; 2: OFF 
            %The quick mode allows to skip all the input part at the beginning of
            %the experiment to test faster for what the experiment is.
            quickMode=2; 
            %==================== DISPLAY MODE ==============================
            %1: ON  ; 2: OFF 
            %In Display mode, some chosen variables are displayed on the screen
            displayMode=2; 
            %===============================================================
            
            %----- mode related stuff ---%
            if quickMode==2
                name=nameInput(datapath);
                language=input('Language (fr for french; en for english):  ', 's');
            else
                name='default';
                language='fr';
            end

    %=========  STARTERS =================================================== %
    %Initialize and load experiment settings (window and stimulus)
               [expe,scr,stim,sounds]=globalParametersVNT1; 
                if exist('parameters','var')
                    stim.stoppingRevNb=parameters(1);
                    stim.stepSize=parameters(2); 
                    stim.robotThr=parameters(3);
                    disp parameters
                end
                expe.inputMode = inputMode;
                destrectL = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.LcenterX, scr.centerY);
                destrectR = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.RcenterX,scr.centerY);
                destRectL1 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.LcenterX, scr.centerY+stim.vertEcc);
                destRectR1 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.RcenterX, scr.centerY+stim.vertEcc);
                destRectL2 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.LcenterX, scr.centerY-stim.vertEcc);
                destRectR2 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.RcenterX, scr.centerY-stim.vertEcc);
                       
            disp(expe.name)
            startTime=GetSecs;
            expe.date(end+1)={dateTime};
            goalCounter=2280;           

      %----- ROBOT MODE ------%
        %when in robot mode, make all timings very short
        if inputMode==2
            stim.mask1Duration                 = 0.01;
            stim.itemDuration                  = 0.01;
            stim.mask2Duration                 = 0.01;
            %stim.responseTrial                = 2000; %not used
            stim.interTrial                    = 0.01;    
        end
        
      %--------- VERGENCE TEST --------% 

              disp('VERGENCE TEST')
              stim.escapeTimeLimit=100;
              save('temp.mat')  
              [respVergence, expe, lastBreakTime,stairs]=vergenceTestRoADV2();              
              disp(['Duration:',num2str((GetSecs-startTime)/60)]);
              expe.vergenceTime(end+1)=(GetSecs-startTime)/60;
              save(fullfile(datapath,name))
              %saveAll([name,'.mat'],[name,'.txt'])

             %===== THANKS ===%
                Screen('FillRect',scr.w, sc(scr.backgr,scr.box));
                displaystereotext3(scr,sc(scr.fontColor,scr.box),[0,500,500,400],expe.thx.(language),1);
                %displayText(scr,sc(scr.fontColor,scr.box),[scr.res(3)/2-250,500,500,400],thx.(expe.language))
                flip2(expe.inputMode, scr.w);
                waitForKey(scr.keyboardNum,expe.inputMode); 

             %===== QUIT =====% 
                 precautions(scr.w, 'off');


catch err   %===== DEBUGING =====%
    sca
    keyboard
    if exist('scr','var'); precautions(scr.w, 'off'); end
    disp(err)
    save(fullfile(datapath,[name,'-crashlog']))
    saveAll([name,'-crashlog.mat'],[name,'-crashlog.txt'])
    rethrow(err);
end
%============================================================================
end

