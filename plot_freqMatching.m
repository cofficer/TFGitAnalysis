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
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/SBa/20151006/resp/SBa_d01_250_type1event2_totalpow_freq11')


freqDataMatrix      = freq.powspctrm;

cfg                 = [];
cfg.baselinetype    = 'relchange';
cfg.baseline        = [-2 -1.5];
baseFreq            = ft_freqbaseline(cfg,freq);


%%
%Different multiplotTFR settings
cfg                 = [];
%cfg.zlim            = [-100 100];
cfg.showlabels      = 'yes';
cfg.ylim            = [10 35];
ft_multiplotTFR(cfg,baseFreq);













