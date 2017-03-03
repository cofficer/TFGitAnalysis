function  createContraVSipsi(~ )
%



%%
%Load and plot all lines seperately for each lock type. 
% 
% stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/respavgAFreqSTIMLOCKED.mat');
% respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/respavgAFreq2.mat');
% cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/respavgAFreqCUELOCKED.mat');
% % 

%define the participant grouping
whichParts = 'all';

switch whichParts
    case 'all'
        stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim3P.mat');
        respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp3P.mat');
        cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue3P.mat');
        %load statstics
        load('statisticsPermutation20thfeb.mat')
        
    case 'low'
        stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim3PlowLS.mat');
        respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp3PlowLS.mat');
        cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue3PlowLS.mat');
        %load statstics
        load('statisticsPermutationLOWls20thfeb.mat')
        
    case 'high'
        stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim3PhighLS.mat');
        respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp3PhighLS.mat');
        cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue3PhighLS.mat');
        %load statstics
        load('statisticsPermutationHIGHls20thfeb.mat')
end


%Load one instance of each type for information such as time. 
resp =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/stim/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue  =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');


%Load all the sessions as response-locked and stimulus-locked
[ fullMatrixR,fullMatrixS,fullMatrixC ] = loadFullMatrixResp;

%time=cue.freq.time;
%%
%The time periods of interest


stimStart =31;
stimStop  =100;
respStart =40;
respStop  =92;
cueStart  =10;
cueStop   =65;

stimStart =8;
stimStop  =21;
respStart =21;
respStop  =31;
cueStart  =1;
cueStop   =12;




sigCluster = ([statS.prob(stimStart:stimStop) statC.prob(cueStart:cueStop) statR.prob(respStart:respStop)]<1)*-6;

inNaN = find(sigCluster==0);

sigCluster(inNaN) = NaN;

%%
%regular plot

%set the ylimit for all plots.
setY = [-14 3];


