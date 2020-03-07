function [stairs, expe, stim] = vergenceTestTrial(trial, scr, stim, expe, sounds, stairs, upper_line_eye,staircaseNb)
%================== Vergence test ====================================   
%           
%=======================================================================
% Stimuli: are pairs of dichoptic nonius presented just after the binocular
%   fusion frames with an ISI-mask, including a fixation point 
% Task: is to tell if upper line is more on right or left compared to lower
%   line

   % get next value to show
   stairs = staircase_ASA('value',stairs);
   
   % get response
   [expe, stuff2save, stim]=stimAndRegistrate(trial,stairs.current_value, scr, stim, expe, sounds, upper_line_eye);
   stairs.response = stuff2save(1)-1;  %responseKey (1 left - 2 right) becomes 0 left, 1 right   
         
   % record trial
   stairs = staircase_ASA('record',stairs);
   expe.results(trial, :) = [stairs.history(end, :), upper_line_eye, trial, staircaseNb, stuff2save, stairs.history(end, 2)./2];
    %       col 1:  stairs.trial
    %       col 2:  intensity in linear units (full offset in arcmin, >0 when upper line is on the right of lower line)
    %       col 3:  response - 0 left, 1 right 
    %       col 4:  upper_line_eye / 1 for upper line in RE, -1 for LE
    %       col 5:  trial #
    %       col 6:  staircase #
    %       col 7:  responseKey (1 left - 2 right)
    %       col 8:  correct (0 fail, 1 success)
    %       col 9:  reaction time RT
    %       col 10: timing check - stimulus duration
    %       col 11: jitter
    %       col 12: half-offset (intensity/2 in arcmin) 
end


%============ STIMULUS PRESENTATION AND RESPONSE INTAKE ======================================
function [expe, stuff2save, stim]=stimAndRegistrate(trial,currentValue, scr, stim, expe, sounds, upper_line_eye)

        
       %leftFactor=randsample([-1,1],1); %for eccentricity: -1 is left, 1 is right
       offset=currentValue/2;
       offsetPx=(offset./60).*scr.VA2pxConstant; % in px
       jitter=round(((rand(1).*stim.jitterRange)-stim.jitterRange/2)); 
       masks=nan(stim.frameWidth,stim.frameHeight,2);

      %--------------------------------------------------------------------------
      %=====  Check BREAK TIME  ====================
      %--------------------------------------------------------------------------
       if (GetSecs-expe.lastBreakTime)/60>=expe.breakTime
           Screen('FillRect',scr.w, sc(scr.backgr,scr.box));
           displaystereotext3(scr,sc(scr.fontColor,scr.box),expe.instrPosition,expe.breaktime.(expe.language),1);
           flip2(expe.inputMode, scr.w);
           waitForKey(scr.keyboardNum,expe.inputMode);
           %-------------------- WAIT ------------------------------------------
           expe.lastBreakTime=GetSecs;
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
             if ((expe.startTime-GetSecs)/60)<10 %the first 10 min, allows for esc button
                  allowR=[1,2,4];
             else                             %but not after
                  allowR=[1,2];
             end

        %--------------------------------------------------------------------------
        %   PRELOADING OF TEXTURES DURING INTERTRIAL 
        %--------------------------------------------------------------------------
            if ~isfield(expe,'beginInterTrial'); expe.beginInterTrial=GetSecs;end
            masks(:,:,1)=sc(stim.maskLum.*rand(stim.frameWidth,stim.frameHeight),scr.box);
            masks(:,:,2)=sc(stim.maskLum.*rand(stim.frameWidth,stim.frameHeight),scr.box);
            text1 = Screen('MakeTexture', scr.w, masks(:,:,1));
            text2 = Screen('MakeTexture', scr.w, masks(:,:,2));
            clear masks             
            feuRouge(expe.beginInterTrial+stim.interTrial/1000,expe.inputMode);
            
        %--------------------------------------------------------------------------
        %   DISPLAY FRAMES + NONIUS 
        %--------------------------------------------------------------------------
            %---- background
            Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
            % ------ Outside frames   
            stim.leftFrameLum
            stim.rightFrameLum
            Screen('FrameRect', scr.w, sc(stim.leftFrameLum,scr.box),stim.frameL, stim.frameLineWidth/2);
            Screen('FrameRect', scr.w, sc(stim.rightFrameLum,scr.box),stim.frameR, stim.frameLineWidth/2);
             
             %--------------------------------------------------------------------------
             %   Fixation
             %--------------------------------------------------------------------------
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
                waitForKey(scr.keyboardNum,expe.inputMode); 
                Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
        %-------------------- WAIT ------------------------------------------

        %--------------------------------------------------------------------------
        %   DISPLAY MASK 1
        %--------------------------------------------------------------------------
             Screen('DrawTextures', scr.w, [text1,text2], [], [stim.destrectL',stim.destrectR']);
              [~, onsetMask1] = flip2(expe.inputMode, scr.w,[]);
             %waitForT(stim.mask1Duration,inputMode);
              %ACTUALLY, instead of waiting, draw stuff and wait on next flip
             Screen('FillRect', scr.w, sc(scr.backgr,scr.box));

        %--------------------------------------------------------------------------
        %   DISPLAY STIMULUS - NONIUS LINES
        %--------------------------------------------------------------------------
          if upper_line_eye==-1 
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
                    if expe.displayMode==1
                         Screen('DrawDots', scr.w, [scr.LcenterXDot,scr.RcenterXDot;scr.centerYDot,scr.centerYDot], 1,sc(stim.noniusLum,scr.box));

                          displayText(scr,sc(scr.fontColor,scr.box),[0,0,scr.res(3),200],['/t:',num2str(trial), '/ofst: ', num2str(offset),' /ofp ', num2str(offsetPx), '/upRO:', num2str(upper_line_eye),'/jit:',num2str(jitter)]);
                    end
            %[dummy onsetStim]=flip(inputMode, scr.w,onsetMask1+stim.mask1Duration/1000);
            [~, onsetStim] = flip2(expe.inputMode, scr.w,onsetMask1+stim.mask1Duration/1000);
            if expe.displayMode==1; waitForKey(scr.keyboardNum,expe.inputMode); end
            %waitForT(stim.itemDuration,inputMode);
            %ACTUALLY, instead of waiting, draw stuff and wait on next flip
            Screen('FillRect', scr.w, sc(scr.backgr,scr.box));

