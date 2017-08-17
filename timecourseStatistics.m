
%statistics on time course data. 
%use old matlab81
warning off
addpath(genpath('/mnt/homes/home024/chrisgahn/fieldtrip-20130305'))
ft_defaults

%%
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
%Replace low and high with the oveall optimal and overal non optimal beta. 
if plotOverallOptim
    if strcmp(optim,'OPTIM')
        lowStim = nanmean(stimL.BPallStim,3)';%nanmean(respL.BPallResp,3)';
        lowResp = nanmean(respL.BPallResp,3)';
        lowCue  = nanmean(cueL.BPallCue,3)';
    else
        highStim = nanmean(stimL.BPallStim,3)';%nanmean(respL.BPallResp,3)';
        highResp = nanmean(respL.BPallResp,3)';
        highCue  = nanmean(cueL.BPallCue,3)';
    end
end
%%
%Parameters
cfg = [];
cfg.correctm = 'cluster';% Ask thoms. 
cfg.statistic = 'ft_statfun_depsamplesT'; %ask thomas
cfg.clusteralpha = 0.05; 
cfg.clusterstatistic = 'maxsum'; %default
cfg.method = 'montecarlo';
cfg.numrandomization = 10000;

design(1,:) = [1:size(low,1) 1:size(low,1)];
design(2,:) = [ones(1,size(low,1)) ones(1,size(low,1))*2];
%design = [ ones(1,size(low,2)) ones(1,size(low,2))*2; 1:size(low,2) 1:size(low,2)]';

cfg.design = design; 
cfg.ivar = 2; 
cfg.uvar = 1; 
cfg.tail = 0;
cfg.clustertail = 0;
%cfg.correcttail = 'prob';
cfg.alpha = 0.025;
cfg.frequency = 'all';

%%
%I will compare for each participant, within Unit of observation... 

%Reconfigure the frequency structure which is normally required. 
resp.freq.label = {'custompooling'};

%add the whole freq structure
freqLow = resp.freq;
freqHigh = resp.freq;

%add the times to the frequency, try to treat frequencies as times. 
freqLow.freq = resp.freq.time;
freqHigh.freq = resp.freq.time;

%remove the field time.
freqLow=rmfield(freqLow,'time');
freqHigh=rmfield(freqHigh,'time');
%Pretend there is only one frequency.
%freqLow.freq  = 1:size(low,2);
%freqHigh.freq = 1:size(low,2);

freqLow.powspctrm = low;
freqHigh.powspctrm = high;

freqLow.dimord = 'subj_freq'; %ask thomas
freqHigh.dimord = 'subj_freq';
%cfg_neigh.method = 'distance';
%cfg.neighours = ft_prepare_neighbours(cfg_neigh,stim.freq);
cfg.neighbours = [];

statR = ft_freqstatistics(cfg,freqLow,freqHigh);


%%



%Do stim stats
low   = (stimL.BPallStim(:,:,1))';
high  = (stimL.BPallStim(:,:,2))';
stim.freq.label = {'custompooling'};

%add the whole freq structure
freqLow = stim.freq;
freqHigh = stim.freq;

%add the times to the frequency, try to treat frequencies as times. 
freqLow.freq = stim.freq.time;
freqHigh.freq = stim.freq.time;

%remove the field time.
freqLow=rmfield(freqLow,'time');
freqHigh=rmfield(freqHigh,'time');

freqLow.powspctrm = low;
freqHigh.powspctrm = high;

freqLow.dimord = 'subj_freq'; %ask thomas
freqHigh.dimord = 'subj_freq';
statS = ft_freqstatistics(cfg,freqLow,freqHigh);




%%

%Do cue stats
low   = (cueL.BPallCue(:,:,1))';
high  = (cueL.BPallCue(:,:,2))';
cue.freq.label = {'custompooling'};


freqLow = cue.freq;
freqHigh = cue.freq;

%add the times to the frequency, try to treat frequencies as times. 
freqLow.freq = cue.freq.time;
freqHigh.freq = cue.freq.time;

%remove the field time.
freqLow=rmfield(freqLow,'time');
freqHigh=rmfield(freqHigh,'time');

freqLow.powspctrm = low;
freqHigh.powspctrm = high;
freqLow.dimord = 'subj_freq'; %ask thomas
freqHigh.dimord = 'subj_freq';
statC = ft_freqstatistics(cfg,freqLow,freqHigh);

%%
statS.prob

statC.prob

statR.prob



cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis')
strDate = '12-Mar-2017';
strStat  = sprintf('statPermutations%sP-%s%s%s.mat',param,lfiPC,optim,strDate);

save(strStat,'statS','statC','statR')