timeX = [stim.freq.time(stimStart:stimStop) cue.freq.time(cueStart:cueStop) resp.freq.time(respStart:respStop)];
x = 1:length(timeX);
% 
% low     = [nanmean(stimL.avgAFreq.low(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.low(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.low(respStart:respStop,:),2)'];
% medium  = [nanmean(stimL.avgAFreq.medium(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.medium(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.medium(respStart:respStop,:),2)'];
% high    = [nanmean(stimL.avgAFreq.high(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.high(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.high(respStart:respStop,:),2)'];
% ceil    = [nanmean(stimL.avgAFreq.ceil(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.ceil(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.ceil(respStart:respStop,:),2)'];
% 


low     = [nanmean(stimL.BPallStim(stimStart:stimStop,:,1),2)', nanmean(cueL.BPallCue(cueStart:cueStop,:,1),2)',nanmean(respL.BPallResp(respStart:respStop,:,1),2)'];
medium  = [nanmean(stimL.BPallStim(stimStart:stimStop,:,2),2)', nanmean(cueL.BPallCue(cueStart:cueStop,:,2),2)',nanmean(respL.BPallResp(respStart:respStop,:,2),2)'];
%high    = [nanmean(stimL.BPallStim(stimStart:stimStop,:,3),2)', nanmean(cueL.BPallCue(cueStart:cueStop,:,3),2)',nanmean(respL.BPallResp(respStart:respStop,:,3),2)'];
%ceil    = [nanmean(stimL.BPallStim(stimStart:stimStop,:,4),2)', nanmean(cueL.BPallCue(cueStart:cueStop,:,4),2)',nanmean(respL.BPallResp(respStart:respStop,:,4),2)'];


%figure(4),clf

subplot(3,1,3)
%title('Contra vs. Ipsi lateralisation: stim / cue / response-locked')
title('All beta lateralisation: stim / cue / response-locked')

hold on
%plot(ceil,'LineWidth',2)
%plot(high,'LineWidth',2)
plot(medium,'LineWidth',2)
plot(low,'LineWidth',2)

time=resp.freq.time;
indT = find(time==0);


indX = find(timeX==0);
indX2= find(timeX==-0.2);
indX3= find(timeX==0.5);
indX4= find(timeX==0.3);
indX=[indX indX2 indX3 indX4];
%indX+5
%indX-5

%indX = [indX (indX-10) (indX+10) indX(1)+20 indX(1)+30 indX(1)+40 indX(1)+50 indX(2)-20 indX(2)-30 indX(3)-20 indX(3)-30];
indX = sort(indX);
set(gca,'YDir','normal')
set(gca,'XTick',[x(indX)])
set(gca,'XTickLabel',timeX(indX))
%set(gca, 'XTick',[respStart:10:respStop])
%set(gca, 'XTickLabel',time(respStart:10:respStop))
%xlim([respStart respStop])
%ylim(setY)
ylim(setY)
line([x(stimStop-stimStart)+2 x(stimStop-stimStart)+2],get(gca,'Ylim'),'Color',[0 0 0],'LineWidth',10)
line([(x(stimStop-stimStart)+2)+(cueStop-cueStart) (x(stimStop-stimStart)+2)+(cueStop-cueStart)],get(gca,'Ylim'),'Color',[0 0 0],'LineWidth',10)

%plot the sig. cluster
plot(1:length(sigCluster),sigCluster,'-','LineWidth',4)

legend high Low 

%ylabel('% change to baseline')



%%
%Get sensors for each sensor group:
sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
         'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
         'MRF54','MRF55','MRF56','MRF66','MRF46'};
sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
         'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
         'MLF54','MLF55','MLF56','MLF66','MLF46'};
[~,idxR]=intersect(resp.freq.grad.label,sensR);
[~,idxL]=intersect(resp.freq.grad.label,sensL);
idxLR = [idxL idxR];


wholeFM = cat(5,fullMatrixS.powsptrcm(:,:,:,:,stimStart:stimStop),fullMatrixC.powsptrcm(:,:,:,:,cueStart:cueStop),fullMatrixR.powsptrcm(:,:,:,:,respStart:respStop));


figure(4)
subplot(2,1,2)
plotT={'Left motor sensor group, Left button press','Left motor sensor group, Right button press';'Right motor sensor group, Left button press','Right motor sensor group, Right button press'};

        fullMatrix = wholeFM;

        startT=1;
        stopT =262;
        
        %data11, left response with left sensors
        data11=squeeze(nanmean(fullMatrix(:,1,idxLR(:,1),1:end,1:end),3));
        %data21, right response with left sensors
        data21=squeeze(nanmean(fullMatrix(:,2,idxLR(:,1),1:end,1:end),3));
        %data12, left response with right sensors
        data12=squeeze(nanmean(fullMatrix(:,1,idxLR(:,2),1:end,1:end),3));
        %data22, right response with right sensors 
        data22=squeeze(nanmean(fullMatrix(:,2,idxLR(:,2),1:end,1:end),3));

        timeX = [stim.freq.time(stimStart:stimStop) cue.freq.time(cueStart:cueStop) resp.freq.time(respStart:respStop)];
        x = 1:length(timeX);%linspace(-0.025,size(fullMatrix,5)*0.025-1,size(fullMatrix,5)); %[stim.freq.time(startT):0.025:5.525]; %[stim.freq.time(31:85) resp.freq.time(50:92)]%
        y = stim.freq.freq(1:end);
          dataL=data21-data11;
        dataR=data12-data22;
        
        avgData=dataR+dataL;      
    
        imagesc(x,y,squeeze(nanmean(avgData./2,1)),[-12 12])
             
        indX = find(timeX==0);
                indX2= find(timeX==-0.2);
        indX3= find(timeX==0.5);
        indX4= find(timeX==0.3);
        indX=[indX indX2 indX3 indX4];
        %indX+5
        %indX-5
        
        %indX = [indX (indX-10) (indX+10) indX(1)+20 indX(1)+30 indX(1)+40 indX(1)+50 indX(2)-20 indX(2)-30 indX(3)-20 indX(3)-30];
        indX = sort(indX);
        set(gca,'YDir','normal')
        set(gca,'XTick',[x(indX)])
        set(gca,'XTickLabel',timeX(indX))
        
        %Create a lines seperating the three plots
        line([x(stimStop-stimStart)+2 x(stimStop-stimStart)+2],get(gca,'Ylim'),'Color',[1 1 1],'LineWidth',10)
        line([(x(stimStop-stimStart)+2)+(cueStop-cueStart) (x(stimStop-stimStart)+2)+(cueStop-cueStart)],get(gca,'Ylim'),'Color',[1 1 1],'LineWidth',10)
        %ylim([-8 8])
        %colorbar
        xlabel('Time (s) relative to event')

        %title('Contra vs. Ipsi')
        
        %xplot=xplot+1;

       



end

