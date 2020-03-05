function drawStereoLine(w, positionXL,positionXR, positionYL, positionYR,xL, xR, L, sizeL, box, zero, check)
%=========================================================================
% Goal of the function is to draw vertical lines whose position can be resolved 
% with a subpixel precision. 
% Subpixel precision is achieved through three adjacent lines are drawn and perceived
% as one, whose luminance is the sum of all line luminances and position is the average 
% of their position weighted by their luminance.
% -------------------------------------------------------------------------
%   w is a psychtoolbox screen
%   positionXL,positionXR: positions of left and right eye centers for the
%   lines in px
%   positionYL, positionYR: same in y dimension
%   xL and xR are the horizontal deviations in px from positionXL and positionXR
%   L: required total luminance for the unresolved line in cd.m-2
%   sizeL is the vertical line size in px
%   box is the one from scr.box
%   zero is the background value, which is considered here as zero for
%   luminance (if backgound is more luminance, then we invert the calculation)
%   check is a memory parameter: are you sure that you did not round the disparity value in px transmitted here? Because if it is the case, 
%   what is the point of having subpixel precision then? Check all your conversion functions and attribute 1 to this parameter then.
%--------------------------------------------------------------------------
% Function created in june 2013 - adrien chopin 
%--------------------------------------------------------------------------
if ~exist('check','var'); check=0; end
if check==0
    disp('Check is set to 0 in drrawStereoLine: are you sure that you did not round the disparity values in px transmitted here? Because if it is the case, what is the point of having subpixel precision then? Check all your conversion functions and attribute 1 to this check parameter then.');
end
if ~exist('zero','var'); zero=0; end
% %first, convert the decimal part of the centers into deviation
    intPositionXL=fix(positionXL); %integer part
    decPositionXL=positionXL-intPositionXL; %decimal part
    signXL=sign(xL); %sign of offset
    xL=xL+signXL.*decPositionXL;
    
    intPositionXR=fix(positionXR); %integer part
    decPositionXR=positionXR-intPositionXR; %decimal part
    signXR=sign(xR); %sign of offset
    xR=xR+signXR.*decPositionXR;
    
%convert every not subpixel disparity into a shift of the lines
    if abs(xL)>=1
       intxL=fix(xL); %signed integer part
       xL=xL-intxL; %signed decimal part
       intPositionXL=intPositionXL+intxL;
    end

    if abs(xR)>=1
       intxR=fix(xR);%integer part
       xR=xR-intxR; %decimal part
       intPositionXR=intPositionXR+intxR;
    end
    
%if more than a half pixel, move the lines to next pixel and go in the other direction
    if abs(xL)>0.5
        finalPosXL=intPositionXL+signXL;
        xL=xL-signXL;
    else
       finalPosXL=intPositionXL;
    end

    if abs(xR)>0.5 
        finalPosXR=intPositionXR+signXR;
        xR=xR-signXR;
    else
       finalPosXR=intPositionXR;
    end

% positionXL
% finalPosXL
% xL
% positionXR
% finalPosXR
% xR

  %computes the luminances for each of the 3 lines in left eye

    l1L=L.*(1/3 - xL./2);
    l3L=L.*(1/3 + xL./2);
    l2L=(l1L+l3L)./2; %middle line is just the mean of the others   


   %computes the luminances for each of the 3 lines in right eye
    l1R=L.*(1/3 - xR./2);
    l3R=L.*(1/3 + xR./2);
    l2R=(l1L+l3L)./2;

    if L<zero %invert polarity when background is brigther than stim 
        tmp=l1L;
        l1L=l3L;
        l3L= tmp;
        tmp=l1R;
        l1R=l3R;
        l3R= tmp;
    end
    
%the 3 left eye lines
Screen('DrawLine',w,sc(l1L,box),finalPosXL-1,positionYL+sizeL/2,finalPosXL-1,positionYL-sizeL/2,1);
Screen('DrawLine',w,sc(l2L,box),finalPosXL,positionYL+sizeL/2,finalPosXL,positionYL-sizeL/2,1);
Screen('DrawLine',w,sc(l3L,box),finalPosXL+1,positionYL+sizeL/2,finalPosXL+1,positionYL-sizeL/2,1);

%the 3 right eye lines
Screen('DrawLine',w,sc(l1R,box),finalPosXR-1,positionYR+sizeL/2,finalPosXR-1,positionYR-sizeL/2,1);
Screen('DrawLine',w,sc(l2R,box),finalPosXR,positionYR+sizeL/2,finalPosXR,positionYR-sizeL/2,1);
Screen('DrawLine',w,sc(l3R,box),finalPosXR+1,positionYR+sizeL/2,finalPosXR+1,positionYR-sizeL/2,1);
     

end
