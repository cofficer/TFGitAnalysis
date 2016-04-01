%Running time frequency analysis etc 
clear all
warning off

addpath(genpath('/home/chrisgahn/Documents/MATLAB/code/'))
addpath(genpath('/home/chrisgahn/Documents/MATLAB/fieldtrip/'))
ft_defaults
%%
%Load the data
cd('/home/chrisgahn/Documents/MATLAB/preprocessed/JRu/20150819')
%cd('/Users/Christoffer/Documents/MATLAB/Internship/Matching_task/MEGdata/preproc/SUk')

data                = loadMEGpreproc();

%%
%Select data around a specific event. 

%First remove all the faulty buttonpreses
cfg                 = [];
cfg.trials          = data.trialinfo(:,9)~=18; 
data                = ft_redefinetrial(cfg,data);
cfg                 = [];
cfg.trials          = data.trialinfo(:,9)~=16; 
data                = ft_redefinetrial(cfg,data);

begsample           = 2*500;
endsample           = 1*500; 
trigger             = 6;          %column for samples of buttonpresses


%definetrials around the selected trigger


data                = triggerDataSelection( begsample, endsample, trigger, data);

fprintf('\n\n---Data around buttonpress selected---\n\n\n')

%%
%Remove trials with NaNs. No longe applicable
% 
% data                = removeNans(data);


%%
%Reformat data.time in relation to offset of the trigger.

data                = triggerOffsetDataTime(data, begsample);

disp('Done')


%%
%Select specific subset of trials

%


horLeftTrials          = data.trialinfo(:,end-4)==21;
verLeftTrials          = data.trialinfo(:,end-4)==20;


horRightTrials         = data.trialinfo(:,end-4)==23;
verRightTrials         = data.trialinfo(:,end-4)==22;


leftTrials             = horLeftTrials+verLeftTrials;
rightTrials            = horRightTrials+verRightTrials;

%Define left trials
cfg                 = [];
cfg.trials          = logical(leftTrials);

%Select left trial
dataL = ft_redefinetrial(cfg,data);

%Define right trials
cfg                 = [];
cfg.trials          = logical(rightTrials);

%Select right trial
dataR = ft_redefinetrial(cfg,data);

data=[];


%%
% %Plot some of the data.
% for k = 1:length(dataR.trial)
%   plot(dataR.time{k}-dataR.time{k}(1), dataR.trial{k}(140,:)+k*1.5e-12);
%   hold on;
% end
% plot([0 0], [0 1], 'k');
% ylim([0 length(dataR.trial)*1.5e-12]);
% set(gca, 'ytick', (1:10).*1.5e-12);
% set(gca, 'yticklabel', 1:10);
% ylabel('trial number');
% xlabel('time (s)');
% 
% %%
% %Testing plot and average of event-related potential.
% k=1;
% figure(2),clf
% subplot(311)
% plot(data.time{k}-data.time{k}(1), data.trial{k}(1:260,:));
% subplot(312)
% plot(data.time{k}-data.time{k}(1), var(data.trial{k}(1:260,:)));
% subplot(313)
% plot(data.time{k}-data.time{k}(1), mean(data.trial{k}(1:260,:)));



% %%
% %Computing the ERF
% dbstop if error
% cfg                 = [];
% cfg.channel         = 'MEG';
% cfg.vartrllength    = 1;
% tl                  = ft_timelockanalysis(cfg, data);
% %%
% %Plotting the ERF
% cfg                 = [];
% cfg.showlabels      = 'yes';
% cfg.showoutline     = 'yes';
% cfg.layout          = 'CTF151.lay';
% ft_multiplotER(cfg, tl);


%%

cfg_pn = [];
cfg_pn.method = 'distance';
                 cfg_pn.template = 'C:\Users\Thomas Meindertsma\Documents\MATLAB\CTF275_neighb.mat'
                 cfg_pn.template = 'CTF275_neighb'
cfg_pn.channel = 'MEG';

cfg_mp.planarmethod = 'sincos';
cfg_mp.trials = 'all';
cfg_mp.channel = 'MEG';
cfg_mp.neighbours = ft_prepare_neighbours(cfg_pn, dataL);
dataL = ft_megplanar(cfg_mp, dataL);

%%
%Doing time-frequency analysis
cfg                 = [];
cfg.method          = 'mtmconvol';
cfg.taper           = 'hanning';
cfg.channel         = 'MEG';

% set the frequencies of interest
cfg.foi             = linspace(12,36,25);%logspace(1,2,10);

% set the timepoints of interest: from -0.8 to 1.1 in steps of 100ms
cfg.toi             = -2:0.025:1; %-0.8:0.1:2;

% set the time window for TFR analysis: constant length of 200ms
cfg.t_ftimwin       = 0.25 * ones(length(cfg.foi), 1);

% average over trials
cfg.keeptrials      = 'no';

% pad trials to integer number of seconds, this speeds up the analysis
% and results in a neatly spaced frequency axis
cfg.pad             = 5; %originally 2
freqL                = ft_freqanalysis(cfg, dataL);

%%
%Combining components of the planar gradient

cfg                 = [];
%cfg.grad =   'ctf275_planar';
cfg.trials = 'all';
freqLC                = ft_combineplanar(cfg, freqL);

%%
%Baseline normalization fo rtime-frequency
% cfg                 = [];
% cfg.baseline        = [-0.8 -0.3]; %begin and end
% 
% freqLC=ft_freqbaseline(cfg,freqLC);


%%
cfg                 = [];
cfg.interactive     = 'yes';
cfg.showoutline     = 'yes';
cfg.layout          = 'CTF151.lay';
cfg.baseline        = [-2 -1.7];
cfg.baselinetype    = 'relchange';
cfg.zlim            = 'maxabs';
ft_multiplotTFR(cfg, freq);


%%
%Store data in a multi-dimensional matrix. 

%Subjects, by sesssion-typ, by eventtype(left or right?) by channel by freq by timepoint

TFdataMatrix=zeros(1,2,2,268,50,73); %In eventtype, left==1, right==2

TFdataMatrix(1,1,1,:,:,:)=freqL;
TFdataMatrix(1,1,2,:,:,:)=freqR;

d2M=squeeze(diff(1,1,1,200,:,:));

%%
%Topoplot using TFdataMatrix

cfg  = [];
cfg.xlim = [-0.2 0.2];
cfg.ylim = [36 150];
%cfg.zlim = [-1e-27 1e-27];
cfg.baseline = [-2 -1.7];
cfg.baselinetype = 'absolute';
cfg.layout = 'CTF151.lay';
figure; ft_topoplotTFR(cfg,freq)



%%
%Using subjectK from fieldtrip website.

cfg  = [];
data = ft_appenddata(cfg, data_left, data_right);




