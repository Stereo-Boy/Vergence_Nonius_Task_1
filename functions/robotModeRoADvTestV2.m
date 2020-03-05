function response=robotModeRoADvTestV2(robotprofil)

  %random
  %   response = randsample([1,2], 1,1,[0.5 0.5]);

   %constant
   %  response = 5;
     
   %profils: 
     %  response=robotprofil;
     
 %  psychophysic function
        errorRate=2/100;% here is the % of error
        noise1=norminv(rand(1),0,robotprofil(2));
        %noise2=norminv(rand(1),0,robotprofil(2));
        bias=0/60;
        offset1=robotprofil(1)+noise1/2-robotprofil(3)*bias/2;
        offset2=robotprofil(1)-noise1/2+robotprofil(3)*bias/2;
        if offset1<offset2
            response=1;
        elseif offset1>offset2
            response=2;
        else
          response= randsample([1,2],1);
        end

        if rand(1)<errorRate
            response=3-response; %error
        end
     
% 	%always knows correct answer
%     response=1.5+robotprofil(3)./2;

        %always the same eye:   
          %  response=robotprofil+4; %robotprofil=freq
        
        %always the same orientation
%             response=robotprofil(2)+4;
%             if robotprofil(1)==2
%                 response=11-response;  %robotprofil= freq , rivalrous
%             end
