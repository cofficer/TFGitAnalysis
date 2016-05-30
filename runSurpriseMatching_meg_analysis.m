% runSurprieMatching_meg_analysis.m
% run preproc and freqanalysis 
clear all; close all;
%cd('/home/chrisgahn/Documents/MATLAB/code/batch')
addpath(genpath('/home/chrisgahn/Documents/MATLAB/code/'))
addpath(genpath('/home/chrisgahn/Documents/MATLAB/fieldtrip/'))
cd('/home/meindertsmat/data/Matching/MEG/raw/')
%Peters home directory
%cd('/home/pmurphy/meg_data/')

runcfg = [];
runcfg.batchlists = {
        
        %Peter Murphys Batch files. TimeScale experiment.
%       'batchTimeScalexp_CGa_20160129'
%       'batchTimeScalexp_EIv_20160204'   
%       'batchTimeScalexp_JRu_20160205'
       
       

%    'batchSurpriseMatchingexp_MAb_test' %Only temporary testing batch. 
%     
%    %#Placebo batch files
%    %'batchSurpriseMatchingexp_TLa_170815' #Incomplete sessions. No batch.
%     'batchSurpriseMatchingexp_MAm_250815' %#Missing triggers both
%                                           sessions. Also party missing ETrigger after restoration.
%     'batchSurpriseMatchingexp_MAb_160815' %Can't even read event #Missing triggers placebo
%     'batchSurpriseMatchingexp_MGo_150815' %Succes3, (maybe few files)#Missing triggers??
%     'batchSurpriseMatchingexp_HRi_160815' %Succes3 #Missing triggers placebo
%     'batchSurpriseMatchingexp_AZi_180815' Success3 %#Missing trigger 2nd datafile.
%    %'batchSurpriseMatchingexp_JNi_250815' #Incomplete sessions. No batch.
%     'batchSurpriseMatchingexp_MSo_200815' %Success4  #Last trial 193, missing trig.
%     'batchSurpriseMatchingexp_MTo_250815' %#Succes (first part). Missing triggers
%     'batchSurpriseMatchingexp_DLa_260815' %#REDO, doesnt exist
%     'batchSurpriseMatchingexp_BPe_260815' %# Succes3 - Missing triggers both sessions
%     'batchSurpriseMatchingexp_NSh_250815' %#Success4.
%     'batchSurpriseMatchingexp_JRi_280815'  %Success4 %#.
%     'batchSurpriseMatchingexp_JRu_190815' %Succes3 #Missing triggers placebo
%     'batchSurpriseMatchingexp_LMe_260815' %#Missing triggers. Missing ETtrigger from event
%     'batchSurpriseMatchingexp_HEn_280815' %#Strange error. Missing triggers dataset2?
%     'batchSurpriseMatchingexp_ROr_270815' %#Success4, but high blink rate.
%     'batchSurpriseMatchingexp_DWe_031015' #Success2, (corrected 17nov)
%     'batchSurpriseMatchingexp_FSr_031015' %#Success4,
%     'batchSurpriseMatchingexp_JNe_041015' %#Success4
%     'batchSurpriseMatchingexp_RWi_031015' %#Almost preprocessed. Issue with missing value of data.time{19} for last block, 
%     'batchSurpriseMatchingexp_EIv_031015' %Data set error. #Lst trial is 0
%     'batchSurpriseMatchingexp_SBa_061015' %Succes4
%     'batchSurpriseMatchingexp_HJu_041015' % Success4 Way too many EYE artifacts
%     'batchSurpriseMatchingexp_JHo_041015' %#Success4
%     'batchSurpriseMatchingexp_FRa_071015' %Eror cannot read data.  
%     'batchSurpriseMatchingexp_JFo_071015' %Success4
%     'batchSurpriseMatchingexp_AWi_071015' %Success4
%     'batchSurpriseMatchingexp_JHa_101015' %JHa and JHa2, strange.
%     'batchSurpriseMatchingexp_LJa_061015' %Success4
%     'batchSurpriseMatchingexp_AMe_081015' %Success4
%    %'batchSurpriseMatchingexp_DJu_091015' #Incomplete sessions. No batch.
%     'batchSurpriseMatchingexp_SKo_111015' %Success4
%    'batchSurpriseMatchingexp_BFu_101015' % Error with 3rd.ds file.
%    Otherwise success
%     'batchSurpriseMatchingexp_JBo_111015' %Success4
%     
%     
%    %#Atomoxetine batch files
%    %'batchSurpriseMatchingexp_TLa_160815' #Incomplete sessions. No batch.
%     'batchSurpriseMatchingexp_MAm_150815' %Succes3, maybe few files? %#Missing triggers both sessions
%     'batchSurpriseMatchingexp_MAb_150815' %Same error as for placebo session.
%     'batchSurpriseMatchingexp_MGo_190815' %Succes3 %#Missing triggers atomoxetine
%     'batchSurpriseMatchingexp_HRi_150815' %Success4
%     'batchSurpriseMatchingexp_AZi_160815' %Missing MEG data. See excel
%     'batchSurpriseMatchingexp_JNi_250815' %#Incomplete sessions. No batch.
%     'batchSurpriseMatchingexp_MSo_190815' %Success4 
%     'batchSurpriseMatchingexp_MTo_250815' Success4
%     'batchSurpriseMatchingexp_DLa_270815' %Succes4 #Missing trigger atomoxetine
%     'batchSurpriseMatchingexp_BPe_250815' %Success4#Missing triggers both sessions
%     'batchSurpriseMatchingexp_NSh_270815' Success4-lacking one block %#Missing triggers atomoxetine
%     'batchSurpriseMatchingexp_JRi_270815' Success4
%     'batchSurpriseMatchingexp_JRu_260815' %Sucess4
%     'batchSurpriseMatchingexp_LMe_280815' Success4 missing one block%Missing triggers atomoxetine
%     'batchSurpriseMatchingexp_HEn_270815' #success
%     'batchSurpriseMatchingexp_ROr_280815' Success4
%     'batchSurpriseMatchingexp_DWe_041015' %Success4
%     'batchSurpriseMatchingexp_FSr_041015' %Success2
%     'batchSurpriseMatchingexp_JNe_031015' %Succes4-2, terminated early...
%     'batchSurpriseMatchingexp_RWi_041015' %Partially preprocessed. Issue with EOG channel,
%     'batchSurpriseMatchingexp_EIv_061015' % 4 -Crashed on the last block. Couldnt access artfctdef.id(0,1)
%     'batchSurpriseMatchingexp_SBa_041015' #Success2 (without first block)
%     'batchSurpriseMatchingexp_HJu_101015' #Success3 (NaN for muscle)
%     'batchSurpriseMatchingexp_JHo_061015' #Success3
%     'batchSurpriseMatchingexp_FRa_061015' #Success3
%     'batchSurpriseMatchingexp_JFo_061015' #Success3 except last cfg
%     'batchSurpriseMatchingexp_AWi_111015' #Success3
%     'batchSurpriseMatchingexp_JHa_061015' #Success3
%     'batchSurpriseMatchingexp_LJa_111015' #Success3
%     'batchSurpriseMatchingexp_AMe_071015' %Error index out of bounds
%    %'batchSurpriseMatchingexp_DJu_091015' #Incomplete sessions. No batch.
%     'batchSurpriseMatchingexp_SKo_101015' %Success3
%     'batchSurpriseMatchingexp_BFu_111015' %Success3
%     'batchSurpriseMatchingexp_JBo_101015' %Success3
};

