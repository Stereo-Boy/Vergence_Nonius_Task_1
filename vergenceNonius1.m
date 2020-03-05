function vergenceNonius1


try

    clc
    [vgnpath,~]=fileparts(mfilename('fullpath')); %path to vergence nonius folder
    cd(vgnpath)

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
            %displayMode=1; 
            %===============================================================
            
            %----- mode related stuff ---%
            if quickMode==2
                name=nameInput;
                language=input('Language (fr for french; en for english):  ', 's');
            else
                name='defaut';
                language='fr';
            end

    %=========  STARTERS =================================================== %
    %Initialize and load experiment settings (window and stimulus)
    
        %first check is file exists for that name
            
        %if file exist but its default, delete and start afresh          
  

               [expe,scr,stim,sounds]=globalParametersRoADv2(0,Box); 
                if exist('parameters','var')
                    stim.stoppingRevNb=parameters(1);
                    stim.stepSize=parameters(2); 
                    stim.robotThr=parameters(3);
                    disp parameters
                end

%                 respTotal=[];
%                 respTotalDist=[];
%                 trial=0;
%                 breakNb=0;
%                 destrectL = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.LcenterX, scr.centerY);
%                 destrectR = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.RcenterX,scr.centerY);
%                 destRectL1 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.LcenterX, scr.centerY+stim.vertEcc);
%                 destRectR1 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.RcenterX, scr.centerY+stim.vertEcc);
%                 destRectL2 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.LcenterX, scr.centerY-stim.vertEcc);
%                 destRectR2 = CenterRectOnPoint([0 0 stim.frameSize stim.frameSize], scr.RcenterX, scr.centerY-stim.vertEcc);
%                            
%                 %do a list of remaining conditions to do in each pool
%                  poolOrder=randsample([1,2],2,0);
%                 % poolOrder=[1,3,2,4] %CHANGE HERE
%                  distPoolOrder=1;
%                  
%                   pool=[6, -5, 0; ... 
%                         8, -10, 0];
%                   distPool= [12, -5, -10, 0];

                        % Cond # - type    -   fixation or not - disparity
                        %   1   single line       fixation         5 -   skipped
                        %   2   single line       no fixation      5 -   skipped
                        %   3   single line       fixation         10 -  skipped
                        %   4   single line       no fixation      10 -  skipped
                        %   5   single line       fixation        -5 -   skipped
                        %   6   single line       no fixation     -5
                        %   7   single line       fixation         -10 -   skipped
                        %   8   single line       no fixation      -10
                        %   9   distance          fixation      5/10 -   skipped
                        %  10   distance          no fixation   5/10     skipped
                        %  11   distance          fixation      -5/-10 -   skipped
                        %  12   distance          no fixation   -5/-10

                % Also do a list of what to do: if a simple line or a distance is judged with a
                % probability (2/3 1/3) each time
                %distanceOrNotList = Shuffle([0 0 1]);
                %
               %distanceOrNotList = [1 1 0];%CHANGE HERE
               
            
            disp(expe.name)
            startTime=GetSecs;
            %lastBreakTime=GetSecs; %time from the last break
            expe.date(end+1)={dateTime};
            %goalCounter=2280;           

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
              [respVergence, breakNb, expe, lastBreakTime,stairs]=vergenceTestRoADV2();              
              disp(['Duration:',num2str((GetSecs-startTime)/60)]);
              expe.vergenceTime(end+1)=(GetSecs-startTime)/60;
              save(name)
              %saveAll([name,'.mat'],[name,'.txt'])

             %===== THANKS ===%
                Screen('FillRect',scr.w, sc(scr.backgr,scr.box));
                displaystereotext3(scr,sc(scr.fontColor,scr.box),[0,500,500,400],expe.thx.(language),1);
                %displayText(scr,sc(scr.fontColor,scr.box),[scr.res(3)/2-250,500,500,400],thx.(expe.language))
                flip(tmp, scr.w);   
                waitForKey(scr.keyboardNum,tmp); 

             %===== QUIT =====%
                 %warnings 
                 precautions(scr.w, 'off');


catch err   %===== DEBUGING =====%
    keyboard
    if exist('scr','var'); precautions(scr.w, 'off'); end
    disp(err)
    save([name,'-crashlog'])
    saveAll([name,'-crashlog.mat'],[name,'-crashlog.txt'])
    rethrow(err);
end
%============================================================================
end

