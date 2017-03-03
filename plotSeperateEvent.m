function  plotSeperateEvent( ~ )
%plot the time courses of stim cue and response seperately 
%%
clear
setY = [-14 3];

%define the participant grouping
whichParts = 'low';

switch whichParts
    %Change manually between ls and tau groupings.
    case 'all'
        stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim3PlowLS20thfeb.mat');
        respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp3PlowLS20thfeb.mat');
        cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue3PlowLS20thfeb.mat');
        %load statstics
        load('statisticsPermutation20thfeb2.mat')
        
    case 'low'
        stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim3PlowPerf20thfeb.mat');
        respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp3PlowPerf20thfeb.mat');
        cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue3PlowPerf20thfeb.mat');
        %load statstics
        load('statisticsPermutationLOWperformance.mat')
        
    case 'high'
        stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim3PhighPerf20thfeb.mat');
        respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp3PhighPerf20thfeb.mat');
        cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue3PhighPerf20thfeb.mat');
        %load statstics
        load('statisticsPermutationHIGHperformance.mat')
end
%get time information
resp =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/stim/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue  =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');


%Structure the significant clusters
sigClusterS = ([statS.prob]<1)*-6;
inNaN = find(sigClusterS==0);
sigClusterS(inNaN) = NaN;
sigClusterC = ([statC.prob]<1)*-6;
inNaN = find(sigClusterC==0);
sigClusterC(inNaN) = NaN;
sigClusterR = ([statR.prob]<1)*-6;
inNaN = find(sigClusterR==0);
sigClusterR(inNaN) = NaN;

%plot the stim onset time course
low   = nanmean(stimL.BPallStim(:,:,1),2)';
high  = nanmean(stimL.BPallStim(:,:,2),2)';
timeX = stim.freq.time;
x = 1:length(timeX);

indX = find(timeX==0);
indX2= find(timeX==-0.2);
indX3= find(timeX==0.5);
indX4= find(timeX==0.3);

indX =sort([indX indX2 indX3 indX4 ]);


figure(1),clf
subplot(1,3,1)
hold on;

plot(low)
plot(high)
plot(sigClusterS,'-','LineWidth',4)
set(gca,'XTick',[x(indX)])
set(gca,'XTickLabel',timeX(indX))
ylim(setY)
legend low high
title('Lateralisation: stim-locked')


%plot the cue onset time course
low   = nanmean(cueL.BPallCue(:,:,1),2)';
high  = nanmean(cueL.BPallCue(:,:,2),2)';
timeX = cue.freq.time;
x = 1:length(timeX);

indX = find(timeX==0);
indX2= find(timeX==-0.2);
indX3= find(timeX==0.5);
indX4= find(timeX==0.3);

indX =sort([indX indX2 indX3 indX4 ]);


subplot(1,3,2)
hold on;

plot(low)
plot(high)
plot(sigClusterC,'-','LineWidth',4)
set(gca,'XTick',[x(indX)])
set(gca,'XTickLabel',timeX(indX))
ylim(setY)
legend low high 
title('Lateralisation: cue-locked')


%plot the resp onset time course
low   = nanmean(respL.BPallResp(:,:,1),2)';
high  = nanmean(respL.BPallResp(:,:,2),2)';
timeX = resp.freq.time;
x = 1:length(timeX);

indX = find(timeX==0);
indX2= find(timeX==-0.2);
indX3= find(timeX==0.5);
indX4= find(timeX==0.3);

indX =sort([indX indX2 indX3 indX4 ]);


subplot(1,3,3)
hold on;

plot(low)
plot(high)
plot(sigClusterR,'-','LineWidth',4)
set(gca,'XTick',[x(indX)])
set(gca,'XTickLabel',timeX(indX))
ylim(setY)
legend low high
title('Lateralisation: response-locked')


end

