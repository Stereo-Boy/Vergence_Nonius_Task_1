function num=framesAutoFast(num,dim,scr,squareS,color,desiredNum,density,yCenter)
%v2: corrected a bug of centering
%-----------------------------------------------------
%Goal: %Display frames of squares (in zero disparity) around stimuli but quickly.
%-----------------------------------------------------
%It is the fast successor of framesAuto.
%Measured duration: 6.4 ms
%-----------------------------------------------------
%Last edit: june 2010
%-----------------------------------------------------
%Inputs:
%dim: [internal heigth of the stim, and width, height of the frame, and width] in px
%scr -> .frameSep (half difference between the center of the 2 screens) in mm
%    -> .ppBymm (nb of px by mm)
%    -> .res (screen resolution)
%      -> .backgr (background luminance)
%    -> .w (a window)
%num = numero of the frames, 0 to generate a new one (if desiredNum is not
%defined, the frame is numbered as #1, and as desiredNum otherwise)
%squareS -> size of a square in px
%color is a luminance value
%density is the % of squares that are filled
%If yCenter is unspecified, use middle of screen
%
%Don't forget to flip the screen to show the squares
%-----------------------------------------------------
%Function created by Adrien Chopin in june 2010
%_____________________________________________________

if ~exist('desiredNum','var')||isempty(desiredNum); desiredNum=1;end
if isfield(scr, 'backgr')==0; scr.backgr=15; end
if isfield(scr, 'frameSep')==0; scr.frameSep=112.8; end
if ~exist('squareS','var')||isempty(squareS); squareS=12;end
if ~exist('color','var')||isempty(color); color=30;end
if ~exist('density','var')||isempty(density); density=0.75;end
if ~exist('yCenter','var')||isempty(yCenter); yCenter=scr.res(4)/2;end

pen=2;

    if num==0
        num=desiredNum;
        new=1;
    else
        new=0;
    end
   

frameWidth=dim(2)+2*dim(4);
frameHeight=dim(1)+2*dim(3);
vertSquNb=floor(frameHeight./squareS);
horSquNb=floor(frameWidth./squareS);

%correct dim with the right dimensions:
dim=[dim(1) dim(2) (vertSquNb*squareS-dim(1))/2 (horSquNb*squareS-dim(2))/2];

%Choose the squares
if new==1
    %make a square matrix
    squareMatrix=ones(vertSquNb,horSquNb);
    %n=numel(squareMatrix); %number of squares
    xxStart=0:squareS:squareS*(horSquNb)-1;
    yyStart=0:squareS:squareS*(vertSquNb)-1;
    xxEnd=squareS:squareS:squareS*(horSquNb);
    yyEnd=squareS:squareS:squareS*(vertSquNb);
    [Xs,Ys]=meshgrid(xxStart,yyStart);
    [Xe,Ye]=meshgrid(xxEnd,yyEnd);
   
    %delete the center ones
    check=logical((Xe>=dim(4)) .* (Xs<dim(4)+dim(2)) .* (Ye>=dim(3)) .* (Ys<dim(3)+dim(1)));
    squareMatrix(check)=0;
     
   %here, select the potentially active coord
   xCoord=Xs(logical(squareMatrix));
   yCoord=Ys(logical(squareMatrix));
   %count them
   n=numel(xCoord);
   %choose the active squares
   active=randsample(n,round(density.*n));
   rectangles=[xCoord(active)'; yCoord(active)' ; xCoord(active)'+squareS; yCoord(active)'+squareS] ;
    save(strcat('num',num2str(num)));
else
    load(strcat('num',num2str(num))); 
end

%left separation
x1=round(scr.res(3)/2-scr.frameSep.*scr.ppBymm-dim(2)/2-dim(4));
%right separation
x2=round(scr.res(3)/2+scr.frameSep.*scr.ppBymm-dim(2)/2-dim(4));
%top separation
yt=round(yCenter-dim(1)/2-dim(3));
 
rectanglesLeft=[rectangles(1,:)+x1+pen;rectangles(2,:)+yt+pen;rectangles(3,:)+x1-pen;rectangles(4,:)+yt-pen];
rectanglesRight=[rectangles(1,:)+x2+pen;rectangles(2,:)+yt+pen;rectangles(3,:)+x2-pen;rectangles(4,:)+yt-pen];
rect=[rectanglesLeft,rectanglesRight];
Screen('FrameRect', scr.w ,sc(color,scr.box) ,rect ,pen);

    
end