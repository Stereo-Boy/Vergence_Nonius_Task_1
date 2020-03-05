function keyboardNum=findKeyboardNumber(skipFlag)
    %====== FIND KEYBOARD NUMBER
    %========================================================= 
    if ~exist('skipFlag'); skipFlag=0; end
    default=-1;
        keyboardNum=GetKeyboardIndices;
        if numel(GetKeyboardIndices)>1 %more than one kb
            if skipFlag==1 %skip if robotmode or testmode
                %try to load the information if possible
                if exist('keyboardNum.mat','file')==2
                    load('keyboardNum.mat','keyboardNum')
                else %default
                    keyboardNum=default;
                end
            else
                %if many, ask for it: (could be set to -1 to merge all the
                %connected Kb devices
                keyboardNum=GetKeyboardIndices; %check for a=PsychHID('Devices') and then a.usageName
                disp('Press a key to get keyboard number:')
                %wait for all keys are released
                keyIsDown1=1;    keyIsDown2=1;
                while keyIsDown1 || keyIsDown2
                    keyIsDown1=KbCheck(keyboardNum(1));
                    keyIsDown2=KbCheck(keyboardNum(2));
                end

                %get the active keyboard number
                while keyIsDown1==0 && keyIsDown2==0
                    keyIsDown1=KbCheck(keyboardNum(1));
                    keyIsDown2=KbCheck(keyboardNum(2));
                end
                keyboardNum=keyboardNum(logical([keyIsDown1,keyIsDown2]));
                disp(keyboardNum); 
                save('keyboardNum.mat','keyboardNum')
                WaitSecs(1);
            end
        end
    %================================================================
end