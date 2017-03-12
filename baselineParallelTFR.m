%Parallel baselining on the cluster.

%Create cfgs, one cell per participant. Might as well include all the 
%Parameters like start stop, response or stimulus locked data. Baselined
%trial by trial or averaged. 

%addpath
warning off
addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis'))
addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170124/')
addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170124/qsub')
ft_defaults


%%
%clear;
%Placebo
runcfg.partlist = {
    %                  %%%             269 channels
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
    % %   %%%%%%%                         268 channels
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
    % %                          'JRu/20150819' %Ignore bad behavor
    'LMe/20150826'
    'MAb/20150816'
    %Check out MAm                        'MAm/20150825' %Avoid for behavior analysis
    
    };
                      
                      
runcfg.baseline.compile         = 'no';      %No    local                        
runcfg.baseline.parallel        = 'torque';      %torque local?
runcfg.baseline.timreq          = 2000; % number of minutes. 
runcfg.dataAnalysisType         = 'parameterOptimize'; %behavior or MEG or selectLFI or parameterOptimize


cfg1 = {};                      

if strcmp(runcfg.dataAnalysisType,'behavior')
    
    bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
    
    cd(bhpath)
    
    %Getting the names of the mat files that store behavioral data.
    setting.numParticipants = 29;
    setting.bhpath          = bhpath;
    [ PLA,ATM ] = loadSessions(setting);
    
    participantPath = dir('*mat');
    
    betalogspace = logspace(-2.82,0.3,1000);
    taulogspace  = logspace(0,4,1000);
    
    for ipart = 1:length(runcfg.partlist)
        
        
        %Get the index of the current specified participant from runcfg to
        %PLA.
        defPart = runcfg.partlist{ipart};
        PLAshort = cellfun(@(x) x(1:3),PLA,'UniformOutput',false);
        indxPLA=strcmp(defPart(1:3),PLAshort);

        %what does simulate do? Simalate model choices.
        cfg1{ipart}.simulate     = 0;
        cfg1{ipart}.modelchoices = 0; %Ignores the maximum likelihood estimation if 1. Yes if recover??
        cfg1{ipart}.test         = 0;%Deceide to run one cfg or more.
        cfg1{ipart}.recover      = 0; %Recover parameter fits of already simulated sessions.
        cfg1{ipart}.perfsim      = 0; %Simulate optimal parameter for highest performance.
        cfg1{ipart}.runs         = 1;
        cfg1{ipart}.numparameter = '1';
        %Create the cfg for job submit.
        if cfg1{ipart}.modelchoices && ~cfg1{ipart}.perfsim
            cfg1{ipart}.tau          = 1 + (20-1).*rand(1,cfg1{ipart}.runs);
            %Randomly draw beta value from logspace distribution
            rpos                     =randperm(length(betalogspace),cfg1{ipart}.runs);
            cfg1{ipart}.beta         = betalogspace(rpos);%0.1 + (5-0.1).*rand(1,cfg1{ipart}.runs);
            cfg1{ipart}.ls           = rand(1,cfg1{ipart}.runs);
            
            
        elseif cfg1{ipart}.modelchoices && cfg1{ipart}.perfsim
             cfg1{ipart}.tau         = logspace(0,3,cfg1{ipart}.runs);%1 + (300-1).*rand(1,cfg1{ipart}.runs);
            %Randomly draw beta value from logspace distribution
            rpos                     = randi(length(betalogspace),1,cfg1{ipart}.runs);
            cfg1{ipart}.beta         = ones(1,cfg1{ipart}.runs)*0.05;%betalogspace(rpos);%0.1 + (5-0.1).*rand(1,cfg1{ipart}.runs);
            cfg1{ipart}.ls           = zeros(1,cfg1{ipart}.runs);%rand(1,cfg1{ipart}.runs);
        else
            if cfg1{ipart}.numparameter=='3'
                cfg1{ipart}.tau          = linspace(1,20,30);
                cfg1{ipart}.beta         = logspace(-2.82,0.3,30);%linspace(0.1,5,30);
                cfg1{ipart}.ls           = linspace(0,1,30);
                
            elseif cfg1{ipart}.numparameter=='2'
                
                cfg1{ipart}.tau          = linspace(1,20,100);
                cfg1{ipart}.beta         = logspace(-2.82,0.3,100);%linspace(0.1,5,30);
                cfg1{ipart}.ls           = linspace(0,1,30);
            elseif cfg1{ipart}.numparameter=='1'
                
                cfg1{ipart}.tau          = linspace(1,20,1000);
                cfg1{ipart}.beta         = logspace(-2.82,0.3,100);%linspace(0.1,5,30);
                cfg1{ipart}.ls           = linspace(0,1,30);
                
            end
        end
        %Define the number of parameter pairs to output.
        cfg1{ipart}.bestfits     = 30;%length(cfg1{ipart}.tau); 
        %If three then tau beta and ls. 
        
        cfg1{ipart}.drugEffect   = 1; %1 if order of intervention, 0 if session order
        cfg1{ipart}.simulateLoseSwitch   = 0; %1 of simulate lose-switch heuristic
        
        cfg1{ipart}.currPart     = ipart;
        
        %choose simulated choice or participant choices to model fit. 
        if cfg1{ipart}.recover
            cfg1{ipart}.session      = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/%s.mat',PLA{indxPLA}(1:3));
            cfg1{ipart}.path         = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/%s.mat',PLA{indxPLA}(1:3));
        else 
            cfg1{ipart}.session      = PLA{indxPLA};
            cfg1{ipart}.path         = PLA{indxPLA};
        end
        %Decide how if the paths should be ordered as indiceted ATM/PLA. Then 1 
        %if cfg1{ipart}.drugEffect == 1
        %    cfg1{ipart}.ATMpath  = sprintf('%s%s',bhpath,ATM{indxPLA});
        %    cfg1{ipart}.PLApath  = sprintf('%s%s',bhpath,PLA{indxPLA});
        %else
        %    cfg1{ipart}.ATMpath                = strcat(bhpath,participantPath(ipart*2).name);
        %    cfg1{ipart}.PLApath                = strcat(bhpath,participantPath(ipart*2-1).name);
        %end
        cfg1{ipart}.numParticiants = setting.numParticipants;
        
        if cfg1{ipart}.numparameter =='2'
            cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/%s.mat'...
                    ,cfg1{ipart}.path(1:3));
        elseif cfg1{ipart}.numparameter =='1'
            cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/1params/%s.mat'...
                    ,cfg1{ipart}.path(1:3));
        else
            if cfg1{ipart}.simulate==1 && ~cfg1{ipart}.perfsim
                cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/%s.mat'...
                    ,cfg1{ipart}.path(1:3));
            elseif cfg1{ipart}.recover
                cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/roughfit/%s.mat',PLA{indxPLA}(1:3));
            elseif cfg1{ipart}.perfsim
                cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/performance/%s.mat',PLA{indxPLA}(1:3));
            elseif cfg1{ipart}.simulate==0
                cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/%s.mat'...
                    ,cfg1{ipart}.path(1:3));
                
            end
        end
        
    end

