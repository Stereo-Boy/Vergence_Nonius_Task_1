function plotVergenceTestV2(name)
%------------------------------------------------------------------------
%
%================== Plot Vergence test results====================================   

%Get saved results
clc
[vgnpath,~]=fileparts(fileparts(mfilename('fullpath'))); %path to vergence nonius folder
datapath = fullfile(vgnpath,'dataFiles');
addpath(fullfile(vgnpath,'functions'))

load(fullfile(datapath,[name,'.mat']))
%dispi('Duration: ', expe.duration);
close all;

%plot staircases
disp('Staircases')
subplot(3,2,1:2)
for i=[1 3 2 4]
    stairs = eval(['stairs',num2str(i)]);
    if i==1||i==2
        plot(stairs.history(:,1),(stairs.history(:,2)),'-r');
    else
        plot(stairs.history(:,1),(stairs.history(:,2)),'-b');
    end
    hold on
    plot(stairs.history(stairs.history(:,3)==1,1),(stairs.history(stairs.history(:,3)==1,2)),'og');
    plot(stairs.history(stairs.history(:,3)==0,1),(stairs.history(stairs.history(:,3)==0,2)),'xr');
end
title('Staircases')
legend('Upper line in RE','Right response','Left response','Upper in LE')
xlabel('Staircase trial #')
ylabel('Offset (arcmin) [>0 if upper on the right of lower]')
% stairs.history:
%       col 1:  stairs.trial
%       col 2:  intensity in linear units
%       col 3:  response - 0 left, 1 right 
%legendAxis(TextTable,1,1,'en',fontSize)  ;


%Separate data according to the offset (left or right) to compute unbiased thresholds
disp('Separate offset conditions')
subplot(3,2,[3 4 5 6])
% select offsets and right responses for trials with upper line in RE and in LE separately
list1 = expe.results(expe.results(:,4)==1,[2 3]); % list1(:,2) = list1(:,2)-1;
list2 = expe.results(expe.results(:,4)==-1,[2 3]);% list2(:,2) = list2(:,2)-1;
theClasses1=makeLevelEqualBoundsMean([list1(:,1),list1(:,2)],7);
theClasses2=makeLevelEqualBoundsMean([list2(:,1),list2(:,2)],7);
hold on
xx = min([list1(:,1);list2(:,1)]):0.01:max([list1(:,1);list2(:,1)]);
cmin1=[min(xx) 0.001 1];    %min
cmax1=[max(xx) 1000 1];      %max
p0=(cmin1+cmax1)/2;   %start 

%then fit it with a cumulative gaussian
%estimate the parameters
x1=theClasses1(:,1)';        range=x1(end)-x1(1);            y1=theClasses1(:,2)';
theP1 = mlfit('cumulGauss6', p0, cmin1,cmax1,[x1(1)-range,x1,x1(end)+range], [0,y1,1])    ;
yG1 = cumulGauss6(xx, theP1);
bias1=theP1(1);
theThres1=theP1(2).*0.67;
plot(x1,y1,'vr-')

%then fit it with a cumulative gaussian
%estimate the parameters
x1=theClasses2(:,1)';        range=x1(end)-x1(1);            y1=theClasses2(:,2)';
theP1 = mlfit('cumulGauss6', p0, cmin1,cmax1,[x1(1)-2*range,x1,x1(end)+2*range], [0,y1,1])    ;
yG2 = cumulGauss6(xx, theP1);
bias2=theP1(1);
theThres2=theP1(2).*0.67;
plot(x1,y1,'xb-')
plot(xx,yG1,'-r')
line([bias1, bias1],[0 1],'color','r','LineStyle','-')
plot(xx,yG2,'-b')
line([bias2, bias2],[0 1],'color','b','LineStyle','-')
%disp(['Threshold using fitting function = ',num2str(60.*(theThres)),'  arcsec.']);
disp(['Threshold (Upper line in RE) = ',num2str(round(60.*(theThres1))),' arcsec']);
disp(['Threshold (Upper line in LE) = ',num2str(round(60.*(theThres2))),' arcsec']);
%disp(['Bias using fitting function = ',num2str(60.*(bias)),'  arcsec.']);
disp(['Partial bias (Upper line in RE) = ',num2str(round(60.*(bias1))),' arcsec']);
disp(['Partial bias (Upper line in LE)= ',num2str(round(60.*(bias2))),' arcsec']);
%fprintf('Threshold using raw data fit = (%5.3f).\n', 10.^theThres);
ylabel('p(Right response)')
xlabel('Offset (arcmin) [>0 if upper on the right of lower]')
legend('Upper line in RE','Upper in LE')
disp(['Final bias (negative is over-convergence) = fixation disparity = ',num2str(round(60.*(bias1-bias2)./2)),' arcsec']);
disp(['Final mean vergence noise after bias correction = ',num2str(round(60.*mean([theThres1,theThres2]))),' arcsec']);




