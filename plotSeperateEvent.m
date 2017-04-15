function  plotSeperateEvent( ~ )
%plot the time courses of stim cue and response seperately 
%%
clear
setY = [-14 3];

%define the participant grouping
whichParts = 'high'; %low not optimal param fits, high optimal param fits
param = '1';
hori=3; %0 or 3 for plot location

lfiPC=''; % set to "" if 1 param.

switch whichParts
    %Change manually between ls and tau groupings.
    case 'all'
        stimL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim%sP%s12-Mar-2017.mat',param,lfiPC));
        respL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp%sP%s12-Mar-2017.mat',param,lfiPC));
        cueL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue%sP%s12-Mar-2017.mat',param,lfiPC));
        %load statstics
        load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/statPermutations%sP-%s12-Mar-2017.mat',param,lfiPC))
        
    case 'low'
        stimL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim%sP%s12-Mar-2017NOTOPTIM.mat',param,lfiPC));
        respL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp%sP%s12-Mar-2017NOTOPTIM.mat',param,lfiPC));
        cueL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue%sP%s12-Mar-2017NOTOPTIM.mat',param,lfiPC));
        %load statstics
        load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/statPermutations%sP-%s12-Mar-2017.mat',param,lfiPC))
        
        
    case 'high'
        stimL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim%sP%s12-Mar-2017OPTIM.mat',param,lfiPC));
        respL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp%sP%s12-Mar-2017OPTIM.mat',param,lfiPC));
        cueL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue%sP%s12-Mar-2017OPTIM.mat',param,lfiPC));
        %load statstics
        load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/statPermutations%sP-%s12-Mar-2017.mat',param,lfiPC))
        
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


figure(1)
subplot(2,3,1+hori)
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


subplot(2,3,2+hori)
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


subplot(2,3,3+hori)
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

