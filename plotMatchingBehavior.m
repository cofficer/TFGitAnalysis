function  plotMatchingBehavior( ~ )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



%%
%Calculate the probability matching per participant.
%load('paramFits.mat')
setting.numParticipants        = 29; %need to remove JRu and MGo somehow.

%Use simulated behavior or not.
simulate = 0;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

setting.bhpath          = bhpath;

%
[ PLA,ATM ] = loadSessions(setting);

figure(1),clf
hold on

PLA=[PLA,ATM];

%Variable that determines whether to plot per participant or aggregate
%prob matching.
oneFig      = 0;
%Only plot certain participnats:
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/perfOptimID1param.mat');
plotOptim = 0;
if plotOptim
    %PLA=partOptim;
    
    PLAshort        = cellfun(@(n) n(1:3),PLA,'UniformOutput',false);
    partOptimshort  = cellfun(@(n) n(1:3),partOptim,'UniformOutput',false);
    
    %Identify the index of participants that have optimal fits to get their
    %full behavioral file names.
    indxOptim = ismember(PLAshort,partOptimshort);
    
    PLA=PLA(~indxOptim);
    
    
else
    
    %PLA=[PLA,ATM];
    
end

%Iterate each block calculated
countBlocks = 0;

allverticals=0;
allhorizontals=0;
allverticalsR = 0;
allhorizontalsR = 0;

