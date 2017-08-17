

%Compute the per partipant relationship between tau fits and maximal beta
%lateralization

clear
%%
%load time coursesm change the load file manually low high or all(nothing).
param = '1';
lfiPC = '';
%The variable options are "" for all participants, OPTIM for all
%participants close to optimal tau, and NOTOPTIM for all participants with
%non optimal taus.
optim = '';

%Decide to calculate the difference in overall beta power between optimal
%and non-optimal participants. If 1 then need to run this cell twice, once
%with optim = 'OPTIM' and once for notoptim, and store each as low and high, respectively.
plotOverallOptim = 1;

stimL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim%sP%s12-Mar-2017%s.mat',param,lfiPC,optim));
respL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp%sP%s12-Mar-2017%s.mat',param,lfiPC,optim));
cueL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue%sP%s12-Mar-2017%s.mat',param,lfiPC,optim));


%Becuase I need a frequency structure.
resp =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/stim/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue  =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');


%plot the stim onset time course
low   = (respL.BPallResp(:,:,1))';
high  = (respL.BPallResp(:,:,2))';

%%
%Need to load the parameters
[ newtaufit,newbetafit,newlsfit,end1taufit ] = load_params_matching;


%%

%Q1: are the timecourses and the taufits in the same order?
stimL;
respL;
cueL;

end1taufit;

scatter(end1taufit,abs(mean(mean(respL.BPallResp(15:25,:,:),3),1)))
scatter(newlsfit,abs(mean(mean(respL.BPallResp(15:25,:,:),3),1)))

%In order to establish a relationship I need to make the beta go from
%optimal to non-optimal. I can do this by taking all betas -2 and then
%taking the abs and adding 2 again.

%Here I remove both a partcipant with NaNs, DWe, in the beta, and all max
%fits.
corr_taufit = abs(end1taufit-2)+2;
indMax=corr_taufit<19;
corr_taufit=corr_taufit(indMax);

corr_taufit(6)=[];

respBeta = abs(mean(mean(respL.BPallResp(15:25,:,:),3),1));
respBeta = respBeta(indMax);
respBeta(6) =[];

length(corr_taufit)
length(respBeta)

