%Matching time frequency analysis.

%Create a cfg per parallell process. Then use qsub.

%For each datafile to run freq on create a seperate cfg cell. 

overwrite = runcfg.overwrite;
cfg = [];
cfg.output = 'pow';
% cfg.output = 'fourier';
cfg.channel = 'MEG';
cfg.keeptapers  = 'no';
cfg.pad = 5; 
cfg.method = 'mtmconvol';
cfg.runMIBmegcfg = runcfg;

cfg1={}; cfg2={}; inputfile={}; outputfile={}; ctr = 0; %make cells for each subject, to analyze in parallel




for iana=1:length(runcfg.freq.analysistype) %high low
    cfg.freqanalysistype = runcfg.freq.analysistype{iana};
    cfg.phaselocktype = runcfg.freq.phaselocktype{iana};
    cfg.timreq = runcfg.freq.timreq;
    cfg.sourceloc = sourceloc;
    
    switch cfg.freqanalysistype
        case 'high'
            cfg.taper = 'dpss'; % high frequency-optimized analysis (smooth)
            cfg.keeptrials  = 'yes';
            cfg.foi = 36:2:150;
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.25; %0.4
            cfg.tapsmofrq = ones(length(cfg.foi),1) .*8;
        case 'low'
            cfg.taper = 'hanning'; % low frequency-optimized analysis
            cfg.keeptrials  = 'yes'; % needed for fourier-output
            %             cfg.keeptapers = 'yes'; % idem
            cfg.foi = 3:35;
            %cfg.foi = linspace(12,36,25); %Same as postPreprocessing.
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.26;
            %cfg.tapsmofrq = ones(length(cfg.foi),1) .* 4.5;
        case 'full'
            cfg.taper = 'dpss'; % high frequency-optimized analysis (smooth)
            cfg.keeptrials  = 'yes';
            cfg.foi = 0:2:150;
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.4;   % length of time window = 0.4 sec
            cfg.tapsmofrq = ones(length(cfg.foi),1) .* 8;
        otherwise
            error('Unexpected analysisname. abort.');
    end %switch
    
    for itrg = 1:length(runcfg.trigger) %resp stim
        cfg.trigger=runcfg.trigger{itrg};
        switch cfg.trigger %Is the logic to do one trigger at a time?
            case 'baseline' %baseline means stimulus-locked
                cfg.toi = -0.65:0.026:0.13; %added 0.13 to each side, timewindow
            case 'stim'
                cfg.toi = -0.13:0.026:0.65;
            case 'cue'
                cfg.toi = -0.39:0.026:0.39; %might as well use the same toi
            case 'resp'
                cfg.toi = -0.91:0.026:0.13; %
            otherwise %Sort of reduntant
                cfg.toi = -1.5:0.025:1.5; % 3 sec TFR's
        end
        
        %Instead of trialsmib, should later concatenate all matching data.
        for i = 1:length(runcfg.batchlists);
            batch=[];
            eval(runcfg.batchlists{i}); %load in batchlist file, batch, PRE come out
            switch cfg.phaselocktype
                case 'evoked'
                    MIBexp_concatenatedata(batch, PRE, cfg.trigger, 1)
                    batch(length(batch)).exp = length(batch) + 1; % catdata saved under exp+1
                    batch = batch(length(batch)); %only analyze catdata
            end
            switch cfg.trigger %concat all trialsmib runs within subj
                case 'trialsmib'
                    MIBexp_concatenatedata(batch, PRE, cfg.trigger, 1)
                    batch(1).exp = length(batch) + 1; % catdata saved under exp+1
                    batch = batch(1); %only analyze catdata
            end
            
            
            %Find the number seperate preprocessed .mat files. 
            PREIN = ['/mnt/homes/home024/chrisgahn/Documents/MATLAB/preprocessed/' PRE];
            cd(PREIN)
            
            namesDir=sprintf('%s*.mat',batch(1).subj);
            
            blocksPreproc=dir(namesDir);
            
            blocksPreproc=blocksPreproc([blocksPreproc.bytes]>60000);
            
            
            for bind = 1:length(blocksPreproc) %for each datafile per subject. Should loop over blocks instead.
                
                PREOUT = ['/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/' cfg.freqanalysistype filesep PRE cfg.trigger filesep];
                
                infile=sprintf('%s%s_%s_resp_block%s', PREIN, batch(1).subj, batch(1).type,blocksPreproc(bind).name(end-5:end-4)); %Removed cfg.trigger
                preprocinfofile = sprintf('%s%s_%s_resp_preprocinfo_block%s.mat', PREIN, batch(1).subj, batch(1).type,blocksPreproc(bind).name(end-5:end-4)); %removed baseline
                infile = [infile '.mat' ];
                
                try load(preprocinfofile)
                    switch cfg.trigger
                        case {'resp' 'baseline' 'cue' 'stim' 'flickerresp' 'flickerstim'}
                            for itype = typeSession % 1=ATM, 2=PLA  Atomoxetine/placebo (Different conditions). Not sure, probably more reasonably different uncertainty levels.
                                for ievent = 1:2%2 % Stands for left vs right (Different events) where 1 == Left. 
                                    trialDirection          = ismember(preprocinfo.trl(:,10),eventLR(ievent,:)); 
                                    cfg.trials              = find(trialDirection); %Get indices of all trials of certain direction stimuli
                                    cfg.eventLR             = eventLR(ievent,:); %The real trial selection happens in freqanalysis.
                                    cfg.trialSampleStart    = preprocinfo.trl(:,1:2);
                                    %cfg.trials = find(preprocinfo.trl(:,10) == eventLR(ievent,1));
                                    if cfg.trials
                                        cfg.itype = itype; %Atomextine or placebo condition
                                        cfg.ievent = ievent;
                                       
                                        outfile = sprintf('%s%s_%s_%d_type%devent%d_%s_freq%s.mat', PREOUT, batch(1).subj, batch(1).type, ...
                                        cfg.t_ftimwin(1)*1000, itype, ievent,cfg.phaselocktype,blocksPreproc(bind).name(end-5:end-4));
                                        cfg.Outfilename=outfile;
                                        %if (~exist(outfile, 'file') && ~isempty(batch(1).dataset)) %Removed "|| overwrite"%% % add to the joblist if outf does not exist and not commented out in batch
                                            ctr = ctr + 1;
                                            cfg1{ctr}=cfg;
                                            cfg2{ctr}.vartrllength = 2; % for var trial length data, nans etc
                                            inputfile{ctr} = infile;
                                            outputfile{ctr} = outfile;
                                        %else
                                        %    [dummy, name]=fileparts(outfile);
                                        %    fprintf('%s exists! Skip it\n', name)
                                       % end
                                    else
                                        fprintf('itype %d, ievent %d not present in %s\n', itype,ievent,infile)
                                    end
                                end
                            end %itype
                        otherwise % baseline or trialsmib
                            outfile = sprintf('%s%s_%s%d_%d_%s_%s_%s_freq.mat', PREOUT, batch(1).subj, batch(1).type, ...
                                batch(bind).exp,cfg.t_ftimwin(1)*1000, cfg.trigger, batch(bind).filter,cfg.phaselocktype );
                            if ~exist(outfile, 'file') && ~isempty(batch(bind).dataset) || overwrite % add to the joblist if outf does not exist and not commented out in batch
                                cfg.trials = 'all';
                                ctr = ctr + 1;
                                cfg1{ctr}=cfg;
                                cfg2{ctr}.vartrllength = 2; % for var trial length data, nans etc
                                inputfile{ctr} = infile;
                                outputfile{ctr} = outfile;
                            else
                                [dummy, name]=fileparts(outfile);
                                fprintf('%s exists! Skip it\n', name)
                            end
                    end %switch cfg.trigger
                catch ME
                    fprintf('%s not found\n', preprocinfofile)
                end
            end % for bind = 1:length(batch)
        end %length(runcfg.batchlists)
    end %itrg
    
    
    setenv('TORQUEHOME', 'yes')  %    yes or ''
    %         ntest=20; % for testing with qsub
    %         inputfile=inputfile(1:ntest);
    %         outputfile=outputfile(1:ntest); cfg2=cfg2(1:ntest); cfg1=cfg1(1:ntest);
    cd('~/Documents/MATLAB/code/analysis/TFGitAnlysis/')
    switch runcfg.freq.compile
        
        case 'local'
            %MatchingExp_freqanalysis(cfg1{3}, cfg2{3}, inputfile{3}, outputfile{3})
            cellfun(@MatchingExp_freqanalysis, cfg1, cfg2, inputfile, outputfile);
        case 'no'
            nnodes = 1;%64; % how many licenses?
            stack = 1;%round(length(cfg1)/nnodes);
            qsubcellfun(@MatchingExp_freqanalysis, cfg1, cfg2, inputfile, outputfile, 'compile', 'no', ...
                'memreq', 1024^3, 'timreq', cfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.freq.parallel);
        case 'yes'
            compiledfun = qsubcompile(@MatchingExp_freqanalysis, 'toolbox', {'signal', 'stats'});
            qsubcellfun(compiledfun, cfg1, cfg2, inputfile, outputfile, ...
                'memreq', 1024^3, 'timreq', cfg.timreq*60,'stack', 1, 'StopOnError', false, 'backend', runcfg.freq.parallel);
    end
    
end