for sess =1:length(PLA) %minus 2 just so that there it fills out subplots.
    %Load the results per participant
    
    load(PLA{sess})
    %participantPath = PLA{participant};
    
    %load(ATM{participant})
    %participantPath = ATM{participant};
    %participant = participant+1;
    
    
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    
    if ~oneFig
    subplot(8,8,sess)
    end
    hold on
    %Calculate the reward delivered,
    rewarDelivered = 0;
    allpropCV=0;
    allpropRV=0;
    
    
    %Store the order of rewards
    if length(results.probHor)<10
        orderRew(sess,:) = [results.probHor,nan(1,10-length(results.probHor))];
    else
        orderRew(sess,:) = results.probHor(1:10);
    end
    
    %Variables for storing all the block for one session
    curentPartRV=[];
    curentPartCV=[];
    
    line([-3 3],[-3 3],'color','r')
    
    
    for ib = 1:results.nblocks
        
        
             
        %Starting point is 0. 
        countBlocks = countBlocks+1;
        
        %Find the distribution of rewards throughou all sessions.
        rewardprob(countBlocks) = results.blocks{ib}.probHor;
   
        
        %Remove all trails with no resp etc. 
        validTrials=results.blocks{ib}.trlinfo(:,7)~=0;
        
        %Calculate the rewards recieved.
        rewarDelivered = rewarDelivered +...
            sum(results.blocks{ib}.newrewardHor(validTrials)) +...
            sum(results.blocks{ib}.newrewardVer(validTrials));
        
        rewardAvailableH(countBlocks) = sum(results.blocks{ib}.newrewardHor);
        rewardAvailableV(countBlocks) = sum(results.blocks{ib}.newrewardVer);
        
        %All collected rewards
        allR=(results.blocks{ib}.trlinfo(:,8));
        allR=allR(validTrials);
        %All verticl choices
        allCV=(results.blocks{ib}.trlinfo(:,7)-1);
        allCV=allCV(validTrials);
        %All verticl rewards
        allRV=allR(logical(allCV));
        %All horizontl rewards
        allRVH = allR(logical(~allCV));
        
        %Proportion of verticl choices
        propCV(countBlocks)=sum(allCV)/sum(~allCV);%length(allCV);
        
        allverticals   =[allverticals,allCV'];
        allhorizontals =[allhorizontals,~allCV'];
        
          allverticalsR   =[allverticalsR,allRV'];
        allhorizontalsR =[allhorizontalsR,allRVH'];
        
%         if propCV(countBlocks) > 20
%             %disp(countBlocks)
%             disp(PLA{sess})
%             disp(countBlocks)
%             disp(sess)
%             disp(ib)
%         end


        %Proportion vertical rewards
        propRV(countBlocks)=sum(allRV)/sum(allRVH);
        
        %All reward recieved from vertical choice
        %Proportion vertical choice == proportion vertical reward.
        
        %plot(propRV,propCV,'.','color','k','markers',15)
        
        
        %allpropCV=allpropCV+propCV;
        %allpropRV=allpropRV+propRV;
        
%         if propRV>1
%             disp(PLA{sess})
%             disp(sess)
%             disp(ib)
%             
%         end
        
      
        
    if ~oneFig
     plot(log(sum(allRV)/sum(allRVH)),log(sum(allCV)/sum(~allCV)),'.','color','k','markers',15)
     
     %Store all the current block for the session. 
     curentPartRV=[curentPartRV,sum(allRV)/sum(allRVH)];
     curentPartCV=[curentPartCV,(sum(allCV)/sum(~allCV))];
    
    end
        

    end
    
    if ~oneFig
        title(PLA{sess}(1:3))
        %add best fit line
        total   = isfinite(log(curentPartRV))+isfinite(log(curentPartCV));
        idx     = (total==2);
        
        p       = polyfit((log(curentPartRV(idx))),(log(curentPartCV(idx))),1);
        f       = polyval(p,(log(curentPartRV(idx))));
        bestfit=plot((log(curentPartRV(idx))),f,'-k');
        legend(bestfit,['Slope = ',num2str(p(1),3),'; bias = ', num2str(p(2),3)])
        
        sessionBestFits(sess,:)=p;
        
    end
    %plot(allpropCV/ib,allpropRV/ib,'.','color','k','markers',15)
    rewgot(sess)=sum(rewardStreamAll)/rewarDelivered;
    %     percrew(sess)=rewarDelivered/length(rewardStreamAll)
    %     disp(PLA{sess})
    %     disp(rewarDelivered)
    %     disp(sum(rewardStreamAll))
end
if oneFig
    plot(log(propRV),log(propCV),'.','color','k','markers',15)
    %title('Probability matching for all blocks','FontSize',20)
    xlabel('Proportion vertical rewards','FontSize',20)
    ylabel('Proportion vertical choices','FontSize',20)
    %line([0 1],[0 1],'color','r')
    xlim([-3 3])
    ylim([-3 3])
end

%Calculate the best fit line
%First find all inf or nans
%First for the logs
if oneFig
    total   = isfinite(log(propRV))+isfinite(log(propCV));
    idx     = (total==2);
    
    p       = polyfit((log(propRV(idx))),(log(propCV(idx))),1);
    f       = polyval(p,(log(propRV(idx))));
    plot((log(propRV(idx))),f,'--k')
    %Second for the regular.
    total2   = isfinite((propRV))+isfinite((propCV));
    idx2     = (total2==2);
    p2      = polyfit((propRV(idx2)),(propCV(idx2)),1);
    
    %From baum 1974,
    
    bias  = sum(allverticals)/(sum(allhorizontals)+sum(allverticals));%mean(propCV(isfinite(propCV))); %bias for vertical target
    
    b1b2log = log(sum(allverticals)/sum(allhorizontals));%smean(log(propCV(isfinite(log(propCV)))));
    
    r1r2log = log(sum(allverticalsR)/sum(allhorizontalsR));%mean(log(propRV(isfinite(log(propRV)))));
    
    slope = (b1b2log/r1r2log)-(log(bias)/r1r2log);
    
    f2 = polyval([exp(slope) bias],(log(propRV(idx))));
    %plot((log(propRV(idx))),f2,'--b')
end

%%
%Create a bar plot of the distribution of reward probabilities. 
possibleRew = unique(rewardprob);

for ipR = 1:length(possibleRew)
    
    totalPR(ipR) = sum(rewardprob==possibleRew(ipR));
    
end

%plotting reward distribution bar plot
figure(2),clf
bar([1:7],totalPR)
set(gca, 'XTick',[1:7])
set(gca,'XTickLabel',possibleRew)

%plotting reward distribution order bar plot
figure(3),clf
imagesc(orderRew)
colorbar

%Plotting the slopes of best fits for all sessions, order of interaction
figure(4),clf

PLAslopes = (sessionBestFits(1:length(sessionBestFits)/2,1));
ATMslopes = (sessionBestFits(length(sessionBestFits)/2+1:end,1));

s=scatter(PLAslopes,ATMslopes,'filled');
s.MarkerEdgeColor='black';
s.MarkerFaceColor='black';


%Plotting the slopes of best fits for all sessions, order of first/second.
% PLAsess        = cellfun(@(n) n(9),PLA,'UniformOutput',false);
% PLAsess        = cellfun(@str2num,PLAsess,'UniformOutput',true);
% % PLAsess        = cellfun(@(n) n(9),PLA,'UniformOutput',false);
% PLAsess        = cellfun(@str2num,PLAsess,'UniformOutput',true);
% 
% PLAonly=PLAsess(1:length(sessionBestFits)/2) ;
% ATMonly=PLAsess(length(sessionBestFits)/2+1:end) ;
% 
% first  = find(PLAsess(1:length(sessionBestFits)/2)==1);
% 
% second = find(PLAsess(length(sessionBestFits)/2+1:end)==2);
% 
% wrongOrder1=sessionBestFits(1:length(sessionBestFits)/2,1);
% wrongOrder2=sessionBestFits(length(sessionBestFits)/2+1:end,1);
% 
% allwrongs = [wrongOrder1,wrongOrder2];
% 
% allwrongs(second,:)=fliplr(allwrongs(second,:));
% 
% correctOrder = allwrongs;
% 
% 

% PLAonly=PLAsess(1:length(sessionBestFits)/2) ;
% ATMonly=PLAsess(length(sessionBestFits)/2+1:end) ;
% 
% first  = find(PLAsess(1:length(sessionBestFits)/2)==1);
% 
% second = find(PLAsess(length(sessionBestFits)/2+1:end)==2);
% 
% wrongOrder1=sessionBestFits(1:length(sessionBestFits)/2,1);
% wrongOrder2=sessionBestFits(length(sessionBestFits)/2+1:end,1);
% 
% allwrongs = [wrongOrder1,wrongOrder2];
% 
% allwrongs(second,:)=fliplr(allwrongs(second,:));
% 
% correctOrder = allwrongs;
% 
% 
%plot([correctOrder(:,1),correctOrder(:,2)]','color','k')


wrongOrder1=sessionBestFits(1:length(sessionBestFits)/2,1);
wrongOrder2=sessionBestFits(length(sessionBestFits)/2+1:end,1);

allwrongs = [wrongOrder1;wrongOrder2];

parts=repmat(linspace(1,29,29),1,2);

c=scatter(parts,allwrongs,'filled');
c.MarkerEdgeColor='black';
c.MarkerFaceColor='black';
%line([parts(1:length(sessionBestFits)/2)' allwrongs(1:length(sessionBestFits)/2)],[parts(length(sessionBestFits)/2+1:end)' allwrongs(length(sessionBestFits)/2+1:end)])

for ilines = 1:29
    line([ilines ilines],[allwrongs(ilines) allwrongs(ilines+29)],'color','k')

end


end

