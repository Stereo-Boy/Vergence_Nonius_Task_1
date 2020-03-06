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
    disp(['Duration: ', num2str(expe.vergenceTime)]);
    disp(['Edition: ', num2str(stairs.edition)]);
%initalize parameters
colors=['r', 'k','y','b','m','c','g';'r', 'k','y','b','m','c','g'; 'r', 'k','y','b','m','c','g'; 'r', 'k','y','b','m','c','g'];
close all;
TextTable.fig1.subfig1.en={'Staircases','log - Offset (arcmin)','Staircase step (#)'};
TextTable.fig1.subfig2.en={'Estimation by gaussian fit','p(Success)','Offset (arcmin)'};
TextTable.fig1.subfig3.en={'Estimation by raw data','p(Success)','Offset (arcmin)'};
TextTable.fig3.subfig1.en={'Condition 1: ev','p(Right response)','Offset (arcmin)'};
%TextTable.fig3.subfig2.en={'Condition 2: ev','p(Right response)','Offset (arcmin)'};
fontSize=12;

%plot staircases
disp('Staircases')
nbCond=size(stairs.startValues,1);
nbLevel=size(stairs.startValues,2);

for i=1:nbCond
    for j=1:nbLevel
        coloriz=colors(j,i);
        subplot(3,2,1:2)
        hold on
        nn= stairs.currentStepNb(i,j);
        y1=squeeze( stairs.valuesArray(i,j,1:nn));
        %y2=moving_average(squeeze(resp_array(i,j,1:nn)),3,1);
        plot(1:nn,y1,'color',coloriz)
    end
end
legendAxis(TextTable,1,1,'en',fontSize)  ;

xx=stairs.xx;
%plot condition averages
disp('Averages:')
for i=1:nbCond 
        subplot(3,2,3)
        coloriz=colors(1,i);
        line(exp([stairs.thresLine(i,1), stairs.thresLine(i,1)]),[0 1],'color',coloriz,'LineStyle','--')
        hold on
        plot(exp(stairs.valueClasses(i,:,1)),stairs.valueClasses(i,:,2),'-o','color',coloriz)
        plot(exp(xx),stairs.yg1(i,:),'-','color',coloriz)
        line(exp([stairs.thresLine(i,2), stairs.thresLine(i,2)]),[0 1],'color',coloriz,'LineStyle','-')
        legendAxis(TextTable,1,2,'en',fontSize)  ;

        subplot(3,2,5)
        plot(exp(stairs.values{i}),stairs.dataResp{i},'o','color',coloriz)
        hold on
        plot(exp(xx),stairs.yg2(i,:),'-','color',coloriz)
        line(exp([stairs.thresLine(i,3), stairs.thresLine(i,3)]),[0 1],'color',coloriz,'LineStyle','-')
        %fprintf('ThresLine using fitting function = (%5.3f).\n', stairs.thresLine(i,2));
        %fprintf('ThresLine using raw data fit = (%5.3f).\n', stairs.thresLine(i,3));
        if exist('respVergence')
            fprintf('Threshold using fitting function = %5.3f arcsec.\n', 60.*exp(respVergence(i,2)));
           % fprintf('Threshold using raw data fit = (%5.3f).\n', 10.^respVergence(i,3));
        end
        legendAxis(TextTable,1,3,'en',fontSize)  ;
end

% disp('Each level:')
% %plot cond/levels too
% for i=1:nbCond
%     disp(['Condition',num2str(i)])
%      for j=1:nbLevel  
%         subplot(3,2,4)
%         hold on
%         coloriz=colors(j,i);
%         plot(exp(squeeze(stairs.lvlClasses(i,j,:,1))),squeeze(stairs.lvlClasses(i,j,:,2)),':o','color',coloriz)
%         plot(exp(xx),squeeze(stairs.yg1lvl(i,j,:)),'-','color',coloriz)
%         line(exp([stairs.thresLvlLine(i,j,2), stairs.thresLvlLine(i,j,2)]),[0 1],'color',coloriz,'LineStyle',':')
%         legendAxis(TextTable,1,2,'en',fontSize)  ;
% 
%         subplot(3,2,6)
%         plot(exp(stairs.values{i}),stairs.dataResp{i},'o','color',coloriz)
%         hold on
%         plot(exp(xx),squeeze(stairs.yg2lvl(i,j,:)),'-','color',coloriz)
%         line(exp([stairs.thresLvlLine(i,j,3), stairs.thresLvlLine(i,j,3)]),[0 1],'color',coloriz,'LineStyle',':')
%         %fprintf('ThresLine using fitting function = (%5.3f).\n', stairs.thresLvlLine(i,j,2));
%         %fprintf('ThresLine using raw data fit = (%5.3f).\n', stairs.thresLvlLine(i,j,3));
%         fprintf('Threshold using fitting function = %5.3f arcsec.\n', 60.*exp(stairs.threslvl(i,j,2)));
%         %fprintf('Threshold using raw data fit = (%5.3f).\n', 10.^stairs.threslvl(i,j,3));
%         legendAxis(TextTable,1,3,'en',fontSize)  ;
%      end
% end
% 
% %PUT ALL DATA TOGETHER
% theValues{1}=[]; theResp{1}=[];
% theValues{2}=[]; theResp{2}=[];
% for e=1:stairs.edition
%       load(fullfile(datapath,[name,'-vTest-ed',num2str(e),'.mat']))
%         for i=1:nbCond
%             theValues{i}=[theValues{i};stairs.values{i}];
%             theResp{i}=[theResp{i};stairs.dataResp{i}];
%         end
%         list=stairs.trialList{e};
%        stepsnb(e)=size(list(isnan(list(:,1))==0,1),1);
% end
% 
% cmin1=[log(10/60) 0.001 1];    %min
% cmax1=[log(1000/60) 1000 1];      %max
% p0=(cmin1+cmax1)/2;   %start 
% xx=cmin1(1):0.01:cmax1(1);
%          
% disp('All editions together:')
% for i=1:nbCond
%          %then split the data for each condition in groups with equal numbers of data
%           theClasses=makeLevelEqualBounds([theValues{i},theResp{i}],7, 'nanmean');
%     
%          %then fit it with a cumulative gaussian
%            %estimate the parameters
%              x1=theClasses(:,1)';        range=x1(end)-x1(1);            y1=theClasses(:,2)';
%             %correct valueClassesTmp (that is between 0.5 and 1) to go
%             %between 0 and 1:
%               y1c=2.*(y1-0.5);
%               theP1 = mlfit('cumulGauss6', p0, cmin1,cmax1,[x1(1)-range,x1,x1(end)+range], [0,y1c,1])    ;
%               yG = cumulGauss6(xx, theP1);
%               theThres=theP1(1);
%               %inverse correction for yg
%               yG= 0.5 + yG./2 ;
%        figure(2)
%         coloriz=colors(1,i);
%          plot(exp(x1),y1,'o-','color',coloriz)
%         hold on
%         plot(exp(xx),yG,'-','color',coloriz)
%         line(exp([theThres, theThres]),[0 1],'color',coloriz,'LineStyle',':')
%         fprintf('Threshold using fitting function = %5.3f arcsec.\n', 60.*exp(theThres));
%         %fprintf('Threshold using raw data fit = (%5.3f).\n', 10.^theThres);
%         legendAxis(TextTable,1,2,'en',fontSize)  ;
% end