scatter((corr_taufit),(respBeta)')

[a,b]=corr((corr_taufit),(respBeta)')

%%
%Also correlate the ls parameter with beta lateralization.
%Also remove the one participant
colrs = cbrewer('qual','Set2',8);
for alltimes = 1:31
    
    corr_lsfit=newlsfit(newtaufit<19);
    corr_lsfit(6)=[];
    
    
    respBeta = (mean(mean(respL.BPallResp(alltimes:alltimes,:,:),3),1));
    %respBeta = (mean(mean(cueL.BPallCue(alltimes:alltimes,:,:),3),1));
    %respBeta = (mean(mean(stimL.BPallStim(alltimes:alltimes,:,:),3),1));
    respBeta = respBeta(newtaufit<19);
    respBeta(6) =[];
    
    [aresp(alltimes),bresp(alltimes)]=corr((corr_lsfit)',(respBeta)');
    
    
end

for alltimes = 1:21
    
    corr_lsfit=newlsfit(newtaufit<19);
    corr_lsfit(6)=[];
    
    
    %respBeta = (mean(mean(respL.BPallResp(alltimes:alltimes,:,:),3),1));
    respBeta = (mean(mean(cueL.BPallCue(alltimes:alltimes,:,:),3),1));
    %respBeta = (mean(mean(stimL.BPallStim(alltimes:alltimes,:,:),3),1));
    respBeta = respBeta(newtaufit<19);
    respBeta(6) =[];
    
    [acue(alltimes),bcue(alltimes)]=corr((corr_lsfit)',(respBeta)');
    
    
end

for alltimes = 1:21
    
    corr_lsfit=newlsfit(newtaufit<19);
    corr_lsfit(6)=[];
    
    
    %respBeta = (mean(mean(respL.BPallResp(alltimes:alltimes,:,:),3),1));
    %respBeta = (mean(mean(cueL.BPallCue(alltimes:alltimes,:,:),3),1));
    respBeta = (mean(mean(stimL.BPallStim(alltimes:alltimes,:,:),3),1));
    respBeta = respBeta(newtaufit<19);
    respBeta(6) =[];
    
    [astim(alltimes),bstim(alltimes)]=corr((corr_lsfit)',(respBeta)');
    
    
end

%plot the correlation timecourse.
%plot(timeX,b)


figure(1),clf
subplot(1,3,1)
hold on;
setY=[-0.8 0.8];
plot(stim.freq.time,astim,'color',colrs(1,:))
ylabel('Correlation coefficient')
xlabel('Time(s)')
% set(gca,'XTick',[x(indX)])
% set(gca,'XTickLabel',timeX(indX))
ylim(setY)
% set(gca,'Position',[0.1 0.15 0.2 0.75])
set(gca,'Position',[0.1 0.15 0.25 0.75])
% legend([h1.mainLine,h2.mainLine,sigc],'Low','High','Sig.')
title('Stimulus-locked')
%line([stim.freq.time],[ 0.05 *ones(1,length(stim.freq.time))],'color','r')

sigplace =nan(1,length(stim.freq.time));
sigplace(bstim<0.05) = 0.05;

line([stim.freq.time],[ sigplace],'color','k')


subplot(1,3,2)
hold on;

plot(cue.freq.time,acue)

% set(gca,'XTick',[x(indX)])
% set(gca,'XTickLabel',timeX(indX))
ylim(setY)
set(gca,'Ytick',[])
set(gca,'Ycolor','W')

%legend([h1.mainLine,h2.mainLine,sigc],'Low','High','Sig.')
title('Cue-locked')
set(gca,'Position',[0.35 0.15 0.30 0.75])%[0.1 0.15 0.3 0.75]

sigplace =nan(1,length(cue.freq.time));
sigplace(bcue<0.05) = 0.05;

line([cue.freq.time],[ sigplace],'color','k')
%line([cue.freq.time],[ 0.05 *ones(1,length(cue.freq.time))],'color','r')

subplot(1,3,3)
hold on;
plot(resp.freq.time,aresp,'color',colrs(1,:))
%line([resp.freq.time],[ 0.05 *ones(1,length(resp.freq.time))],'color','r')
sigplace =nan(1,length(resp.freq.time));
sigplace(bresp<0.05) = 0.05;

line([resp.freq.time],[ sigplace],'color','k')
ylim(setY)
%legend([h1.mainLine,h2.mainLine,sigc],'Low','High','Sig.')
title('Response-locked')
set(gca,'Ytick',[])
set(gca,'Ycolor','W')
set(gca,'Position',[0.65 0.15 0.30 0.75])

legend Timecourse Sig.
%saveas(gca,'timecourseCorrelationLSbetalat.png')
%%
%Save figur
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
%saveas(gca,'timecourseCorrelationLSLateralization.png')
%%
%Plot some overall scatter plot
s=scatter(corr_lsfit,respBeta,'filled');
s.MarkerFaceColor='black';
s.MarkerEdgeColor='black';
xlabel('Lose switch parameter')
ylabel('Beta lateralization')
title('Entire cue timecourse')
%Plot the best fit line
[bet,pvalue]=corr(corr_lsfit',respBeta');
%ylim([-25 0 ])
p=polyfit(corr_lsfit',respBeta',1);
f=polyval(p,corr_lsfit',1);
hold on;
plot(corr_lsfit',f,'r')
legend(sprintf('p = %s', num2str(pvalue,3)),sprintf('r = %s',num2str(bet)))

%
%%
%Would be nice to plot all the timecoures in relation to the beta param

respBetaParts = ((mean(respL.BPallResp(:,:,:),3)));
respBetaParts = respBetaParts(:,newtaufit<19);
respBetaParts(:,6) =[];
[Y,I]=sort(corr_lsfit');

colors = jet(60);

figure(2),clf
for ilses = 1:24
    
    plot(respBetaParts(:,I(ilses)),'color',colors(ilses,:))
    hold on
    ilegend {ilses}= sprintf('LS - %.2f',(corr_lsfit(I(ilses))));
    %legend(num2str(I(ilses)))
end

legend(ilegend)

xlabel('Lose switch parameter')
ylabel('Beta lateralization')
title('Entire resp timecourse')
%saveas(gca,'wholetimecourseRespLS.png')


%Should try and plot in seperate bins.
[Y,I]=sort(corr_lsfit'); % First take the lowest fourth

%hist(I,4)

indLowFits = I<7;
indMedFits = (I>6) .* (I<13);
indHighFits = (I>12) .* (I<19);
indCeilFits = I>18;

respBetaParts = ((mean(respL.BPallResp(:,:,:),3)));
respBetaParts = respBetaParts(:,newtaufit<19);
respBetaParts(:,6) =[];

meanLow  = mean(respBetaParts(:,indLowFits),2);
meanMed  = mean(respBetaParts(:,logical(indMedFits)),2);
meanHigh = mean(respBetaParts(:,logical(indHighFits)),2);
meanCeil = mean(respBetaParts(:,indCeilFits),2);

figure(3),clf
hold on
plot(meanLow,'color',colors(1,:))
plot(meanMed,'color',colors(5,:))
plot(meanHigh,'color',colors(14,:))
plot(meanCeil,'color',colors(20,:))
legend low med high ceil

xlabel('Lose switch parameter')
ylabel('Beta lateralization')
title('Entire resp timecourse')
saveas(gca,'wholetimecourseRespLS4P.png')
%%
%Now do cue locked
respBetaParts = ((mean(cueL.BPallCue(:,:,:),3)));
respBetaParts = respBetaParts(:,newtaufit<19);
respBetaParts(:,6) =[];

meanLow  = mean(respBetaParts(:,indLowFits),2);
meanMed  = mean(respBetaParts(:,logical(indMedFits)),2);
meanHigh = mean(respBetaParts(:,logical(indHighFits)),2);
meanCeil = mean(respBetaParts(:,indCeilFits),2);

figure(3),clf
hold on
plot(meanLow,'color',colors(1,:))
plot(meanMed,'color',colors(5,:))
plot(meanHigh,'color',colors(14,:))
plot(meanCeil,'color',colors(20,:))
legend low med high ceil

xlabel('Lose switch parameter')
ylabel('Beta lateralization')
title('Entire cue timecourse')
saveas(gca,'wholetimecourseCueLS4P.png')

%%
%Now do stim locked
respBetaParts = ((mean(stimL.BPallStim(:,:,:),3)));
respBetaParts = respBetaParts(:,newtaufit<19);
respBetaParts(:,6) =[];

meanLow  = mean(respBetaParts(:,indLowFits),2);
meanMed  = mean(respBetaParts(:,logical(indMedFits)),2);
meanHigh = mean(respBetaParts(:,logical(indHighFits)),2);
meanCeil = mean(respBetaParts(:,indCeilFits),2);

figure(3),clf
hold on
plot(meanLow,'color',colors(1,:))
plot(meanMed,'color',colors(5,:))
plot(meanHigh,'color',colors(14,:))
plot(meanCeil,'color',colors(20,:))
legend low med high ceil

xlabel('Lose switch parameter')
ylabel('Beta lateralization')
title('Entire stim timecourse')

saveas(gca,'wholetimecourseStimLS4P.png')


%Look at correlation with performance.


respBeta = abs(mean(mean(respL.BPallResp(18:25,:,:),3),1));
respBeta = respBeta(newtaufit<19);
respBeta(6) =[];

perf=performance(1:2:end);

perf=perf(newtaufit<19);
perf(6)=[];


s=scatter(perf,respBeta,'filled');


[rho,pval]=partialcorr(corr_lsfit',respBeta',perf');

%The correlation between ls and resp beta is still sig. after controlling
%performance.


%Check the relationship between this beta lat. and noise param fits.

scatter(newbetafit,(mean(mean(respL.BPallResp(18:25,:,:),3),1)))



%%
%Look at the reaction times as well, especially reaction time vs. beta lat.
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel')

%If you load a full table then no reason run the 2nd cell.
load('fullTable24Nov-2.mat')



allRT=(Ttotal.resp_sample-Ttotal.goQ_sample)/1200;


ID = Ttotal.ID;
ID = cellstr(ID);

indID = unique(ID);
checksub=[];

for allID = 1:length(indID)
    
    table_ind_id = strcmp(Ttotal.ID,indID(allID));
    
    
    currRT = allRT(table_ind_id);
    
    currRT=currRT(currRT>0.2);
    
    currRT=currRT(currRT<3);
    
    avgRT(allID)=mean(currRT);
    stdRT(allID)=std(currRT);
    %lenRT(allID)=length(currRT);
    lenRT(allID)=length(allRT(table_ind_id));
    %Few trials
    if length(currRT)<500
        checksub = [checksub,indID(allID)];
    end
end

scatter(avgRT,newlsfit);


%saveas(gca,'scatterNumTrialsLSparam.png')
%%
%Plot the individual timecourses

dim_dat = size(respL.BPallResp);

figure(3),clf
hold on

for ipart = 1:dim_dat(2)
    
    subplot(6,5,ipart)
    plot(respL.BPallResp(:,ipart,1))
    hold on
    plot(respL.BPallResp(:,ipart,2))
    legend(num2str(end1taufit(ipart)))
    ylim([-25 0])
    
end