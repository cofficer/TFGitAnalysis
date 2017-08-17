function [ lowLS,highLS ] = groupLoseSwitchHeuristic(~)
%create divisions between high and low switch participants. 
%



%Setting number of participants is irrelevant at this point and should
%instead just include everyone with reasonable behavioral data.
setting.numParticipants        = 29;  

%Use simulated behavior or not.
simulate = 0;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
setting.bhpath          = bhpath;
[ PLA,ATM ] = loadSessions(setting);

%Quantify lose switch tendency.
[l_switch]                     = loseSwitch(PLA, ATM, simulate);
%Quntify performance
[ performance ]                = calcPerformance( PLA,ATM, simulate);

%Median of lose switch tendency, based on the quantification. 
medianLS = quantile(l_switch(1:2:end),[0.5]);

%Participants grouped by lose switch heuristic
lowLS  = l_switch(1:2:end)<medianLS;
highLS = l_switch(1:2:end)>medianLS;
lowLS =PLA(lowLS);
highLS=PLA(highLS);


%Check the difference in performance between low and high switchers. 
perfPLA=performance(1:2:end);

perfLow =perfPLA(lowLS);
perfHigh=perfPLA(highLS);

%Median of lose switch tendency, based on the quantification. 
medianPerf = quantile(performance(1:2:end),[0.5]);

perfLowID  = performance(1:2:end)<medianPerf;
perfHighID = performance(1:2:end)>medianPerf;

perfLowID  =  PLA(perfLowID);
perfHighID =  PLA(perfHighID);

%Check lose switch tendency according to best fit parameters. Conlusion
%very similar. Commented out for now. Only diffference shifted DLa/AZi. DLa
%grouped as low ls when using parameter-based approach. 
% order
% storeLSAT
% medianLSparam = quantile(storeLSAT,[0.5]);
% 
% lowLSparam  = storeLSAT<medianLSparam;
% highLSparam = storeLSAT>medianLSparam;

end

