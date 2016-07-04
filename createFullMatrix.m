
function createFullMatrix(cfg1, outputfile) %Decide what to put in argument
%Function for contructing a data matrix of all participants and all trials. 


%partDateAll            = cfg1.partlist;


%numPart = length(partDateAll);

cfg = []; %Just for freqdescriptives argument

%Define length of baseline and if trial-by-trial or average. And if basline
%separately for left and right button presses. 
% start   = -0.5;
% stop    = 0;
% trialAverage = 'average';

%Load all the meg sensors that are present in all sessions:
%load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/MEGsensors.mat');

%Keep track of all the additions to the full matrix of data. 
added=0;

%Initialize matrix
partMatrix.powsptrcm = zeros(2,267,33,121); %Different if stimulus or resp locked.
% fullMatrix.participants = partDateAll;
% for ipart = 1:numPart
    [ conTrials ] = concatenateTrials( cfg1);
    for LR = 1:2%2 %change back to 1:2, this is only while saving the data. LR buttonpress
        
        
        [allFreq] = baselineFreqMatrix(cfg1,LR,conTrials);%pd,LR,MEGsensors,start,stop,trialAverag
        avgFreq = ft_freqdescriptives(cfg,allFreq.freq);
        
        %Dont save this data again. Contstrut the full data matrix instead.
        %saveFile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/%s_BP%d_%s.mat',partDateAll{ipart}(1:3),LR,partDateAll{numPart}(5:end));
        %save(saveFile,'avgFreq')
        
        
        
        fprintf('%s average freq trial data has been saved', cfg1.session)
        
        %Store the loaded average freq data of current participant and L/R
        %in data matrix. 
        partMatrix.powsptrcm(LR,:,:,:) = avgFreq.powspctrm;
        
 
        
        clear allFreq
        
        
        added=added+1;
    end
% end
       %Need to save avgFreq somehow here. 
        save(outputfile.path,'partMatrix')

fprintf('\n\n\n\n-------Matrix containing the chosen participants has been created------\n\n\n\n-');







