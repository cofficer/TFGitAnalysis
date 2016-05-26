
function [low] = baselineFreqMatrix(~)

%Script for baselining the data using percentage change. 
%%
clear all
dbstop if error
%%
cd('/Users/Christoffer/Documents/MATLAB/matchingData/JRuHigh20150819/')

highFreq    = dir('*_high*.mat');
lowFreq     = dir('*_low*.mat');

%Define the duration of the baseline. 
start       = -0.5;
stop        = 0;
figure(1),clf
hold on
for iresp   = 1:length(lowFreq)/2

   %high     =load(highFreq(iresp+1).name); 
   low      =load(lowFreq(iresp+1).name); 
   baseline =load(lowFreq(iresp).name);
   
   %Baseline trial by trial by taking the relative change.
   for itrial = 1:size(baseline.freq.powspctrm,1);
       for ifreq = 1:size(baseline.freq.powspctrm,3);
           
           %Get the indices for the timeperiod of interest to baseline
           startInd    = find(baseline.freq.time==start);
           stopInd     = find(baseline.freq.time==stop);

           %Get the baseline per TF datapoint for all timepoints 
           currFreq     =  baseline.freq.powspctrm(itrial,:,ifreq,startInd:stopInd);
          
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
           avgTOI       = repmat(avgTOI',1,size(low.freq.powspctrm,4));
           
           %Calculate the percentage change in relation to baseline. 
           low.freq.powspctrm(itrial,:,ifreq,:) = ((squeeze(low.freq.powspctrm(itrial,:,ifreq,:))-avgTOI)./avgTOI)*100;
           
           
           
       end
   end
    
    
end

%save the baselined data in 
end




%meanVals = repmat(nanmean(data(:,:,baselineTimes), 3), [1 1 size(data, 3)]);
%data = (data - meanVals) ./ meanVals;


