
function [allFreq] = baselineFreqMatrix(lowhigh)

%Script for baselining the data using percentage change. 
%%
clear all
dbstop if error
%%
%cd('/Users/Christoffer/Documents/MATLAB/matchingData/JRuHigh20150819/')

lowhigh             = 'low';   

basePath            = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/SBa/20151006/baseline/';

freqPath            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/%s/SBa/20151006/resp/',lowhigh);

cd(freqPath)

allNames            = dir('*.mat');

%Define the duration of the baseline. 
start       = -0.5;
stop        = 0;
%figure(1),clf
%hold on

%Create matrix for all the blocks.


for iresp   = 1:length(allNames)/2

    
   
   freqInt      = load(sprintf('%s%s',basePath,allNames(iresp).name)); %load the TF data. Change back to freqPath
   freqBase     = load(sprintf('%s%s',basePath,allNames(iresp).name)); %load the baseline
   

   
   
   
   %Baseline trial by trial by taking the relative change.
   for itrial = 1:size(freqBase.freq.powspctrm,1);
       for ifreq = 1:size(freqBase.freq.powspctrm,3);
           
           %Get the indices for the timeperiod of interest to baseline
           startInd    = find(freqBase.freq.time==start);
           stopInd     = find(freqBase.freq.time==stop);

           %Get the baseline per TF datapoint for all timepoints 
           currFreq     =  freqBase.freq.powspctrm(itrial,:,ifreq,startInd:stopInd);
          
           %Get the mean over all the timepoints for current TF datapoint
           avgTOI       = nanmean(currFreq,4);
           
           %For each trial plot the average baseline and average resp
%            %activity
%            if ifreq==10
%            plot(itrial,nanmean(avgTOI),'r*','markers',20);
%            plot(itrial,nanmean(squeeze(low.freq.powspctrm(itrial,:,ifreq,1))),'b*','markers',20)
%            end
           %Repeat the mean over the range of timepoints for the range of
           %interest. 
           avgTOI       = repmat(avgTOI',1,size(freqInt.freq.powspctrm,4));
           
           %Calculate the percentage change in relation to baseline. 
           freqInt.freq.powspctrm(itrial,:,ifreq,:) = ((squeeze(freqInt.freq.powspctrm(itrial,:,ifreq,:))-avgTOI)./avgTOI)*100;
           
           
           
       end
   end
    
%Add to total frequency matrix
if iresp==1
allFreq.freq=freqInt.freq;
else
    allFreq.freq.powspctrm=cat(1,allFreq.freq.powspctrm,freqInt.freq.powspctrm);
end
end

%save the baselined data in 
end




%meanVals = repmat(nanmean(data(:,:,baselineTimes), 3), [1 1 size(data, 3)]);
%data = (data - meanVals) ./ meanVals;


