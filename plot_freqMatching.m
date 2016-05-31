%Script for plotting the frequancy analysis data. 

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/SBa/20151006/resp/') %Change to SBa folder

%%
%This cell is uses a preset baselining method as per ft_multiplotTFR. 
%I would rather construct my own baselining routine. 


%load the freq. 

figure(1),clf

cfg                 = [];
cfg.interactive     = 'yes';
cfg.showoutline     = 'yes';
%cfg.layout          = 'CTF151.lay';
cfg.baseline        = [-1.8 -1.5];
cfg.baselinetype    = 'absolute';
cfg.ylim            = [10 35];
cfg.zlim            = 'maxabs';
ft_multiplotTFR(cfg,freq);



%%
%Freqency data matrix needed to manage the data in a straight forward way. 
%Maybe using the ft_freqbaseline funcion for now to save time is
%reasonable

%load data:
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/SBa/20151006/resp/SBa_d01_250_type1event1_totalpow_freq11')
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/NSh/20150825/resp/NSh_d01_250_type1event2_totalpow_freq11')



cfg                 = [];
cfg.baselinetype    = 'relchange';
cfg.baseline        = [-0.5 0];
baseFreq            = ft_freqbaseline(cfg,freq);


%%
%Different multiplotTFR settings
cfg                 = [];
cfg.zlim            = [-100 100];
cfg.showlabels      = 'yes';
cfg.ylim            = [10 35];
cfg.xlim            = [-0.3 0.8];
%cfg.ylim            = [64 95];

ft_multiplotTFR(cfg,freqInt.freq);

%%
%average freq. 
cfg = [];
avgFreq = ft_freqdescriptives(cfg,allFreq.freq);


cfg                 = [];
%cfg.zlim            = [-20 200];
cfg.showlabels      = 'yes';
cfg.ylim            = [10 35];
cfg.xlim            = [-1 0.8];
%cfg.ylim            = [64 95];

ft_multiplotTFR(cfg,avgFreq);


%%
%Choose sensors:

sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23','MRC24','MRF65'};
sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23','MLC24','MLF65'};

[label,idxR]=intersect(avgFreq.grad.label,sensR);

[label,idxL]=intersect(avgFreq.grad.label,sensL);


data=squeeze(nanmean(avgFreq.powspctrm(idxR,8:end,20:end-80)));
x = avgFreq.time(20:end-80);
y = avgFreq.freq(8:end);

imagesc(x,y,data)

set(gca,'YDir','normal')

%imagesc(squeeze(nanmean(avgFreq.powspctrm(idxR,8:end,:))))