%         %--------------------------------------------------------------------------
%         %   DISPLAY MASK 2
%         %--------------------------------------------------------------------------
%               Screen('DrawTextures', scr.w, [text2,text1], [], [stim.destrectL',stim.destrectR']);
               [~, offsetStim] = flip2(expe.inputMode, scr.w,onsetStim+stim.itemDuration/1000);
% %              waitForT(stim.mask1Duration,inputMode);
% %              %ACTUALLY, instead of waiting, draw stuff and wait on next flip
%               Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
%               flip2(expe.inputMode, scr.w,offsetStim+stim.mask1Duration/1000);

        %--------------------------------------------------------------------------
        %   GET RESPONSE
        %--------------------------------------------------------------------------
           [responseKey, RT]=getResponseKb(scr.keyboardNum,0,expe.inputMode,allowR,'robotModeRoADvTestV2',[offset stim.robotThr stim.robotBias upper_line_eye]);

           if responseKey==4 
               disp('Voluntary Interruption')
               stim.stopSignal = 1;
           end

           % if upper line RE, then 
           correct=(responseKey==upper_line_eye/2+1.5);
           
           if expe.inputMode==1
             PsychPortAudio('Start', sounds.handle1, 1, 0, 1);
           end

           if expe.displayMode==1
                Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
                displayText(scr,sc(scr.fontColor,scr.box),[0,100,scr.res(3),200],['responseKey:',num2str(responseKey),'/correct: ',num2str(correct),'/RT:',num2str(RT)]);
                flip2(expe.inputMode, scr.w,[],1);
                waitForKey(scr.keyboardNum,expe.inputMode);
                Screen('FillRect', scr.w, sc(scr.backgr,scr.box));
                flip2(expe.inputMode, scr.w,[],1);
           end
         
        %--------------------------------------------------------------------------
        %  SAVE STUFF
        %--------------------------------------------------------------------------
         stuff2save=[responseKey, correct, RT, offsetStim-onsetStim, jitter];  
         % stuff2save
         %  1  responseKey (1 left - 2 right)
         %  2  correct (0 fail, 1 success)
         %  3  reaction time RT
         %  4  timing check - stimulus duration
         %  5  jitter
         
        %--------------------------------------------------------------------------
        %   INTER TRIAL
        %--------------------------------------------------------------------------
           %inter-trial is actually at the begistepIing of next trial to allow pre-loading of textures in the meantime.
           %to be able to do that, we have to start counting time
           %from now on:
           expe.beginInterTrial=GetSecs;

        %------ Progression bar for robotMode ----%
            if expe.inputMode==2
                Screen('FillRect',scr.w, sc([scr.fontColor,0,0],scr.box),[0 0 scr.res(3)*trial/expe.goalCounter 10]);
                Screen('Flip',scr.w);
            end
end

 