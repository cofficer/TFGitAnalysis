
%Script for contructing a data matrix of all participants and all trials. 

%Loop over participants
%Loop over left/right
%Loop over sessions?
%%
dbstop if error
%clear all
%%
%Participants:
warning off

partDate269            = {'AWi/20151007','SBa/20151006','JHo/20151004','JFo/20151007'... 
                          'AMe/20151008','SKo/20151011','JBo/20151011','DWe/20151003'...
                          'FSr/20151003','JNe/20151004','RWi/20151003','HJu/20151004'...
                          'LJa/20151006','BFu/20151010','EIv/20151003'};
partDate268            = {'MGo/20150815','JRi/20150828','HRi/20150816','AZi/20150818'...
                          'MTo/20150825','DLa/20150826','BPe/20150826','ROr/20150827'...
                          'HEn/20150828','MSo/20150820'}; %One channel less.

partDateAll            = [partDate269 partDate268]; %insert partDate269

partDateAll            = {'AWi/20151007'};

numPart = length(partDateAll);

cfg = [];

%Define length of baseline and if trial-by-trial or average.
start   = -0.5;
stop    = 1;
trialAverage = 'average';

%Load all the meg sensors that are present in all sessions:
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/MEGsensors.mat');

%Keep track of all the additions to the full matrix of data. 
added=0;

%Initialize matrix
fullMatrix.powsptrcm = zeros(numPart,2,267,33,141); 
fullMatrix.participants = partDateAll;
for ipart = 1:numPart
    for LR = 1:2%2 %change back to 1:2, this is only while saving the data. LR buttonpress
        
        pd = partDateAll{ipart};
        [allFreq] = baselineFreqMatrix(pd,LR,MEGsensors,start,stop,trialAverage);
        avgFreq = ft_freqdescriptives(cfg,allFreq.freq);
        
        %Dont save this data again. Contstrut the full data matrix instead.
        %saveFile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/%s_BP%d_%s.mat',partDateAll{ipart}(1:3),LR,partDateAll{numPart}(5:end));
        %save(saveFile,'avgFreq')
        
        fprintf('%s average freq trial data has been saved', partDateAll{ipart})
        
        %Store the loaded average freq data of current participant and L/R
        %in data matrix. 
        fullMatrix.powsptrcm(ipart,LR,:,:,:) = avgFreq.powspctrm;
        
        clear allFreq
        
        
        added=added+1;
    end
end

fprintf('\n\n\n\n-------Matrix containing the chosen participants has been created------\n\n\n\n-');


%%
%Get the grand average

% cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq');
% 
% allFreqs        = dir('*BP2*.mat');
% 
% 
% for ifreq = 1:length(allFreqs)
%     
%     allAvg.(allFreqs(ifreq).name(1:3)) = load(allFreqs(ifreq).name);
%     
%     
%     
% end
% 
% cfg      = [];
% grandavg = ft_freqgrandaverage(cfg, allAvg.AMe.avgFreq,allAvg.AWi.avgFreq,allAvg.AZi.avgFreq,allAvg.BPe.avgFreq,allAvg.DLa.avgFreq,allAvg.DWe.avgFreq,allAvg.FSr.avgFreq,allAvg.HJu.avgFreq,allAvg.HRi.avgFreq,allAvg.JBo.avgFreq,allAvg.JFo.avgFreq,allAvg.JHo.avgFreq,allAvg.JNe.avgFreq,allAvg.JRi.avgFreq,allAvg.LJa.avgFreq,allAvg.MGo.avgFreq,allAvg.MTo.avgFreq,allAvg.ROr.avgFreq,allAvg.RWi.avgFreq,allAvg.SBa.avgFreq,allAvg.SKo.avgFreq) ;






