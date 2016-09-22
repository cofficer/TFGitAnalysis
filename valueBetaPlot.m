
%Plot collapsed beta suppression over time, binned by local fractional
%income. 

squeeze(mean(data,1))

collapsedBeta = (mean(squeeze(mean(data,1))));

plot(collapsedBeta)



cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/trialsLowFreq/baselinedStim')

sessions = dir('*.mat');

%Load the local fractional income for each trial

%Match up trial number from trialinfo with the LFI, 

trialsFreq = load(sessions(3).name);
trialsFreq2 = load(sessions(4).name);



size(trialsFreq2.powspctrm)


trialsFreq.trialinfo
trialsFreq2.trialinfo
