% MIBexp_freqanalysis_peersetup
% called by runMIBmeg_analysis

overwrite = runcfg.overwrite;
cfg = [];
cfg.output = 'pow';
% cfg.output = 'fourier';
cfg.channel = 'MEG';
cfg.keeptapers  = 'no';
cfg.pad = 7;
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
            cfg.keeptrials  = 'no';
            cfg.foi = 36:2:150;
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.4;
            cfg.tapsmofrq = ones(length(cfg.foi),1) .* 8;
        case 'low'
            cfg.taper = 'hanning'; % low frequency-optimized analysis
            cfg.keeptrials  = 'yes'; % needed for fourier-output
%             cfg.keeptapers = 'yes'; % idem
            cfg.foi = 3:35;
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.4;
            cfg.tapsmofrq = ones(length(cfg.foi),1) .* 4.5;
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
        switch cfg.trigger
            case 'baseline'
                cfg.toi = 0:0.025:2;
            case 'trialsmib'
                cfg.toi = -0.3:0.025:1.5;
            case 'flickerstim'
                cfg.toi = -1.5:0.025:3; 
            otherwise
                cfg.toi = -1.5:0.025:1.5; % 3 sec TFR's
        end
        
        for i = 1:length(runcfg.batchlists)
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
                    
            for bind = 1:length(batch) %for each run per subject
                PREIN = ['/mnt/homes/home020/meindertsmat/data/MEG/preproc/' PRE];
                PREOUT = ['/mnt/homes/home020/meindertsmat/data/MEG/freq/' cfg.freqanalysistype filesep PRE cfg.trigger filesep];
                if cfg.runMIBmegcfg.append_et
                    infile = sprintf('%s%s_%s%d_%s_%s_data_appended', PREIN, batch(bind).subj, batch(bind).type, batch(bind).exp, batch(bind).filter, cfg.trigger);
                else
                    infile = sprintf('%s%s_%s%d_%s_%s_data', PREIN, batch(bind).subj, batch(bind).type, batch(bind).exp, batch(bind).filter, cfg.trigger);
                end
                % load in preprocinfo and figure out if condition is there, % if yes put in queue
                preprocinfofile = [infile '_preprocinfo.mat'];
                infile = [infile '.mat' ];
                try load(preprocinfofile)
                    switch cfg.trigger
                        case {'resp' 'stim' 'flickerresp' 'flickerstim'}
                            for itype = 1:7 %  !!!!!!!!!!!! 1:3 % 1=D1-act, 2= D2-act, 3= D3-act, 4= D1-cou, 5= D2-cou, 6= D3-cou, 7= MIB
                                for ievent = 1:2 %1= OFF, 2=ON target
                                    cfg.trials = find(preprocinfo.trl(:,4) == itype & preprocinfo.trl(:,5) == ievent);
                                    if cfg.trials
                                        cfg.itype = itype; %MIBexp variables
                                        cfg.ievent = ievent;
                                        outfile = sprintf('%s%s_%s%d_%d_type%devent%d_%s_%s_freq.mat', PREOUT, batch(bind).subj, batch(bind).type, ...
                                            batch(bind).exp,cfg.t_ftimwin(1)*1000, itype, ievent, batch(bind).filter,cfg.phaselocktype );
                                        
                                        if (~exist(outfile, 'file') && ~isempty(batch(bind).dataset)) || overwrite % add to the joblist if outf does not exist and not commented out in batch
                                            ctr = ctr + 1;
                                            cfg1{ctr}=cfg;
                                            cfg2{ctr}.vartrllength = 2; % for var trial length data, nans etc
                                            inputfile{ctr} = infile;
                                            outputfile{ctr} = outfile;
                                        else
                                            [dummy, name]=fileparts(outfile);
                                            fprintf('%s exists! Skip it\n', name)
                                        end
                                    else
                                        fprintf('itype %d, ievent %d not present in %s\n', itype,ievent,infile)
                                    end
                                end
                            end %itype
                        otherwise % baseline or trialsmib
                            outfile = sprintf('%s%s_%s%d_%d_%s_%s_%s_freq.mat', PREOUT, batch(bind).subj, batch(bind).type, ...
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
    
    %Submit jobs
    fprintf('Running MIBexp_freq_analysis for %d cfgs\n', length(cfg1))
    disp(cfg1{1})
    disp(cfg2{1})
    switch runcfg.freq.parallel
        case 'local'
            cellfun(@MIBexp_freqanalysis, cfg1, cfg2, inputfile, outputfile);
        case 'peer'
            peercellfun(@MIBexp_freqanalysis, cfg1, cfg2, inputfile, outputfile);
        case {'torque'}
            setenv('TORQUEHOME', 'yes')  %    yes or ''
            %         ntest=20; % for testing with qsub
            %         inputfile=inputfile(1:ntest);
            %         outputfile=outputfile(1:ntest); cfg2=cfg2(1:ntest); cfg1=cfg1(1:ntest);
            cd('D:\SurpriseReplay_MEG\MEG_data\')
            switch runcfg.freq.compile
                case 'no'
                    nnodes = 64; % how many licenses?
                    stack = round(length(cfg1)/nnodes);
                    qsubcellfun(@MIBexp_freqanalysis, cfg1, cfg2, inputfile, outputfile, 'compile', 'no', ...
                        'memreq', 1024^3, 'timreq', cfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.freq.parallel);
                case 'yes'
                    compiledfun = qsubcompile(@MIBexp_freqanalysis, 'toolbox', {'signal', 'stats'});
                    qsubcellfun(compiledfun, cfg1, cfg2, inputfile, outputfile, ...
                        'memreq', 1024^3, 'timreq', cfg.timreq*60,'stack', 1, 'StopOnError', false, 'backend', runcfg.freq.parallel);
            end
        otherwise
            error('Unknown backend, aborting . . .\n')
    end
    
end % freqanalysistype

