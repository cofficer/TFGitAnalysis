function  plotSeperateEvent( ~ )
%plot the time courses of stim cue and response seperately
%%
clear;close all
%%
%Set the range of signal change
setY = [-14 3];

%Store colors
col_alts=cbrewer('qual','Set2',8);

%define the participant grouping
whichParts = 'all'; %low not optimal param fits, high optimal param fits
param = '1';
hori=0; %0 or 3 for plot location

lfiPC=''; % set to "" if 1 param.

%Plot overall beta difference between non optimal and optimal participants>
optimOveralPlot = 0;


if strcmp(whichParts,'low')
    optim='NOTOPTIM';
elseif strcmp(whichParts,'high')
    optim='OPTIM';
end
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
        load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/statPermutations%sP-%s%s12-Mar-2017.mat',param,lfiPC,optim))
        
        
    case 'high'
        stimL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseStim%sP%s12-Mar-2017OPTIM.mat',param,lfiPC));
        respL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseResp%sP%s12-Mar-2017OPTIM.mat',param,lfiPC));
        cueL = load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/timecourseCue%sP%s12-Mar-2017OPTIM.mat',param,lfiPC));
        %load statstics
        load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/statPermutations%sP-%s%s12-Mar-2017.mat',param,lfiPC,optim))
        
end
%get time information
resp =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/stim/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue  =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');

if ~optimOveralPlot
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
    %set(gca,'Position',[0 0 0.75 0.75])
    subplot(1,3,1+hori)
    hold on;
    

    %try shadederrorbar instead
    h1=shadedErrorBar(timeX,low,nanstd(stimL.BPallStim(:,:,1)')/sqrt(length(stimL.BPallStim(:,:,1)')));
    h2=shadedErrorBar(timeX,high,nanstd(stimL.BPallStim(:,:,2)')/sqrt(length(stimL.BPallStim(:,:,2)')));
    xlabel('Time(s)')
    ylabel('Percent signal change(%)')

     h1.mainLine.Color=col_alts(1,:)./2;
    h1.patch.FaceColor=col_alts(1,:);
    h1.patch.FaceAlpha=0.5;
   
    h2.mainLine.Color=col_alts(3,:)./2;
    h2.patch.FaceColor=col_alts(3,:);
    h2.patch.FaceAlpha=0.5;   
    
    %plot(high)
    sigc=plot(timeX,sigClusterS,'-','LineWidth',4,'color','k')
   % set(gca,'XTick',[x(indX)])
   % set(gca,'XTickLabel',timeX(indX))
    ylim(setY)
    % set(gca,'Position',[0.1 0.15 0.2 0.75])
   set(gca,'Position',[0.1 0.15 0.25 0.75])
    % legend([h1.mainLine,h2.mainLine,sigc],'Low','High','Sig.')
    title('Stimulus-locked')
    
    
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
    
    
    subplot(1,3,2+hori)
    hold on;
    
    %plot(low)
    %plot(high)
    %try shadederrorbar instead
    h1=shadedErrorBar(timeX,low,nanstd(cueL.BPallCue(:,:,1)')/sqrt(length(cueL.BPallCue(:,:,1)')));
    h2=shadedErrorBar(timeX,high,nanstd(cueL.BPallCue(:,:,2)')/sqrt(length(cueL.BPallCue(:,:,2)')));
    
     h1.mainLine.Color=col_alts(1,:)./2;
    h1.patch.FaceColor=col_alts(1,:);
    h1.patch.FaceAlpha=0.5;
   
    h2.mainLine.Color=col_alts(3,:)./2;
    h2.patch.FaceColor=col_alts(3,:);
    h2.patch.FaceAlpha=0.5;   
    
    sigc=plot(timeX,sigClusterC,'-','LineWidth',4,'color','k');
   % set(gca,'XTick',[x(indX)])
   % set(gca,'XTickLabel',timeX(indX))
    ylim(setY)
        set(gca,'Ytick',[])
    set(gca,'Ycolor','W')
    
    %legend([h1.mainLine,h2.mainLine,sigc],'Low','High','Sig.')
    title('Cue-locked')
    set(gca,'Position',[0.35 0.15 0.25 0.75])%[0.1 0.15 0.3 0.75]
    
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
    
    
    subplot(1,3,3+hori)
    hold on;

    h1=shadedErrorBar(timeX,low,nanstd(respL.BPallResp(:,:,1)')/sqrt(length(respL.BPallResp(:,:,1)')));
    h2=shadedErrorBar(timeX,high,nanstd(respL.BPallResp(:,:,2)')/sqrt(length(respL.BPallResp(:,:,2)')));
    
    h1.mainLine.Color=col_alts(1,:)./2;
    h1.patch.FaceColor=col_alts(1,:);
    h1.patch.FaceAlpha=0.5;
   
    h2.mainLine.Color=col_alts(3,:)./2;
    h2.patch.FaceColor=col_alts(3,:);
    h2.patch.FaceAlpha=0.5;   
    
    %plot(low)
    %plot(high)
    sigc=plot(timeX,sigClusterR,'-','LineWidth',4,'color','k');
   % set(gca,'XTick',[x(indX)])
    %set(gca,'XTickLabel',timeX(indX))
    ylim(setY)
    legend([h1.mainLine,h2.mainLine,sigc],'Low','High','Sig.')
    title('Response-locked')
    set(gca,'Ytick',[])
    set(gca,'Ycolor','W')
    set(gca,'Position',[0.6 0.15 0.35 0.75]) %[0.1 0.15 0.3 0.75][0.30 0.15 0.3 0.75]
    %saveas(gca,'timecourse1param2nd.png')
    %set(gca,'Position',get(gca,'TightInset'))
    %%
    %Plotting overal beta differences disregarding LFI.
    
else
    
    figure(2)
    
    
    
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
    
    
    subplot(1,3,1+hori)
    hold on;
    overall = (low+high)/2;
    plot(overall)
    plot(sigClusterS,'-','LineWidth',4)
    set(gca,'XTick',[x(indX)])
    set(gca,'XTickLabel',timeX(indX))
    ylim(setY)
    %legend low high
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
    
    
    subplot(1,3,2+hori)
    hold on;
    overall = (low+high)/2;
    plot(overall)
    
    plot(sigClusterC,'-','LineWidth',4)
    set(gca,'XTick',[x(indX)])
    set(gca,'XTickLabel',timeX(indX))
    ylim(setY)
    %legend low high
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
    
    
    subplot(1,3,3+hori)
    hold on;
    overall = (low+high)/2;
    plot(overall)
    plot(sigClusterR,'-','LineWidth',4)
    set(gca,'XTick',[x(indX)])
    set(gca,'XTickLabel',timeX(indX))
    ylim(setY)
    %legend low high
    title('Lateralisation: response-locked')
    
end
end

