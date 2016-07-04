%Parallel baselining on the cluster.

%Create cfgs, one cell per participant. Might as well include all the 
%Parameters like start stop, response or stimulus locked data. Baselined
%trial by trial or averaged. 

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
                          'MAm/20150825'
                          'MAb/20150816'
  }; 
                      
                      
runcfg.baseline.compile = 'local';                                  
                      
                      
for ipart = 1:length(runcfg.partlist)    
    
                      
       cfg1{ipart}.start        = -0.5;
       cfg1{ipart}.stop         =  0;
       cfg1{ipart}.trialAverage = 'average'; %baseline each trial or avg.                
       cfg1{ipart}.session      = runcfg.partlist{ipart};               
       cfg1{ipart}.megsenspath  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/MEGsensors.mat';               
       cfg1{ipart}.preprocFreq  = 'freq'; %concatenate TF or preproc trials             
       
       cfg1{ipart}.stimResp     = 'resp'; %Do the baseline for stimulus period or for response? 
       cfg1{ipart}.lowhigh      = 'low';  %low or high frequencies
       outputfile{ipart}.path   = sprintf ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedResp/%s.mat'...
                                           ,strrep(runcfg.partlist{ipart},'/','_') );
             
                      
end          



switch runcfg.baseline.compile
    
    case 'local'
        createFullMatrix(cfg1{1},outputfile{1})
        %cellfun(@McreatFullMAtrix, cfg1, outputfile);
    case 'no'
        nnodes = 1;%64; % how many licenses?
        stack = 1;%round(length(cfg1)/nnodes);
        qsubcellfun(@createFullMatrix, cfg1, 'compile', 'no', ...
            'memreq', 1024^3, 'timreq', cfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.freq.parallel);
    case 'yes'
        compiledfun = qsubcompile(@MatchingExp_freqanalysis, 'toolbox', {'signal', 'stats'});
        qsubcellfun(compiledfun, cfg1, cfg2, inputfile, outputfile, ...
            'memreq', 1024^3, 'timreq', cfg.timreq*60,'stack', 1, 'StopOnError', false, 'backend', runcfg.freq.parallel);
end



