runcfg.trigger = {
        'resp'
%         'stim'
% 'trialsmib's
%         'baseline'
% 'flickerresp'
%% 
% 'flickerstim'
% 'flicker'
        };

%% Peersetup preproc scripts
% dbstop if error
% runcfg.overwrite =1;
% runcfg.append_et = 1;
% runcfg.sourceloc = 'no';
% 
% % % preproc runanalysis settings
% runcfg.preproc.loaddata = 'no'; %load in data to do visual muscle rejection
% runcfg.preproc.loaddatapath = '/home/chrisgahn/Documents/MATLAB/preprocessed/';
% 
% runcfg.preproc.artf_rejection = 'yes';
% runcfg.preproc.artf_feedback = 'no';
% runcfg.preproc.loadartf = 'no';
% 
% runcfg.preproc.parallel = 'local'; %torque peer local qsublocal
% runcfg.preproc.compile = 'no';
% 
% runcfg.preproc.prunemibfromrep = 'no'; % yes
% 
% fprintf('Running MIBmeg preproc analysis . . .\n\n')
% disp(runcfg.preproc.parallel); disp(runcfg.batchlists); disp(runcfg);
% 
% warning off
% % 
% MIBexp_preproc_peersetup

% MIBexp_plotpie_artifacts

%% Peersetup freq scripts
%Change folder to git repository analysis
dbstop if error
warning off
%dbclear all
cd('/home/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/')


runcfg.overwrite = 1;
sourceloc = 0;

runcfg.freq.analysistype = {
%    'low'
     'high'
%     'full'
    };

runcfg.freq.phaselocktype = {
    'totalpow'
    %'induced'
%     'evoked'
    };

% runcfg.freq.timreq = [25 50]; % high low in minutes
runcfg.freq.timreq = 40; % 

runcfg.freq.parallel = 'torque'; %torque peer local 
runcfg.freq.compile = 'no'; % yes no
% 
fprintf('Running Matching MEG freq analysis . . .\n\n')
%disp(runcfg.freq.parallel); disp(runcfg.batchlists); disp(runcfg);
disp(runcfg.freq.parallel); disp(runcfg);

typeSession = 1; %1 = ATM, 2 = PLACEBO. 
eventLR     = [21,20;22,23];


% warning off
%MatchingExp_freqanalysis_peersetup
machingExpParallelRuns
% 

%clear all; close all;
% 


% % 
% plotTFR_SurpriseReplayexp
% 
% MIBexp_corrfreq_statedur_bands

% 
% plotTFR_stimulusresponse
% 
    




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% qsub beta testing
% % cfg=[]; % simple test
% % % cfg.dataset = '/home/niels/MIBmeg/data/s10_NR/011111/NR011111_run1_tsss.fif';
% cfg.dataset='/home/niels/MIBeeg/DummyData/DummyRecording_01.vhdr';
% compiledfun = qsubcompile('ft_preprocessing');
% data = qsubcellfun(compiledfun, {cfg}, 'memreq', 1024^3, 'timreq', 3, 'backend', 'torque');

% compiledfun = qsubcompile('rand');
% qsubcellfun(compiledfun, {1, 2, 3}, 'memreq', 1024^3, 'timreq', 60)

