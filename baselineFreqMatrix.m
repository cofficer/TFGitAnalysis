
function [totalFreq] = baselineFreqMatrix(cfg1,LR,conTrials)
%partDate = particant/date session. LR = 2D-Matrix with trigger numbers
%MEGsensors, index for sensors that are common for all participants. 
%Start, stop = the timepoints of the baseline period. 
%trialAverage, shoudl denote if the baseline it to be computed on the
%average of all trials or on a trial by trial basis. 
%Script for baselining the data using percentage change. 

basePath            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/%s/%s/baseline/',cfg1.lowhigh,cfg1.session);

if strcmp(cfg1.stimResp,'stim')
    respPath            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/%s/%s/stim/',cfg1.lowhigh,cfg1.session);

elseif strcmp(cfg1.stimResp,'resp')
    respPath            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/%s/%s/resp/',cfg1.lowhigh,cfg1.session);
elseif strcmp(cfg1.stimResp,'cue')
    respPath            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/%s/%s/cue/',cfg1.lowhigh,cfg1.session);
end

load(cfg1.megsenspath);

%Change directory to path where the relevant freq is located
cd(basePath)

%Store all the filename. 
allNames            = dir('*260*.mat');

%Maybe there should be more of a security check to make sure its L/R.
if LR==1
    allNames = allNames(1:end/2);
else
    allNames = allNames((end/2)+1:end);
    
end

%Choose to baseline left or right trials. left==1. Ie which blocks to load.
%if average call concatenateTrials to get overall average baseline.
switch cfg1.trialAverage

    case 'average'
        
        %Returns all trials, then take average of the baseline period
        
        %First get the indices for the timeperiod of interest to baseline
        startInd    = find(conTrials.time==cfg1.start);
        stopInd     = find(conTrials.time==cfg1.stop);
        %Get the baseline per TF datapoint for all timepoints
        allFreq     =  conTrials.powspctrm(:,ismember(conTrials.label,MEGsensors),:,startInd:stopInd);
        
        %Average over time
        allFreq     = nanmean(allFreq,4);
        
        %Average over trials
        allFreq     = squeeze(nanmean(allFreq,1));
        
        

        
end

%Get the prestimulus baseline period freq by
%Loading all the trials for one participant. 
%and averaging the baseline together. 

for iresp   = 1:length(allNames)

    if strcmp(cfg1.stimResp,'resp')
        
        %freqInt      = load(sprintf('%s%s',basePath,allNames(iresp).name)); %load the TF data. Change back to freqPath
        freqBase         = load(sprintf('%s%s',respPath,allNames(iresp).name)); %load the baseline
        
    elseif strcmp(cfg1.stimResp,'cue')
        
        %freqInt      = load(sprintf('%s%s',basePath,allNames(iresp).name)); %load the TF data. Change back to freqPath
        freqBase         = load(sprintf('%s%s',respPath,allNames(iresp).name)); %load the baseline
    elseif strcmp(cfg1.stimResp,'stim')
        
        %freqInt      = load(sprintf('%s%s',basePath,allNames(iresp).name)); %load the TF data. Change back to freqPath
        freqBase         = load(sprintf('%s%s',respPath,allNames(iresp).name)); %load the baseline
    end

   
   %Get the index of the sensors which are present in all freq data. 
   sensorsIdx       =ismember(freqBase.freq.label,MEGsensors);
   
   %Create matrix to fill with the baselined freq data. 
   baselinedMatrix  =zeros(size(freqBase.freq.powspctrm(:,sensorsIdx,:,:)));
   
   %Baseline trial by trial by taking the relative change.
   for itrial = 1:size(freqBase.freq.powspctrm,1);
       for ifreq = 1:size(freqBase.freq.powspctrm,3);
           
           %Get the indices for the timeperiod of interest to baseline,
           %irrelevant for average
           startInd    = find(freqBase.freq.time==cfg1.start);
           stopInd     = find(freqBase.freq.time==cfg1.stop);
           
           %for the trial case avgTOI is calculated here
           switch cfg1.trialAverage
               case 'trial'
                   %Get the baseline per TF datapoint for all timepoints 
                   currFreq     =  freqBase.freq.powspctrm(itrial,sensorsIdx,ifreq,startInd:stopInd);

                   %Get the mean over all the timepoints for current TF datapoint
                   avgTOI       = nanmean(squeeze(currFreq),2);

                   %Repeat the mean over the range of timepoints for the range of
                   %interest. 
                   avgTOI       = repmat(avgTOI,1,size(freqBase.freq.powspctrm,4));
                   
                   %Calculate the percentage change in relation to baseline.
                   baselinedMatrix(itrial,:,ifreq,:) = ((squeeze(freqBase.freq.powspctrm(itrial,sensorsIdx,ifreq,:))-avgTOI)./avgTOI)*100;
               case 'average'
                   
                   %Repeat the mean over the range of timepoints for the range of
                   %interest.
                   avgTOI       = repmat(squeeze(allFreq(:,ifreq)),1,size(freqBase.freq.powspctrm,4));
                   
                   %Calculate the percentage change in relation to baseline. 
                   baselinedMatrix(itrial,:,ifreq,:) = ((squeeze(freqBase.freq.powspctrm(itrial,sensorsIdx,ifreq,:))-avgTOI)./avgTOI)*100;
           end
           
            
           
       end
   end
    
   %Add to total frequency matrix
   if iresp==1
       totalFreq.freq=freqBase.freq;
       totalFreq.freq.powspctrm=baselinedMatrix;
       totalFreq.freq.trialinfo = freqBase.freq.trialinfo;
   else
       totalFreq.freq.powspctrm=cat(1,totalFreq.freq.powspctrm,baselinedMatrix);
       totalFreq.freq.trialinfo = cat(1,totalFreq.freq.trialinfo,freqBase.freq.trialinfo);
       
   end
end

%save the baselined data in 
end




%meanVals = repmat(nanmean(data(:,:,baselineTimes), 3), [1 1 size(data, 3)]);
%data = (data - meanVals) ./ meanVals;