elseif strcmp(runcfg.dataAnalysisType,'parameterOptimize')
    %
    %----------------------------------------------------------------------
    %Optimize the rough grid seach of parameter space.
    %----------------------------------------------------------------------
     
    bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
    
    cd(bhpath)
    
    %Getting the names of the mat files that store behavioral data.
    setting.numParticipants = 29;
    setting.bhpath          = bhpath;
    [ PLA,ATM ] = loadSessions(setting);
    
    participantPath = dir('*mat');
    

    
    for ipart = 1:length(runcfg.partlist)
        
        
        %Get the index of the current specified participant from runcfg to
        %PLA.
        defPart = runcfg.partlist{ipart};
        PLAshort = cellfun(@(x) x(1:3),PLA,'UniformOutput',false);
        indxPLA=strcmp(defPart(1:3),PLAshort);
        
        %Create the cfg for job submit.
        cfg1{ipart}.tau          = linspace(1,20,5);
        cfg1{ipart}.beta         = linspace(0.1,5,5);
        cfg1{ipart}.ls           = linspace(0,1,5);
        %what does simulate do? Simalate model choices.
        cfg1{ipart}.simulate     = 0;
        cfg1{ipart}.modelchoices = 0; %Ignores the maximum likelihood estimation if 1. 
        cfg1{ipart}.recover      = 0;
        cfg1{ipart}.funceval     = 30000;
        cfg1{ipart}.iter         = 10000;
        %Define the number of parameter pairs to output.
        cfg1{ipart}.bestfits     = 30; 
        cfg1{ipart}.numparameter = '1';
        cfg1{ipart}.drugEffect   = 1; %1 if order of intervention, 0 if session order
        cfg1{ipart}.simulateLoseSwitch   = 0; %1 of simulate lose-switch heuristic
        cfg1{ipart}.runs         = 1;%Same number of run as simualtions per session
        cfg1{ipart}.currPart     = ipart;
        if cfg1{ipart}.modelchoices
            cfg1{ipart}.session      = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/roughfit/%s.mat',PLA{indxPLA}(1:3));
            cfg1{ipart}.path         = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/roughfit/%s.mat',PLA{indxPLA}(1:3));
            
        else
            cfg1{ipart}.session      = PLA{indxPLA};
            cfg1{ipart}.path         = PLA{indxPLA};
        end
        
        cfg1{ipart}.numParticiants = setting.numParticipants;
        
        if cfg1{ipart}.numparameter =='2'
            cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/optimized/%s.mat'...
                ,cfg1{ipart}.path(1:3));
        elseif cfg1{ipart}.numparameter =='1'
            cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/1params/optimized/%s.mat'...
                ,cfg1{ipart}.path(1:3));
        else
            if cfg1{ipart}.recover==1
                cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/optimized/%s.mat'...
                    ,PLA{indxPLA}(1:3));
            elseif cfg1{ipart}.simulate==0
                cfg1{ipart}.outputfile     = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/optimized/%s.mat'...
                    ,cfg1{ipart}.path(1:3));
            end
        end
        
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
                if cfg1{ipart}.test
                    parameterFitting_Tor(cfg1{10})
                else
                    cellfun(@parameterFitting_Tor, cfg1);
                end
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
    case 'parameterOptimize'
        
        switch runcfg.baseline.compile
            
            case 'local'
                optimizeParameterFitting(cfg1{1})
                %cellfun(@Model_performance, cfg1, outputfile);
            case 'no'
                nnodes = 1;%64; % how many licenses?
                stack = 1;%round(length(cfg1)/nnodes);
                qsubcellfun(@optimizeParameterFitting, cfg1, 'compile', 'no', ...
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
% cd ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedResp');
% 
% 
% baselined       = dir('*mat');
% 
% %Store the first powspctrm
% load(baselined(1).name)
% 
% fullMatrixR.powsptrcm = zeros([length(baselined) size(partMatrix.powsptrcm)]);
% fullMatrixR.powsptrcm(1,:,:,:,:) = partMatrix.powsptrcm;
% 
% 
% %Loop and load all powspctrm data into fullMatrix
% for iparticipants = 2:length(baselined)
% 
% load(baselined(iparticipants).name)
% 
% fullMatrixR.powsptrcm(iparticipants,:,:,:,:) = partMatrix.powsptrcm;
% 
% end
% 
% disp('Finished storing all participants in one 5-D matrix')
% 
% 
% %Load all the participants for stimulus
% cd ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedStim');
% 
% 
% baselined       = dir('*mat');
% 
% %Store the first powspctrm
% load(baselined(1).name)
% 
% fullMatrixS.powsptrcm = zeros([length(baselined) size(partMatrix.powsptrcm)]);
% fullMatrixS.powsptrcm(1,:,:,:,:) = partMatrix.powsptrcm;
% 
% 
% %Loop and load all powspctrm data into fullMatrix
% for iparticipants = 2:length(baselined)
% 
% load(baselined(iparticipants).name)
% 
% fullMatrixS.powsptrcm(iparticipants,:,:,:,:) = partMatrix.powsptrcm;
% 
% end
% 
% disp('Finished storing all participants in one 5-D matrix')
% 
% 
% 









