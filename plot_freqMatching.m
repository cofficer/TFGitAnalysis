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
cfg.xlim            = [-0.5 2];
%cfg.ylim            = [64 95];

avgFreq.powspctrm = fullMatrix(1,1,:,:,:);

ft_multiplotTFR(cfg,avgFreq);


%%
%Choose sensors:

sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23','MRC24','MRC31','MRC41','MRF64','MRF65'};
sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23','MLC24','MLC31','MLC41','MLF64','MLF65'};

[label,idxR]=intersect(freq.grad.label,sensR);

[label,idxL]=intersect(freq.grad.label,sensL);

%avFM=squeeze(nanmean(fullMatrix,1));

%%

figure(1),clf

currPlot=1;

for iplotP =1:size(fullMatrix,1)
    for iplotS=1:size(fullMatrix,2)
        
        
        subplot(8,2,currPlot)
        
        
        data=squeeze(nanmean(fullMatrix(iplotP,iplotS,idxL,8:end,20:end-40),3));
        x = freq.time(20:end-40);
        y = freq.freq(8:end);
        
        imagesc(x,y,data)
        
        set(gca,'YDir','normal')
        colorbar
        
        currPlot=currPlot+1;
        
    end
end
%imagesc(squeeze(nanmean(avgFreq.powspctrm(idxR,8:end,:))))