%Separate data according to the offset (left or right) to compute bias and
%unbiased thresholds
cmin1=[-900/60 0.001 1];    %min
cmax1=[900/60 1000 1];      %max
p0=(cmin1+cmax1)/2;   %start 
xx=cmin1(1):0.01:cmax1(1);
disp('Separate offset')
listTot=stairs.trialList{1};
%change response from to 1 = right, 0 = left (ordinate)
 listTot(:,9)=listTot(:,9)-1; 
%then compute correct abcissa (offset values)
listTot(:,7)=listTot(:,7).*listTot(:,8); 
for i=1:nbCond
       %figure(3)
       subplot(3,2,[4 6])
        %coloriz=colors(1,i);
          list=listTot(listTot(:,4)==i,:);
         %then split the data for each condition in groups with equal numbers of data
          list1=list(list(:,13)==1,:); % upper line in right eye
          list2=list(list(:,13)==-1,:); % uppper line in left eye
          
          %theClasses=makeLevelEqualBounds([list(:,7),list(:,9)],7, 'nanmean'); 
          theClasses1=makeLevelEqualBounds([list1(:,7),list1(:,9)],7, 'nanmean');
          theClasses2=makeLevelEqualBounds([list2(:,7),list2(:,9)],7, 'nanmean');
            
         %then fit it with a cumulative gaussian
           %estimate the parameters
%              x1=theClasses(:,1)';        range=x1(end)-x1(1);            y1=theClasses(:,2)';
%               theP1 = mlfit('cumulGauss6', p0, cmin1,cmax1,[x1(1)-range,x1,x1(end)+range], [0,y1,1])    ;
%               yG = cumulGauss6(xx, theP1);
%               bias=theP1(1);
%               theThres=theP1(2).*0.67;
%           plot(x1,y1,':','color',coloriz)
           hold on
        
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
        
%         plot(xx,yG,':','color',coloriz)
%         line([bias, bias],[0 1],'color',coloriz,'LineStyle',':')
        plot(xx,yG1,'-r')
        line([bias1, bias1],[0 1],'color','r','LineStyle','-')
        plot(xx,yG2,'-b')
        line([bias2, bias2],[0 1],'color','b','LineStyle','-')
        %disp(['Threshold using fitting function = ',num2str(60.*(theThres)),'  arcsec.']);
        disp(['Threshold using fitting function (Upper line in RE) = ',num2str(60.*(theThres1)),' arcsec.']);
        disp(['Threshold using fitting function (Upper line in LE) = ',num2str(60.*(theThres2)),' arcsec.']);
        %disp(['Bias using fitting function = ',num2str(60.*(bias)),'  arcsec.']);
        disp(['Bias using fitting function (Upper line in RE) = ',num2str(60.*(bias1)),' arcsec.']);
        disp(['Bias using fitting function (Upper line in LE)= ',num2str(60.*(bias2)),' arcsec.']);
        %fprintf('Threshold using raw data fit = (%5.3f).\n', 10.^theThres);
        ylabel('p(Right response)')
        xlabel('Offset (arcmin) [>0 if upper on the right of lower]')
        legend('Upper line in RE','in LE')
        disp(['Final bias (negative is over-convergence) = fixation disparity = ',num2str(60.*(bias1-bias2)),' arcsec.']);
        disp(['Final mean vergence noise after bias correction = ',num2str(60.*mean([theThres1,theThres2])),' arcsec.']);
end

%thr=60.*exp(respVergence(:,2));
%stepsnbT=sum(stepsnb);




