function [expe, scr, stim, sounds, stairs1, stairs2, stairs3, stairs4] = globalParametersVNT1(expe)
%======================================================================
%  Goal: control panel for the expriment parameters
%======================================================================
    
    %set the randomness random
    try rng('shuffle'); catch; rand('twister', sum(100*clock)); end
    Screen('Preference', 'SkipSyncTests', 0); % HERE CHANGE TO 0!!!

    %======================================================================
    %              WINDOW-SCREEN PARAMETERS 
    %====================================================================== 
    scr = screen_parameters;
    screens=Screen('Screens');
    scr.screenNumber=max(screens);
    scr.box=[scr.paramOptim1,scr.paramOptim2];
    
        %check if vertical and horizontal pixel sizes are the same
        [success, scr.oldResolution, scr.newResolution]  = changeResolution(scr.screenNumber, scr.goalWidthRes, scr.goalHeightRes, scr.goalRefreshRate);
        if success==0; error('See warning - resolution could not be changed appropriately');end 
        scr.pixelSize = scr.newResolution.pixelSize;
        scr.res=Screen('rect', scr.screenNumber); %screen size in pixel, format: [0 0 maxHoriz maxVert]
        scr.ppBymm= scr.res(3)/scr.W;
        if scr.res(3)/scr.W~=scr.res(4)/scr.H; warning('Change the screen resolution to have equal pixel sizes.');end
        scr.VA2pxConstant=scr.ppBymm *10*VA2cm(1,scr.distFromScreen); %constant by scr.Which we multiply a value in VA to get a value in px
        scr.backgr=0; %in cd/m2
        scr.fontColor=10;
        scr.keyboardNum=-1;
        %scr.keyboardNum=scr.keyboardNum(2);
        % Keyboard in the experimental room is keyboardNum = 4
        %scr.keyboardNum=max(PsychHID('NumDevices'))
        scr.w=Screen('OpenWindow',scr.screenNumber, sc(scr.backgr,scr.box), [], 32, 2);      
        scr.fontSize  = 18;
        
        %now defines centers of screen and centers of stereo screens
        %Caution has to be taken because the screen origin for DrawLine and
        %DrawDots are different, and are also dependent on the screen
        %On a viewPixx, screen originates at [1,0] for DrawLine and [0,1]
        %for DrawDots
          scr.centerX = scr.res(3)/2;
          scr.centerY = scr.res(4)/2;
          scr.frameSep = scr.W/4;
          scr.stereoDeviation = scr.ppBymm.*scr.frameSep; %nb of px necessary to add from screen center in order to put a stim a zero disp          
           scr.LcenterX=round(scr.centerX-scr.stereoDeviation);
           scr.RcenterX=round(scr.centerX+scr.stereoDeviation);
           scr.centerY=round(scr.centerY);
           
          %Centers for Drawline
            scr.LcenterXLine=round(scr.centerX-scr.stereoDeviation); %stereo position of left eye center
            scr.RcenterXLine=round(scr.centerX+scr.stereoDeviation); %stereo position of right eye center
            scr.centerYLine=round(scr.centerY); %stereo position of left eye center
          %Centers for Drawdots
            scr.LcenterXDot=round(scr.centerX-scr.stereoDeviation); %stereo position of left eye center
            scr.RcenterXDot=round(scr.centerX+scr.stereoDeviation); %stereo position of right eye center
            scr.centerYDot=round(scr.centerY); %stereo position of left eye center
                       
        %    scr.savepath=strcat(paths(15),'Experiment',filesep,'dataFiles');
    %     scr.frameTime =Screen('GetFlipInterval', scr.onScreen, 10);
    %     scr.monitorRefreshRate=1/scr.frameTime;
        disp(scr)
    %--------------------------------------------------------------------------
    
    %======================================================================
    %              STIMULUS PARAMETERS 
    %======================================================================
        %Line
            stim.lineLum=20; %luminance in cd.m2
            stim.nbLines=3; %nb of lines in a unresolved line stimulus NOT USED - always 3
            stim.lineSizeMin= 20; % in arcmin %20
            stim.eccentricityMin = 15; %eccentricity of the stim in arcmin
            stim.distBetwLines = 12; % distance between lines tips in arcmin
            stim.vertEccMin= stim.lineSizeMin/2 + stim.distBetwLines/2; %vertical eccentricity of the line in arcmin (distance between midscreen and middle of the line to draw)
            stim.jitterRangeMin=30; %eccentricity jitter for lines, in min
            
        %Nonius
            stim.noniusLum=20; 
            stim.noniusLineSizeMin= 20; % half size in arcmin
            stim.noniusLineWidthSec=60; %in arcsec
            stim.noniusOffsetMin= 5; %offset between central fixation and nonius in arcmin
            stim.fixationSizeSec=90; %in arcsec
            
        %Mask
            stim.maskLum=10; %max amplitude of mask luminance
        
        %General
            stim.nbValues=5;
            stim.escapeTimeLimit=5; %(min) nb of min after which escape key is deactivated
            stim.maxAcuity=5/60; %maximal acuity to be tested in arcmin #NOT USED
            stim.minAcuity=135/60; %minimal acuity to be tested in arcmin; values will be [a-2min, a-min, a ,a+min, a+2min]
            % #CHANGE HERE - delete below
            %stim.minAcuity=350/60;
            %stim.colorFixationDesired=stim.lineLum; %color when you have to look at NOT USED
            %stim.colorFixationOn=[0 0 20]; %color when you have to respond
            %stim.contrast=50/100;

        %frames properties
            %stim.frameInVA=2; %size of the inside frame for the frame of squares in deg
            %stim.frameWidth=60; %width of the frames in px
            %stim.squareS=20; %size of a square in a frame in px
            %stim.frameLum=3; %its luminance
            stim.frameWidthVA = 7.1; % witdth of the outside frame in deg
            stim.frameHeightVA = 8;
            stim.frameLineWidthVA=0.2; %line width of the frames in VA
         
            stim.robotThr=100/60; %threshold simulated for vergence (robot)
            stim.robotBias = -500/60; %bias simulated for vergence (robot)
            
        %conversions in pixels
           % stim.frameSize = round(convertVA2px(stim.frameInVA));
            stim.lineSize=round(convertVA2px(stim.lineSizeMin/60)); %in px
            stim.noniusLineSize=round(convertVA2px(stim.noniusLineSizeMin/60)); %in px
            stim.noniusLineWidth=round(convertVA2px(stim.noniusLineWidthSec/3600)); %in px
            stim.eccentricity=round(convertVA2px(stim.eccentricityMin/60)); %in px
            stim.vertEcc=round(convertVA2px(stim.vertEccMin/60)); %in px
            stim.noniusOffset=round(convertVA2px(stim.noniusOffsetMin/60));
            stim.fixationSize=round(convertVA2px(stim.fixationSizeSec/3600));
            stim.jitterRange=round(convertVA2px(stim.jitterRangeMin/60));
            stim.frameLineWidth = round(convertVA2px(stim.frameLineWidthVA));
            stim.frameWidth = round(convertVA2px(stim.frameWidthVA));
            stim.frameHeight = round(convertVA2px(stim.frameHeightVA));
            
       %correct luminance for number of pixel width
       %stim.noniusLum=stim.noniusLumDesired/stim.noniusLineWidth;
       %stim.colorFixation= stim.colorFixationDesired/stim.fixationSize;
       % stim.noniusLum=20;
       % stim.colorFixation=20;
        
        %staircase parameters
            stairs1.trial = 1; % first trial initialization
            stairs1.initial_value = 50/60; %in arcmin 70 280 490 700
            stairs1.desired_threshold = 0.50;
            stairs1.maxInitialStepSize = 270/60; %in arcmin (ASA) - 1.5 logUnit
            %stairs1.stoppingStep = 61/60;      % stopping criterion in arcmin (ASA) - 0.01 logUnit       
            stairs1.maxStepNb = 60;         % maximum number of steps for each staircase
            stairs1.max=3000/60; %maximum value in arcmin          
            %stairs1.stepSize= 73/60; %in arcmin (1up/2down) =>approx 0.2 logUnit
            %stairs1.stoppingRevNb = 30;      % number of rev before stopping (1up/2down)
            %stairs1.excludedValues=0; %number of first measured values that are excluded of last psychom function
            
            stairs2 = stairs1;
            stairs2.initial_value = -50/60;
            stairs3 = stairs1;
            stairs4 = stairs2;
    %--------------------------------------------------------------------------

    %SPECIAL VIEWPIXX
    if scr.viewpixx == 1
        Datapixx('Open');
        Datapixx('EnableVideoScanningBacklight');
        Datapixx('RegWrRd');
        status = Datapixx('GetVideoStatus');
        fprintf('Scanning Backling mode on = %d\n', status.scanningBacklight);
        Datapixx('Close');
    end
    %--------------------------------------------------------------------------
    % TIMING (All times are in MILLISECONDS)
    %--------------------------------------------------------------------------
        stim.mask1Duration                 = 5;
        stim.itemDuration                  = 200; 
        stim.mask2Duration                 = 0;
        %stim.responseTrial                = 2000; %not used
        stim.interTrial                    = 200;   
        disp(stim)
    %--------------------------------------------------------------------------

    %--------------------------------------------------------------------------
    %         sounds PARAMETERS
    %--------------------------------------------------------------------------
        duration=0.2;
        freq1=1000;
        freq2=500;
        sounds.success=soundDefine(duration,freq1);
        sounds.fail=soundDefine(duration,freq2);
        disp(sounds)
    %--------------------------------------------------------------------------
   
    %--------------------------------------------------------------------------
    %         EXPERIENCE PARAMETERS
    %--------------------------------------------------------------------------
        expe.name='VNT1 - Vergence Nonius Task v1';
        expe.verbose = 'verboseON';
        expe.time=[]; %durations of the sessions in min
        expe.vergenceTime=[]; %duration of vergence test
        expe.date={}; %dates of the sessions
        expe.breaks=[]; %for each break, block, trial and duration of the break in sec
        expe.breakTime=10;%time after which there is a small break, in min
        expe.instrPosition=[0,300,400,1100];
        expe.addInstructions1.fr= strcat('ENTRAINEMENT');
        expe.addInstructions1.en= 'TRAINING';
        expe.language = 'fr';
        expe.instructionsVergence.en=strcat('V TEST: You will be displayed couples of lines.',...
            ' Each trial begins with the presentation', ...
            ' of small squares. In the centre is displayed a cross for fixation.',...
            ' Look at it and press any key to start the trial.',...
            ' The cross disappears, a mask appears briefly followed by two lines, one above the other.',...
            ' Task is to judge the offset of the upper line in comparison to the lower one.',...
            ' Answer pressing (left arrow) if the upper line is leftward relative to the lower and (right arrow) otherwise.',...
            ' Press any key to begin.'); 
        expe.instructionsVergence.fr=strcat('TEST V: des lignes vont vous etre present�es. Chaque essai commence avec la presentation',...
            ' de petits carr�s. Au centre se trouve une croix de fixation. ',...
            ' Regardez-la puis appuyez sur une touche pour lancer l''essai.',...
            ' La croix est remplac�e par un masque bref, suivi de deux lignes, l''une au-dessus de l''autre.',...
            ' Un point de fixation peut etre pr�sent ou non. Votre tache est de juger si le decallage de la ligne du haut est plutot sur la',...
            ' gauche ou plutot sur la droite, comparee a la ligne du bas. Repondez en appuyant sur (fleche gauche) si la ligne du haut est',...
            ' plus a gauche et (fleche droite) sinon. Appuyez sur n''importe quelle touche pour commencer.');
        expe.breaktime.fr=strcat('Vous pouvez prendre une courte pause. Appuyez sur une touche pour continuer.');
        expe.breaktime.en=strcat('You can take a short break. Press a key to continue.');
        expe.thx.fr='===========  MERCI  ===========';
        expe.thx.en='===========  THANK YOU  ===========';
        disp(expe)
        
            %--------------------------------------------------------------------------
    %         sounds PARAMETERS
    %--------------------------------------------------------------------------
        sounds = struct();
        [wave1, sounds.freq1] = psychwavread(fullfile(fullfile(expe.vntpath,'functions'),'success.wav'));
        sounds.success = wave1';
        %[wave2, sounds.freq2] = psychwavread(fullfile(fullfile(expe.vntpath,'functions'),'fail.wav'));
        %sounds.fail = wave2';
        InitializePsychSound;
        sounds.handle1 = PsychPortAudio('Open', [], [], 0, sounds.freq1, 2);
        %sounds.handle2 = PsychPortAudio('Open', [], [], 0, sounds.freq2, 2);
        PsychPortAudio('FillBuffer', sounds.handle1, sounds.success);
        %PsychPortAudio('FillBuffer', sounds.handle2, sounds.fail);
        disp(sounds)
    %--------------------------------------------------------------------------
    precautions(scr.w, 'on');
    
    function px=convertVA2px(VA)
        px=round(scr.ppBymm *10*VA2cm(VA,scr.distFromScreen)); 
    end
end