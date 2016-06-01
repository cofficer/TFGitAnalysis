
%Script for contructing a data matrix of all participants and all trials. 

%Loop over participants
%Loop over left/right
%Loop over sessions?
%%
dbstop if error
clear all
%%
%Participants:

partDate269            = {'AWi/20151007','SBa/20151006','JHo/20151004','JFo/20151007','AMe/20151008','SKo/20151011','JBo/20151011'};%
partDate268            = {'JRi/20150828'}; %One channel less.

numPart = length(partDate269);

cfg = [];

%Keep track of all the additions to the full matrix of data. 
added=0;

%Initialize matrix
fullMatrix.powsptrcm = zeros(numPart,2,269,33,141);
fullMatrix.participants = partDate269;
for ipart = 1:numPart
    for LR = 1:2
        
        pd = partDate269{ipart};
        [allFreq] = baselineFreqMatrix(pd,LR);
        avgFreq = ft_freqdescriptives(cfg,allFreq.freq);
        
        fullMatrix.powsptrcm(ipart,LR,:,:,:) = avgFreq.powspctrm;
        clear allFreq
        
        
        added=added+1;
    end
end







