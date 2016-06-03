
%Script for contructing a data matrix of all participants and all trials. 

%Loop over participants
%Loop over left/right
%Loop over sessions?
%%
dbstop if error
clear all
%%
%Participants:

partDate269            = {'AWi/20151007','SBa/20151006','JHo/20151004','JFo/20151007'... 
                         'AMe/20151008','SKo/20151011','JBo/20151011'...
                         'DWe/20151003','FSr/20151003'...
                         'JNe/20151004','RWi/20151003','HJu/20151004','LJa/20151006'};%
partDate268            = {'MGo/20150815','JRi/20150828','HRi/20150816','AZi/20150818','MTo/20150825'...
                          'DLa/20150826','BPe/20150826','ROr/20150827'}; %One channel less.



%solo participant
%partDate269            = {'SBa/20151006'};

numPart = length(partDate268);

cfg = [];

%Keep track of all the additions to the full matrix of data. 
added=0;

%Initialize matrix
fullMatrix.powsptrcm = zeros(numPart,2,268,33,141);
fullMatrix.participants = partDate268;
for ipart = 1:numPart
    for LR = 1:2
        
        pd = partDate268{ipart};
        [allFreq] = baselineFreqMatrix(pd,LR);
        avgFreq = ft_freqdescriptives(cfg,allFreq.freq);
        
        fullMatrix.powsptrcm(ipart,LR,:,:,:) = avgFreq.powspctrm;
        clear allFreq
        
        
        added=added+1;
    end
end

fprintf('\n\n\n\n-------Matrix containing the chosen participants has been created------\n\n\n\n-');





