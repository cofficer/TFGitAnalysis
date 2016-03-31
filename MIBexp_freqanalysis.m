function MIBexp_freqanalysis(cfg1, cfg2, inputfile, outputfile)% do freqanalysis, called by MIBexp_TFR_analysis_peersetupmkdir(fileparts(outputfile));fprintf('Loading %s\n', inputfile);try load(inputfile);    if ~isempty(cfg1.trials)        switch cfg1.phaselocktype            case {'induced' 'evoked'}            %: subtract trial average per condition! from each trial                cfg2.trials = cfg1.trials;                timelock = ft_timelockanalysis(cfg2, data); %compute ERF                switch cfg1.phaselocktype                    case 'induced'                        for itrial = cfg2.trials'                            fprintf('Subtracting ERF for trial %d\n', itrial)                            startind = find(~timelock.time) - find(~data.time{itrial}) + 1; % start ind of trial in timelock.time indices                            endind   = find(~timelock.time) + length(data.time{itrial}) - find(~data.time{itrial}) ; % timeindices: timelock_t=0 + last_sample_data - data_t=0 % select indices of timebins present in itrial                            data.trial{itrial} = data.trial{itrial} - timelock.avg(:,startind:endind); % subtract ERP from available total signal bins                        end                    case 'evoked'                        data.trial = {timelock.avg};   %prepare freqanalysis on the average trial                        data.time = {timelock.time};                        cfg1.trials = 'all'; %only 1 trial left                end %case {'induced' 'evoked'}        end %case 'totalpow': straight to freqanalysis!                %         switch ft_senstype(freq.label)        %                     case 'ctf275'        if cfg1.sourceloc == 0            cfg_pn = [];            cfg_pn.method = 'distance';            %                 cfg_pn.template = 'C:\Users\Thomas Meindertsma\Documents\MATLAB\CTF275_neighb.mat'            %                 cfg_pn.template = 'CTF275_neighb'            cfg_pn.channel = 'MEG';                        cfg_mp.planarmethod = 'sincos';            cfg_mp.trials = 'all';            cfg_mp.channel = 'MEG';            cfg_mp.neighbours = ft_prepare_neighbours(cfg_pn, data);            data = ft_megplanar(cfg_mp, data);                    end        %         end                if cfg1.sourceloc            cfg1.method = 'mtmfft';            cfg1.output = 'powandcsd';            cfg1.tapsmofrq = 2;            cfg1.foilim = [12 30];            cfg1.channelcmb = 'all';            source_freq = ft_freqanalysis(cfg1, data);        else            cfg1.pad            cfg1.pad=5;            freq = ft_freqanalysis(cfg1, data);                        % combine longitude and latitude planar sensors            switch ft_senstype(freq.label)                case 'neuromag306'                    cfg=[];                    cfg.trials = 'all';                    freq = ft_combineplanar(cfg, freq);                case 'ctf275_planar'                    cfg_cp.trials = 'all';                    freq_cp = ft_combineplanar(cfg_cp, freq);                    freq_cp.grad = freq.grad;                    freq = freq_cp            end        end                ettrials = find((data.trialinfo(:,1)==cfg1.itype) & (data.trialinfo(:,2)==cfg1.ievent));        taxis = -1.71:0.002:1.71;        etdat = NaN(length(ettrials),1711);        for i = 1:length(ettrials)%             etdat{i} = data.trial{ettrials(i)}(543:545,:);%             startind = find(taxis == data.time{ettrials(i)}(1));            startind = find((taxis - data.time{ettrials(i)}(1))<0.00001);            endind = startind + length(data.time{ettrials(i)}) -1;            etdat(i,startind:endind) = data.trial{ettrials(i)}(545,:);            if min(etdat(i,startind:endind)) == 0 && max(etdat(i,startind:endind)) == 0                etdat(i,startind:endind) = NaN;            end        end        freq.etdat = etdat;                % save freq struct        if cfg1.runMIBmegcfg.append_et            [pathstr, name] = fileparts(outputfile);            name = [name, '_appended'];            outputfile = fullfile(pathstr, name);            fprintf('Saving %s to...\n %s\n', name, pathstr)            save(outputfile, 'freq');            clear all        else            [pathstr, name] = fileparts(outputfile);            fprintf('Saving %s to...\n %s\n', name, pathstr)            save(outputfile, 'freq');            clear all        end    else        warning('Condition not present in data\n')        return    endcatch ME    disp(getReport(ME))    fid = fopen('/home/chrisgahn/MIBexp_freq_errorlog.txt', 'at');    fprintf(fid,'%s\n%s\n%s\n\n\n', datestr(now), inputfile, getReport(ME));    fclose('all');end