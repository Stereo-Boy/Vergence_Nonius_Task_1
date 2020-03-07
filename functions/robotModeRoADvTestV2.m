function response=robotModeRoADvTestV2(robotprofil)

  %random
  %   response = randsample([1,2], 1,1,[0.5 0.5]);

   %constant
   %  response = 5;
     
   %profils: 
     %  response=robotprofil;
     
 %  psychophysic function
        errorRate=2/100;% here is the % of error
        offset = robotprofil(1);
        noise = robotprofil(2)./0.67;
        bias = robotprofil(3);
        upper_line_eye = robotprofil(4);
        vergenceNoise = norminv(rand(1),bias,noise);
        %noise2=norminv(rand(1),0,robotprofil(2));
        offsetUp = -upper_line_eye.*vergenceNoise/2 + offset;
        offsetDown =  upper_line_eye.*vergenceNoise/2 - offset;

%         noise1=norminv(rand(1),0,robotprofil(2));
%         noise2=norminv(rand(1),0,robotprofil(2));
%         offset1=robotprofil(1)+noise1/2-robotprofil(3)*bias/2;
%         offset2=robotprofil(1)-noise1/2+robotprofil(3)*bias/2;
        
        if offsetUp<offsetDown
            response=1;
        elseif offsetUp>offsetDown
            response=2;
        else
          response= randsample([1,2],1);
        end

        if rand(1)<errorRate
            response=3-response; %error
        end
     
