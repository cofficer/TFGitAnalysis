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
ft_multiplotTFR(cfg,freqBase.freq);



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
%cfg.zlim            = [-100 100];
cfg.showlabels      = 'yes';
cfg.ylim            = [10 35];
cfg.xlim            = [-0.3 0.8];
%cfg.ylim            = [64 95];

ft_multiplotTFR(cfg,freq);

%%
%average freq. 
%cfg = [];
%avgFreq = ft_freqdescriptives(cfg,freq);


cfg                 = [];
%cfg.zlim            = [-20 200];
cfg.showlabels      = 'yes';
cfg.ylim            = [10 35];
cfg.xlim            = [-0.5 0.8];
%cfg.ylim            = [64 95];
cfg.layout          = 'CTF275.lay';

%avgFreq.powspctrm = squeeze(nanmean(fullMatrix.powsptrcm(:,2,:,:,:),1));

ft_multiplotTFR(cfg,grandavg);


%%
%Choose sensors:

sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23','MRC24','MRC31','MRC41','MRF64','MRF65','MRF63','MRF54','MRF55','MRF56','MRF66','MRF46'};
sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23','MLC24','MLC31','MLC41','MLF64','MLF65','MLF63','MLF54','MLF55','MLF56','MLF66','MLF46'};

[label,idxR]=intersect(freq.grad.label,sensR);

[label,idxL]=intersect(freq.grad.label,sensL);

idxLR = [idxL idxR];

%avFM=squeeze(nanmean(fullMatrix,1));

%%

figure(2),clf

currPlot=1;

for iplotP =1:size(fullMatrix.powsptrcm,1) %Loop over participants
    
    
    for iplotS=1:size(fullMatrix.powsptrcm,2); %Left and right button presses
        
        
        subplot(size(fullMatrix.powsptrcm,1),size(fullMatrix.powsptrcm,2),currPlot)
       
        
        data=squeeze(nanmean(fullMatrix.powsptrcm(iplotP,iplotS,idxL,8:end,20:end-60),3));
        x = freq.time(20:end-60);
        y = freq.freq(8:end);
        
        imagesc(x,y,data)
        
        set(gca,'YDir','normal')
        colorbar
        
        currPlot=currPlot+1;
        %title(sprintf('%s L/R: %d',fullMatrix.participants{iplotP},iplotS))
    end
end
%imagesc(squeeze(nanmean(avgFreq.powspctrm(idxR,8:end,:))))

%%
%Plot the average for each sensor group and for each button press. 

plotT={'Left motor sensor group, Left button press','Left motor sensor group, Right button press';'Right motor sensor group, Left button press','Right motor sensor group, Right button press'};

xplot=1;

for isensG=1:2
    
    for ibutG=1:2
        
        subplot(4,1,xplot)
        
        data=squeeze(nanmean(fullMatrix.powsptrcm(:,ibutG,idxLR(:,isensG),8:end,20:end-70),3));
        
        x = freq.time(20:end-70);
        y = freq.freq(8:end);
        
        %plot contra vs ipsi:
        
        %clims=[-5 30];
        
        
        imagesc(x,y,squeeze(nanmean(data,1)),[-20 20]) %insert clims
        
        set(gca,'YDir','normal')
        colorbar
        
        title(plotT(isensG,ibutG))
        
        xplot=xplot+1;
        
    end
end


%%
%Plot topoplots


cfg                 = [];
%cfg.zlim            = [-20 200];
cfg.showlabels      = 'no';
cfg.marker          = 'off';
cfg.comment         = 'no';
cfg.ylim            = [15 25];
cfg.xlim            = [0.6 0.8];
cfg.layout          = 'CTF275.lay';

LR={'Left button press','Right button pess'};

currPlot=1;

for iplotP =1:2%size(fullMatrix.powsptrcm,1) %Loop over participants
    
    
   % for iplotS=1:size(fullMatrix.powsptrcm,2); %Left and right button presses
        
        
        subplot(1,2,currPlot)
        
        
        grandavg.powspctrm = squeeze(nanmean(fullMatrix.powsptrcm(:,iplotP,:,:,:),1));
        %avgFreq.powspctrm = squeeze(fullMatrix.powsptrcm(1,2,:,:,:));
        
        
        ft_topoplotTFR(cfg,grandavg);
        title(sprintf('%s',LR{iplotP}))
        
        %5title(sprintf('%s ',fullMatrix.participants{currPlot}))
        
        
        
        
        
        currPlot=currPlot+1;
    %end
end

%%
%Figure 2b. Buildup of choice-predictive...


plotT={'Left motor sensor group, Left button press','Left motor sensor group, Right button press';'Right motor sensor group, Left button press','Right motor sensor group, Right button press'};

% xplot=1;
% 
% for isensG=1:2
%     
%     for ibutG=1:2
%         
%         subplot(4,1,xplot)
        
        data11=squeeze(nanmean(fullMatrix.powsptrcm(:,1,idxLR(:,1),8:end,20:end-45),3));
        data21=squeeze(nanmean(fullMatrix.powsptrcm(:,2,idxLR(:,1),8:end,20:end-45),3));
        data12=squeeze(nanmean(fullMatrix.powsptrcm(:,1,idxLR(:,2),8:end,20:end-45),3));
        data22=squeeze(nanmean(fullMatrix.powsptrcm(:,2,idxLR(:,2),8:end,20:end-45),3));

        x = freq.time(20:end-45);
        y = freq.freq(8:end);
        
        %plot contra vs ipsi:
        
        
        
        

%         
%     end
%     
%     
%     
% end
        dataL=data21-data11;
        dataR=data12-data22;
        
    
        imagesc(x,y,squeeze(nanmean(dataR,1)),[-40 40])
        
        set(gca,'YDir','normal')
        colorbar
        
        title('Contra vs. Ipsi')
        
        xplot=xplot+1;


%% Save figure
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
print('MotorGroupsLRBPLR','-dpdf')

print('-depsc','-tiff','/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures/avg7partTopoStimOnset1-1.2sRightBP')



