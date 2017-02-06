%Parallel baselining on the cluster.

%Create cfgs, one cell per participant. Might as well include all the 
%Parameters like start stop, response or stimulus locked data. Baselined
%trial by trial or averaged. 

%addpath
warning off
addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis'))
addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20160601/')
addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20160601/qsub')
ft_defaults


%%
%clear;
%Placebo
runcfg.partlist = {
% %                  %%%             269 channels
                           'AWi/20151007'
                             'SBa/20151006'
                            'JHo/20151004'
                             'JFo/20151007'
  
                            'SKo/20151011'
                         'JBo/20151011'
                          'DWe/20151003'
                         'FSr/20151003'
                         'JNe/20151004'
                           'RWi/20151003'
                           'HJu/20151004'
                           'LJa/20151006'
                            'AMe_20151008'
                            'BFu/20151010'
                            'EIv/20151003'
                           'JHa/20151010'
                           'FRa/20151007' 
  %%%%%%%                         268 channels
  %                         'MGo/20150815' %ignore bad behavior
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
%                          'JRu/20150819' %Ignore bad behavor
                          'LMe/20150826'
                          'MAb/20150816'
%Check out MAm                        'MAm/20150825' %Avoid for behavior analysis
                              
  }; 
                      
                      
runcfg.baseline.compile         = 'no';      %No    local                        
runcfg.baseline.parallel        = 'torque';      %torque local?
runcfg.baseline.timreq          = 800; % 
runcfg.dataAnalysisType         = 'behavior'; %behavior or MEG or selectLFI


cfg1 = {};                      

if strcmp(runcfg.dataAnalysisType,'behavior')
    
    bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
    
    cd(bhpath)
    
    %Getting the names of the mat files that store behavioral data.
    setting.numParticipants = 31;
    setting.bhpath          = bhpath;
    [ PLA,ATM ] = loadSessions(setting);
    
    participantPath = dir('*mat');
    
    for ipart = 1:length(runcfg.partlist)
        
        cfg1{ipart}.tau          = linspace(1,20,100);
        cfg1{ipart}.beta         = linspace(0.1,2,100);
        cfg1{ipart}.ls           = linspace(0,1,100);
        %what does simulate do?
        cfg1{ipart}.simulate     = 0;
        cfg1{ipart}.numparameter    = '3';
        cfg1{ipart}.drugEffect   = 1; %1 if order of intervention, 0 if session order
        cfg1{ipart}.simulateLoseSwitch   = 0; %1 of simulate lose-switch heuristic
        cfg1{ipart}.runs         = 1;
        cfg1{ipart}.currPart     = ipart; 
        cfg1{ipart}.session      = runcfg.partlist{ipart};
        %Decide how if the paths should be ordered as indiceted ATM/PLA. Then 1 
        if cfg1{ipart}.drugEffect == 1
            cfg1{ipart}.ATMpath  = sprintf('%s%s',bhpath,ATM{ipart});
            cfg1{ipart}.PLApath  = sprintf('%s%s',bhpath,PLA{ipart});
        else
            cfg1{ipart}.ATMpath                = strcat(bhpath,participantPath(ipart*2).name);
            cfg1{ipart}.PLApath                = strcat(bhpath,participantPath(ipart*2-1).name);
        end
        cfg1{ipart}.numParticiants = setting.numParticipants;
        cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/%s.mat'...
            ,cfg1{ipart}.session(1:3));
        
        
        
    end
elseif strcmp(runcfg.dataAnalysisType,'MEG')
    
    
    for ipart = 1:length(runcfg.partlist)
        
        
        cfg1{ipart}.start        = -0.52;
        cfg1{ipart}.stop         =  0;
        cfg1{ipart}.trialAverage = 'average'; %baseline each trial or avg.
        cfg1{ipart}.session      = runcfg.partlist{ipart};
        cfg1{ipart}.megsenspath  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/MEGsensors.mat';
        cfg1{ipart}.preprocFreq  = 'freq'; %concatenate TF or preproc trials
        
        cfg1{ipart}.stimResp     = 'cue'; %Get response or stimulus locked data, or cue locked.
        cfg1{ipart}.lowhigh      = 'low';  %low or high frequencies
        outputfile{ipart}.path   = sprintf ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/trialsLowFreq/baselinedCue/%s.mat'...
            ,strrep(runcfg.partlist{ipart},'/','_') );
        
        
    end
elseif strcmp(runcfg.dataAnalysisType,'selectLFI')
        %Create a cfg per participant, per proba-level per event
        %I could just load LFI, same for idxLR and Ttotal
        %new arguments include, part number, and level of probChoice
        sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
            'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
            'MRF54','MRF55','MRF56','MRF66','MRF46'};
        sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
            'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
            'MLF54','MLF55','MLF56','MLF66','MLF46'};
        resp=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
        
        [~,idxR]=intersect(resp.freq.grad.label,sensR);
        [~,idxL]=intersect(resp.freq.grad.label,sensL);
        idxLR = [idxL idxR];
        
        njobs = 1;
        
        events = {'Stim','Cue','Resp'}';
        
        for ipart = 1:length(runcfg.partlist)
            for ilevel = 1:2
                for ievent = 1:3
                    cfg1{njobs}.participant = runcfg.partlist{ipart}(1:3);
                    cfg1{njobs}.PBlevel = 1;
                    cfg1{njobs}.idxLR = idxLR;
                    cfg1{njobs}.PBlevel =  ilevel;
                    cfg1{njobs}.event  = events{ievent};
                    njobs = njobs + 1;
                end
                
            end
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
                parameterFitting_Tor(cfg1{1})
                %cellfun(@Model_performance, cfg1, outputfile);
            case 'no'
                nnodes = 1;%64; % how many licenses?
                stack = 1;%round(length(cfg1)/nnodes);
                qsubcellfun(@parameterFitting_Tor, cfg1, 'compile', 'no', ...
                    'memreq', 10*1024^3, 'timreq', runcfg.baseline.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.baseline.parallel);
            case 'yes'
                compiledfun = qsubcompile(@Model_performance, 'toolbox', {'signal', 'stats'});
                qsubcellfun(compiledfun, cfg1, cfg2, inputfile, outputfile, ...
                    'memreq', 1024^3, 'timreq', cfg.timreq*60,'stack', 1, 'StopOnError', false, 'backend', runcfg.freq.parallel);
        end
    case 'selectLFI'
        
        
        switch runcfg.baseline.compile
            
            case 'local'
                cellfun(@selectLFI_Tor, cfg1)
                %Model_performance(cfg1{1},outputfile{1})
                %cellfun(@Model_performance, cfg1, outputfile);
            case 'no'
                nnodes = 1;%64; % how many licenses?
                stack = 1;%round(length(cfg1)/nnodes);
                qsubcellfun(@selectLFI_Tor, cfg1, 'compile', 'no', ...
                    'memreq', 5*1024^3, 'timreq', runcfg.baseline.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.baseline.parallel);
            case 'yes'
                compiledfun = qsubcompile(@selectLFI_Tor, 'toolbox', {'signal', 'stats'});
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












