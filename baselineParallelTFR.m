%Parallel baselining on the cluster.

%Create cfgs, one cell per participant. Might as well include all the 
%Parameters like start stop, response or stimulus locked data. Baselined
%trial by trial or averaged. 

%addpath

addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/'))
addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20160601/')
addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20160601/qsub')
ft_defaults
warning off

%%
clear;
%Placebo
runcfg.partlist = {
                             %269 channels
                           'AWi/20151007'
                          'SBa/20151006'
                          'JHo/20151004'
                          'JFo/20151007'
                          'AMe/20151008'
                          'SKo/20151011'
                          'JBo/20151011'
                          'DWe/20151003'
                          'FSr/20151003'
                          'JNe/20151004'
                           'RWi/20151003'
                           'HJu/20151004'
                           'LJa/20151006'
                           'BFu/20151010'
                           'EIv/20151003'
                           'JHa/20151010'
                           'FRa/20151007'
                           %268 channels
                           'MGo/20150815'
                           'JRi/20150828'
                           'HRi/20150816'
                          'AZi/20150818' 
                          'MTo/20150825'
                          'DLa/20150826'
                          'BPe/20150826'
                          'ROr/20150827'
                          'HEn/20150828'
                          'MSo/20150820'
                          'NSh/20150825'
                          'JRu/20150819'
                          'LMe/20150826'
% % %   %                        'MAm/20150825' %Avoid for behavior analysis
                             'MAb/20150816'
  }; 
                      
                      
runcfg.baseline.compile         = 'no';      %No                            
runcfg.baseline.parallel        = 'torque';      %Torque
runcfg.baseline.timreq          = 500; % 
runcfg.dataAnalysisType         = 'behavior'; %Behavior or MEG 


cfg1 = {};                      

if strcmp(runcfg.dataAnalysisType,'behavior')
    
    bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
    
    cd(bhpath)
    
    %Getting the names of the mat files that store behavioral data.
    [ PLA,ATM ] = loadSessions();
    
    
    for ipart = 1:length(runcfg.partlist)
        
        cfg1{ipart}.tau          = linspace(1,25,50);
        cfg1{ipart}.beta         = linspace(0.01,3,50);
        cfg1{ipart}.runs         = 1;
        cfg1{ipart}.session      = runcfg.partlist{ipart};
        cfg1{ipart}.ATMpath  = sprintf('%s%s',bhpath,ATM{ipart});
        cfg1{ipart}.PLApath  = sprintf('%s%s',bhpath,PLA{ipart});
        
        
        outputfile{ipart} = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/results/%s.mat'...
                                   ,cfg1{ipart}.session(1:3));
        
    end
elseif strcmp(runcfg.dataAnalysisType,'MEG')
    
    
    for ipart = 1:length(runcfg.partlist)
        
        
        cfg1{ipart}.start        = -0.5;
        cfg1{ipart}.stop         =  0;
        cfg1{ipart}.trialAverage = 'average'; %baseline each trial or avg.
        cfg1{ipart}.session      = runcfg.partlist{ipart};
        cfg1{ipart}.megsenspath  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/MEGsensors.mat';
        cfg1{ipart}.preprocFreq  = 'freq'; %concatenate TF or preproc trials
        
        cfg1{ipart}.stimResp     = 'stim'; %Do the baseline for stimulus period or for response?
        cfg1{ipart}.lowhigh      = 'low';  %low or high frequencies
        outputfile{ipart}.path   = sprintf ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedStim/%s.mat'...
            ,strrep(runcfg.partlist{ipart},'/','_') );
        
        
    end
    
end


%Switch between which type of data to analyse
switch runcfg.dataAnalysisType
    
    case 'MEG' %For TF analysis
        
        switch runcfg.baseline.compile
            
            case 'local'
                for alp = 1:length(cfg1)
                    createFullMatrix(cfg1{alp},outputfile{alp})
                %cellfun(@createFullMatrix, cfg1, outputfile);
                end
            case 'no'
                nnodes = 1;%64; % how many licenses?
                stack = 1;%round(length(cfg1)/nnodes);
                qsubcellfun(@createFullMatrix, cfg1, outputfile, 'compile', 'no', ...
                    'memreq', 1024^3, 'timreq', runcfg.baseline.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.baseline.parallel);
            case 'yes'
                compiledfun = qsubcompile(@createFullMatrix, 'toolbox', {'signal', 'stats'});
                qsubcellfun(compiledfun, cfg1, cfg2, inputfile, outputfile, ...
                    'memreq', 1024^3, 'timreq', cfg.timreq*60,'stack', 1, 'StopOnError', false, 'backend', runcfg.freq.parallel);
        end
        
    case 'behavior' %For behavioral analysis
        
        
        switch runcfg.baseline.compile
            
            case 'local'
                Model_performance(cfg1{1},outputfile{1})
                %cellfun(@Model_performance, cfg1, outputfile);
            case 'no'
                nnodes = 2;%64; % how many licenses?
                stack = 1;%round(length(cfg1)/nnodes);
                qsubcellfun(@Model_performance, cfg1, outputfile, 'compile', 'no', ...
                    'memreq', 10*1024^3, 'timreq', runcfg.baseline.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.baseline.parallel);
            case 'yes'
                compiledfun = qsubcompile(@Model_performance, 'toolbox', {'signal', 'stats'});
                qsubcellfun(compiledfun, cfg1, cfg2, inputfile, outputfile, ...
                    'memreq', 1024^3, 'timreq', cfg.timreq*60,'stack', 1, 'StopOnError', false, 'backend', runcfg.freq.parallel);
        end
        
end
%%
%Load all the participants for response
cd ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedResp');


baselined       = dir('*mat');

%Store the first powspctrm
load(baselined(1).name)

fullMatrixR.powsptrcm = zeros([length(baselined) size(partMatrix.powsptrcm)]);
fullMatrixR.powsptrcm(1,:,:,:,:) = partMatrix.powsptrcm;


%Loop and load all powspctrm data into fullMatrix
for iparticipants = 2:length(baselined)

load(baselined(iparticipants).name)

fullMatrixR.powsptrcm(iparticipants,:,:,:,:) = partMatrix.powsptrcm;

end

disp('Finished storing all participants in one 5-D matrix')


%Load all the participants for stimulus
cd ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedStim');


baselined       = dir('*mat');

%Store the first powspctrm
load(baselined(1).name)

fullMatrixS.powsptrcm = zeros([length(baselined) size(partMatrix.powsptrcm)]);
fullMatrixS.powsptrcm(1,:,:,:,:) = partMatrix.powsptrcm;


%Loop and load all powspctrm data into fullMatrix
for iparticipants = 2:length(baselined)

load(baselined(iparticipants).name)

fullMatrixS.powsptrcm(iparticipants,:,:,:,:) = partMatrix.powsptrcm;

end

disp('Finished storing all participants in one 5-D matrix')












