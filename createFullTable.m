%Create the full table of all participants.

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel')

%If you load a full table then no reason run the 2nd cell.
load('fullTable24Nov-2.mat')
%load('fullTable28hOct.mat')
%load('allFracIncome.mat')
%load('AllprobChoice3-1002-17.mat')
load('AllprobChoice2-1203-17.mat')


%%
%loop participants to create a table based on trialinfos, this cell is
%

%Can usually skip this part since the general table has already been
%created. 
creaTable = 0;

if creaTable
    
    bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
    
    
    %Getting the names of the mat files that store behavioral data.
    setting.numParticipants = 29;
    setting.bhpath          = bhpath;
    
    [PLA,ATM] = loadSessions(setting);
    
    
    folder = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/';
    
    for nPart = 1:length(PLA)
        nPart
        
        folderP = sprintf('%s%s/',folder,PLA{nPart}(1:3));
        
        
        cd(folderP)
        
        %name of the date folder inside of each participant.
        aD=dir;
        aD=aD(3).name;
        
        folderP = sprintf('%s%s/resp',folderP,aD);
        
        cd(folderP)
        
        sessions = dir('*260_type1event1*.mat');
        
        
        for blocks = 1:length(sessions)
            
            pathA = sessions(blocks).name;
            
            [ T ] = tableTrialinfo( pathA );
            
            if blocks == 1
                TAll = T;
            else
                TAll = [TAll;T];
            end
            
        end
        
        %Add column with the total trials of one session
        totalTrials  = 1:length(TAll.cue_trigger);
        TAll.totalTrials = totalTrials';
        
        if nPart == 1
            Ttotal = TAll;
        else
            Ttotal = [Ttotal;TAll];
        end
        
        
        
    end
end

%%
%Figure out if there is a match between the model trials and table.
%Adding the probability of choice (LFI) to the precise positions in the
%table. 
ID = Ttotal.ID;
ID = cellstr(ID);

%Store all lfi value to be inserted
LocalProbChoice = zeros(1,length(Ttotal.cue_trigger));
%Make one for each LFI and PC
LocalFract1 = zeros(1,length(Ttotal.cue_trigger));
LocalFract2 = zeros(1,length(Ttotal.cue_trigger));
LocalFract3 = zeros(1,length(Ttotal.cue_trigger));

ProbChoice2 = zeros(1,length(Ttotal.cue_trigger));
ProbChoice3 = zeros(1,length(Ttotal.cue_trigger));


correct=1;

%skip JRu, part 20, and MGo 24, should already not be there in probchoice3
lenParts = 1:length(AllprobChoice.order);
%The two participants MGo and JRu are already skipped.
%lenParts(20)=[]; 
%lenParts(23)=[];


%Loop over participants.
for nPart = 1:length(AllprobChoice.order)%1:length(AllprobChoice.order);

 %Find the position of the current participant, but its not LME.   
 if nPart ==21
     cmpID=strncmp('LME',ID,3);
 else
     cmpID=strncmp(AllprobChoice.order{nPart}(1:3),ID,3);
 end
 
[posID,~] = find(cmpID==1);

%TF trialinfo
ta = Ttotal(posID,:);
%Model trialinfo
%AllprobChoice.BFu
%trial number TF data reset by new dataset
%ta.totalTrials

%Compare choices
behavChoices = AllprobChoice.(AllprobChoice.order{nPart}(1:3));
behavChoices = behavChoices(:,7);
behavChoices = behavChoices(behavChoices>0);

%Get all choices from the participant specific table. 20+ means real
%response
TFChoices     = ta.resp_type(ta.resp_type>19);

%1 is horizontal choice, 2 is vertical choice
%Removal of left/right info, retaining hor/ver
indH = find(TFChoices==21);
TFChoices(indH) = 1;
indH = find(TFChoices==23);
TFChoices(indH) = 1;
indV = find(TFChoices==20);
TFChoices(indV) = 2;
indV = find(TFChoices==22);
TFChoices(indV) = 2;
% 
% 
% figure(1),clf
% hold on;
% plot(TFChoices-0.5,'r')
% plot(behavChoices,'k')
% ylim([-2 3])
%pause
%Storing the length of trial, which is not relevant.
tableT = length(posID);
modelT =length(AllprobChoice.PC3{nPart});

%subtract the number of incorrect buttonpresses from the number of trials.
tableT = tableT-sum(Ttotal.resp_type(posID)<20);

%Find the position of all the button presses for current participant. Both
%correct p and incorrect pN
[p,a]  =find(Ttotal.resp_type(posID)>=20);
[pN,a] =find(Ttotal.resp_type(posID)<20);



%compare if the number of trials in trialinfo overlaps with model
if tableT == modelT
    sprintf('Correct trials for: %s',AllprobChoice.order{nPart}(1:3))
    correct=correct+1;
    
    %insert LFI and PC
    LocalProbChoice(posID(p))     = AllprobChoice.PC3{nPart}'; %Redundant soon .
    LocalProbChoice(posID(pN))    = NaN;
    
    %New measuremets of LFI and PC
    LocalFract1(posID(p))     = AllprobChoice.LFI1{nPart}';
    LocalFract1(posID(pN))    = NaN;
    LocalFract2(posID(p))     = AllprobChoice.LFI2{nPart}';
    LocalFract2(posID(pN))    = NaN;
    LocalFract3(posID(p))     = AllprobChoice.LFI3{nPart}';
    LocalFract3(posID(pN))    = NaN;
    
    ProbChoice2(posID(p))     = AllprobChoice.PC2{nPart}';
    ProbChoice2(posID(pN))    = NaN;
    ProbChoice3(posID(p))     = AllprobChoice.PC3{nPart}';
    ProbChoice3(posID(pN))    = NaN;
    
    
    
else
    sprintf('Wrong number of trials for: %s, modelT=%d, tableT=%d',...
        AllprobChoice.order{nPart}(1:3),modelT,tableT)
    
    
    if ta.trialN(1) ~=1 && ta.trialN(1) ~=7 %The 7 is only for HEn
        %Extend TFChoices so that it is the same length as all behav choices.
        
        if strcmp(AllprobChoice.order{nPart}(1:3),'JHa');
            pad0 = zeros(1,ta.trialN(1)+16)';
        else
            pad0 = zeros(1,ta.trialN(1)-1)';
        end
        %find peaks to see if more padding is necessary
        [pks,loc] = findpeaks(ta.trialN');
        
        %Only set for one peak
        if length(loc)>0
            
            %Complicated, tuned for nPart = 5.
            pad1 = zeros(1,ta.trialN(loc+1)-2)';
            
            TFChoices = [pad0;TFChoices(1:loc);pad1;TFChoices(loc+1:end)];
            
            %Store all LFIs
            %localFI = AllprobChoice.LFI{nPart}';
            %Add all the alternative PC.
            LF1 = AllprobChoice.LFI1{nPart}';
            LF2 = AllprobChoice.LFI2{nPart}';
            LF3 = AllprobChoice.LFI3{nPart}';
            PC2 = AllprobChoice.PC2{nPart}';
            PC3 = AllprobChoice.PC3{nPart}';
            
            %Exctract only the lfi where the two choice sets overlap.
            %localFI(TFChoices==0) = NaN;
            
            %Add all the alternative PC.
            LF1(TFChoices==0) = NaN;
            LF2(TFChoices==0) = NaN;
            LF3(TFChoices==0) = NaN;
            PC2(TFChoices==0) = NaN;
            PC3(TFChoices==0) = NaN;
            
            %Now add the relevant fractional income to the full vector
            %LocalProbChoice(posID(p))     = localFI(TFChoices>0);
            %LocalProbChoice(posID(pN))    = NaN;
            
            
            %New measuremets of LFI and PC
            LocalFract1(posID(p))     = LF1(TFChoices>0);
            LocalFract1(posID(pN))    = NaN;
            LocalFract2(posID(p))     = LF2(TFChoices>0);
            LocalFract2(posID(pN))    = NaN;
            LocalFract3(posID(p))     = LF3(TFChoices>0);
            LocalFract3(posID(pN))    = NaN;
            
            ProbChoice2(posID(p))     = PC2(TFChoices>0);
            ProbChoice2(posID(pN))    = NaN;
            ProbChoice3(posID(p))     = PC3(TFChoices>0);
            ProbChoice3(posID(pN))    = NaN;
            
            
        else
            
            TFChoices = [pad0;TFChoices];
        end
    elseif strcmp(AllprobChoice.order{nPart}(1:3),'HEn'); %Only for participant HEn
        
        [pks,loc] = findpeaks(ta.trialN');
        
        pad0 = zeros(1,ta.trialN(loc+1)-1)';
        
        TFChoices=[TFChoices(1:loc);pad0;TFChoices(loc+1:end)];
        
        %Store all LFIs
        %localFI = AllprobChoice.LFI{nPart}';
        %Add all the alternative PC.
        LF1 = AllprobChoice.LFI1{nPart}';
        LF2 = AllprobChoice.LFI2{nPart}';
        LF3 = AllprobChoice.LFI3{nPart}';
        PC2 = AllprobChoice.PC2{nPart}';
        PC3 = AllprobChoice.PC3{nPart}';
        
        %Exctract only the lfi where the two choice sets overlap.
        %localFI(TFChoices==0) = NaN;
        
        %Add all the alternative PC.
        LF1(TFChoices==0) = NaN;
        LF2(TFChoices==0) = NaN;
        LF3(TFChoices==0) = NaN;
        PC2(TFChoices==0) = NaN;
        PC3(TFChoices==0) = NaN;
        
        %Now add the relevant fractional income to the full vector
        %LocalProbChoice(posID(p))     = localFI(TFChoices>0);
        %LocalProbChoice(posID(pN))    = NaN;
        
        
        %New measuremets of LFI and PC
        LocalFract1(posID(p))     = LF1(TFChoices>0);
        LocalFract1(posID(pN))    = NaN;
        LocalFract2(posID(p))     = LF2(TFChoices>0);
        LocalFract2(posID(pN))    = NaN;
        LocalFract3(posID(p))     = LF3(TFChoices>0);
        LocalFract3(posID(pN))    = NaN;
        
        ProbChoice2(posID(p))     = PC2(TFChoices>0);
        ProbChoice2(posID(pN))    = NaN;
        ProbChoice3(posID(p))     = PC3(TFChoices>0);
        ProbChoice3(posID(pN))    = NaN;
        
        
        
        
        
    elseif strcmp(AllprobChoice.order{nPart}(1:3),'BFu'); %Only for participant HEn
        
        %[pks,loc] = findpeaks(ta.trialN');
        
        %calculate number of missing trials. 
        pad0 = zeros(1,length(behavChoices)-length(TFChoices));
        
        %Insert dummy trials between actual trials. Hardcoded/22nov '16.
        TFChoices=[TFChoices(1:285)' pad0 TFChoices(286:end)']';
        
        %Store all LFIs
        %localFI = AllprobChoice.LFI{nPart}';
        %Add all the alternative PC.
        LF1 = AllprobChoice.LFI1{nPart}';
        LF2 = AllprobChoice.LFI2{nPart}';
        LF3 = AllprobChoice.LFI3{nPart}';
        PC2 = AllprobChoice.PC2{nPart}';
        PC3 = AllprobChoice.PC3{nPart}';
        
        %Exctract only the lfi where the two choice sets overlap.
        %localFI(TFChoices==0) = NaN;
        
        %Add all the alternative PC.
        LF1(TFChoices==0) = NaN;
        LF2(TFChoices==0) = NaN;
        LF3(TFChoices==0) = NaN;
        PC2(TFChoices==0) = NaN;
        PC3(TFChoices==0) = NaN;
        
        %Now add the relevant fractional income to the full vector
        %LocalProbChoice(posID(p))     = localFI(TFChoices>0);
        %LocalProbChoice(posID(pN))    = NaN;
        
        
        %New measuremets of LFI and PC
        LocalFract1(posID(p))     = LF1(TFChoices>0);
        LocalFract1(posID(pN))    = NaN;
        LocalFract2(posID(p))     = LF2(TFChoices>0);
        LocalFract2(posID(pN))    = NaN;
        LocalFract3(posID(p))     = LF3(TFChoices>0);
        LocalFract3(posID(pN))    = NaN;
        
        ProbChoice2(posID(p))     = PC2(TFChoices>0);
        ProbChoice2(posID(pN))    = NaN;
        ProbChoice3(posID(p))     = PC3(TFChoices>0);
        ProbChoice3(posID(pN))    = NaN;
        
    elseif strcmp(AllprobChoice.order{nPart}(1:3),'DWe'); %Only for participant HEn
        
        [pks,loc] = findpeaks(ta.trialN');
        
        %calculate number of missing trials.
        pad0 = zeros(1,length(behavChoices)-length(TFChoices));
        
        %Insert dummy trials between actual trials. Hardcoded/22nov '16.
        TFChoices=[pad0 TFChoices']';
        
        %Store all LFIs
        %localFI = AllprobChoice.LFI{nPart}';
        %Add all the alternative PC.
        LF1 = AllprobChoice.LFI1{nPart}';
        LF2 = AllprobChoice.LFI2{nPart}';
        LF3 = AllprobChoice.LFI3{nPart}';
        PC2 = AllprobChoice.PC2{nPart}';
        PC3 = AllprobChoice.PC3{nPart}';
        
        %Not sure why whole of DWe is NaN
        %Exctract only the lfi where the two choice sets overlap.
        %localFI(TFChoices==0) = NaN;
        
        %Add all the alternative PC.
        LF1(TFChoices==0) = NaN;
        LF2(TFChoices==0) = NaN;
        LF3(TFChoices==0) = NaN;
        PC2(TFChoices==0) = NaN;
        PC3(TFChoices==0) = NaN;
        
        %Now add the relevant fractional income to the full vector
        %LocalProbChoice(posID(p))     = NaN;
        %LocalProbChoice(posID(pN))    = NaN;
        
        
        %New measuremets of LFI and PC
        LocalFract1(posID(p))     = NaN;
        LocalFract1(posID(pN))    = NaN;
        LocalFract2(posID(p))     = NaN;
        LocalFract2(posID(pN))    = NaN;
        LocalFract3(posID(p))     = NaN;
        LocalFract3(posID(pN))    = NaN;
        
        ProbChoice2(posID(p))     = NaN;
        ProbChoice2(posID(pN))    = NaN;
        ProbChoice3(posID(p))     = NaN;
        ProbChoice3(posID(pN))    = NaN;
        
   elseif strcmp(AllprobChoice.order{nPart}(1:3),'HRi'); %Only for participant HEn
        
        [pks,loc] = findpeaks(ta.trialN');
        
        %calculate number of missing trials.
        pad0 = zeros(1,length(behavChoices)-length(TFChoices));
        
        %Insert dummy trials between actual trials. Hardcoded/22nov '16.
        TFChoices=[TFChoices(1:396)' pad0 TFChoices(397:end)']';
        
        %Store all LFIs
        %localFI = AllprobChoice.LFI{nPart}';
        %Add all the alternative PC.
        LF1 = AllprobChoice.LFI1{nPart}';
        LF2 = AllprobChoice.LFI2{nPart}';
        LF3 = AllprobChoice.LFI3{nPart}';
        PC2 = AllprobChoice.PC2{nPart}';
        PC3 = AllprobChoice.PC3{nPart}';
        
        %Exctract only the lfi where the two choice sets overlap.
        %localFI(TFChoices==0) = NaN;
        
        %Add all the alternative PC.
        LF1(TFChoices==0) = NaN;
        LF2(TFChoices==0) = NaN;
        LF3(TFChoices==0) = NaN;
        PC2(TFChoices==0) = NaN;
        PC3(TFChoices==0) = NaN;
        
        %Now add the relevant fractional income to the full vector
        %LocalProbChoice(posID(p))     = localFI(TFChoices>0);
        %LocalProbChoice(posID(pN))    = NaN;
        
        
        %New measuremets of LFI and PC
        LocalFract1(posID(p))     = LF1(TFChoices>0);
        LocalFract1(posID(pN))    = NaN;
        LocalFract2(posID(p))     = LF2(TFChoices>0);
        LocalFract2(posID(pN))    = NaN;
        LocalFract3(posID(p))     = LF3(TFChoices>0);
        LocalFract3(posID(pN))    = NaN;
        
        ProbChoice2(posID(p))     = PC2(TFChoices>0);
        ProbChoice2(posID(pN))    = NaN;
        ProbChoice3(posID(p))     = PC3(TFChoices>0);
        ProbChoice3(posID(pN))    = NaN;
        
        
   elseif strcmp(AllprobChoice.order{nPart}(1:3),'LMe'); %Only for participant HEn
        
        %[pks,loc] = findpeaks(ta.trialN');
        
        %calculate number of missing trials.
        pad0 = zeros(1,length(behavChoices)-length(TFChoices));
        
        %Insert dummy trials between actual trials. Hardcoded/22nov '16.
        TFChoices=[TFChoices(1:209)' pad0 TFChoices(210:end)']';
        
        %Store all LFIs
        %localFI = AllprobChoice.LFI{nPart}';
        %Add all the alternative PC.
        LF1 = AllprobChoice.LFI1{nPart}';
        LF2 = AllprobChoice.LFI2{nPart}';
        LF3 = AllprobChoice.LFI3{nPart}';
        PC2 = AllprobChoice.PC2{nPart}';
        PC3 = AllprobChoice.PC3{nPart}';
        
        %Exctract only the lfi where the two choice sets overlap.
        %localFI(TFChoices==0) = NaN;
        
        %Add all the alternative PC.
        LF1(TFChoices==0) = NaN;
        LF2(TFChoices==0) = NaN;
        LF3(TFChoices==0) = NaN;
        PC2(TFChoices==0) = NaN;
        PC3(TFChoices==0) = NaN;
        
        %Now add the relevant fractional income to the full vector
        %LocalProbChoice(posID(p))     = localFI(TFChoices>0);
        %LocalProbChoice(posID(pN))    = NaN;
        
        
        %New measuremets of LFI and PC
        LocalFract1(posID(p))     = LF1(TFChoices>0);
        LocalFract1(posID(pN))    = NaN;
        LocalFract2(posID(p))     = LF2(TFChoices>0);
        LocalFract2(posID(pN))    = NaN;
        LocalFract3(posID(p))     = LF3(TFChoices>0);
        LocalFract3(posID(pN))    = NaN;
        
        ProbChoice2(posID(p))     = PC2(TFChoices>0);
        ProbChoice2(posID(pN))    = NaN;
        ProbChoice3(posID(p))     = PC3(TFChoices>0);
        ProbChoice3(posID(pN))    = NaN;
        
    else
        %Extend TFChoices so that it is the same length as all behav choices.
        TFChoices(length(TFChoices)+1:length(behavChoices))=0;
        
        
        %Store all LFIs
        %Add all the alternative PC.
        LF1 = AllprobChoice.LFI1{nPart}';
        LF2 = AllprobChoice.LFI2{nPart}';
        LF3 = AllprobChoice.LFI3{nPart}';
        PC2 = AllprobChoice.PC2{nPart}';
        PC3 = AllprobChoice.PC3{nPart}';
        
        %Exctract only the lfi where the two choice sets overlap.
        %localFI(TFChoices==0) = NaN;
        
        %Add all the alternative PC.
        LF1(TFChoices==0) = NaN;
        LF2(TFChoices==0) = NaN;
        LF3(TFChoices==0) = NaN;
        PC2(TFChoices==0) = NaN;
        PC3(TFChoices==0) = NaN;
        
        %Now add the relevant fractional income to the full vector
        %LocalProbChoice(posID(p))     = localFI(TFChoices>0);
        %LocalProbChoice(posID(pN))    = NaN;
        
        
        %New measuremets of LFI and PC
        LocalFract1(posID(p))     = LF1(TFChoices>0);
        LocalFract1(posID(pN))    = NaN;
        LocalFract2(posID(p))     = LF2(TFChoices>0);
        LocalFract2(posID(pN))    = NaN;
        LocalFract3(posID(p))     = LF3(TFChoices>0);
        LocalFract3(posID(pN))    = NaN;
        
        ProbChoice2(posID(p))     = PC2(TFChoices>0);
        ProbChoice2(posID(pN))    = NaN;
        ProbChoice3(posID(p))     = PC3(TFChoices>0);
        ProbChoice3(posID(pN))    = NaN;

        
        
    end
    %Find indices where both vectors are the same. Currently it could be
    %only by coincidence.
    %indOverlap = find(TFChoices==behavChoices);
    
    %Find the deviating positions
    
    
    %In sessons without matching trials just place NaNs for now
    %LocalFractionalIncome(posID)        = NaN;
end
% 
% figure(1),clf
% hold on;
% plot(TFChoices-0.5,'r')
% plot(behavChoices,'k')
% ylim([-2 3])
% pause


end

%Ttotal.LocalProbChoice = LocalProbChoice';
Ttotal.LocalFract1     = LocalFract1';
Ttotal.LocalFract2     = LocalFract2';
Ttotal.LocalFract3     = LocalFract3';
Ttotal.ProbChoice2     = ProbChoice2';
Ttotal.ProbChoice3     = ProbChoice3';
        


%Issue with LME session. 
a=find(Ttotal.LocalFract1==0);
%Ttotal.LocalProbChoice(a,:) = NaN;
Ttotal.LocalFract1(a,:) = NaN;
Ttotal.LocalFract2(a,:) = NaN;
Ttotal.LocalFract3(a,:) = NaN;
Ttotal.ProbChoice2(a,:) = NaN;
Ttotal.ProbChoice3(a,:) = NaN;



%%
%Find out the different local fractional income bins from table
%Start finding equal bin of LFI

LFIs  = Ttotal.LocalFract1(~isnan(Ttotal.LocalFract1'));

histfit(LFIs) %plots the distribution of local fractional incomes

%partitions the LFI in four equal parts.
y=quantile(LFIs,[0 0.25 0.5 0.75 1]);


ceilLFI = Ttotal(Ttotal.LocalFract1>=y(4),:);

highLFI = Ttotal(y(4)>Ttotal.LocalFract1 & Ttotal.LocalFract1>=y(3),:);

mediumLFI = Ttotal(y(3)>Ttotal.LocalFract1 & Ttotal.LocalFract1>=y(2),:);

lowLFI = Ttotal(y(2)>Ttotal.LocalFract1 & Ttotal.LocalFract1>=y(1),:);

%%
%select ceilLFI and average 
%Include only the relevant sensors. 
%Get sensors for each sensor group:
sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
         'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
         'MRF54','MRF55','MRF56','MRF66','MRF46'};
sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
         'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
         'MLF54','MLF55','MLF56','MLF66','MLF46'};
resp=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/AWi/20151007/baseline/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');


[~,idxR]=intersect(resp.freq.grad.label,sensR);
[~,idxL]=intersect(resp.freq.grad.label,sensL);
idxLR = [idxL idxR];

%Preallocate fields
avgAFreq.low    = [];
avgAFreq.medium = [];
avgAFreq.high   = [];
avgAFreq.ceil   = [];

fnames = fieldnames(avgAFreq);

for LFIbins = 1:length(fnames)
    
    %Select trial based on local fractional income from time-frequency data.
    switch LFIbins
        case 1            
            [ BP ] = selectLFI( lowLFI,Ttotal, idxLR);
        case 2
            [ BP ] = selectLFI( mediumLFI,Ttotal, idxLR);           
        case 3
            [ BP ] = selectLFI( highLFI,Ttotal, idxLR);            
        case 4            
            [ BP ] = selectLFI( ceilLFI,Ttotal, idxLR);
    end
    
    
    %Average BP in correct order
    avgFreq = squeeze(nanmean(nanmean(BP,4)));  
    avgAFreq.(fnames{LFIbins}) = avgFreq;
    mes = sprintf('Finished averaging for the binned group: %s',fnames{LFIbins});
    disp(mes)
    
end


%plot(avgFreq)

%Currently only plotting one type of buttonpresses. 
%shadedErrorBar(1:141,nanmean(avgFreq,2)',nanstd(avgFreq')./sqrt(size(avgFreq,2)),'g')



%%
%Plot all LFIs

figure(1),clf
hold on; 
l = shadedErrorBar(1:141,nanmean(avgAFreq.low,2)',nanstd(avgAFreq.low')./sqrt(size(avgAFreq.low,2)),'g',1);
m = shadedErrorBar(1:141,nanmean(avgAFreq.medium,2)',nanstd(avgAFreq.medium')./sqrt(size(avgAFreq.medium,2)),'k',1);
h = shadedErrorBar(1:141,nanmean(avgAFreq.high,2)',nanstd(avgAFreq.high')./sqrt(size(avgAFreq.high,2)),'r',1);
c = shadedErrorBar(1:141,nanmean(avgAFreq.ceil,2)',nanstd(avgAFreq.ceil')./sqrt(size(avgAFreq.ceil,2)),'b',1);
%ylim([-20 10])
xlim([30 141])
ylabel('% change to baseline')
xlabel('Time (s) relative to response')
title('Beta suppression binned by LFI (1 parameter)')
set(gca, 'XTick',[1:10:141])
set(gca, 'XTickLabel',time(1:10:141))

legend([l.mainLine m.mainLine h.mainLine c.mainLine],'Low:       0.26-0.32','Medium: 0.32-0.46','High:      0.46-0.60','Ceiling:  0.60-0.73')

%%

%regular plot
figure(2),clf
hold on 
plot(nanmean(avgAFreq.low,2)','LineWidth',2)
plot(nanmean(avgAFreq.medium,2)','LineWidth',2)
plot(nanmean(avgAFreq.high,2)','LineWidth',2)
plot(nanmean(avgAFreq.ceil,2)','LineWidth',2)

indT = find(time==0.7);
set(gca, 'XTick',[1:10:length(time)])
set(gca, 'XTickLabel',time(1:10:length(time)))
xlim([0 indT])
legend Low Medium High Ceiling 
title('Contra vs. ipsi lateralization binned by probability of choice')

ylabel('% change to baseline')
xlabel('Time (s) relative to cue')

%%
%Load and plot all lines seperately for each lock type. 

stimL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/respavgAFreqSTIMLOCKED.mat');
respL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/respavgAFreq2.mat');
cueL = load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/respavgAFreqCUELOCKED.mat');


%Load one instance of each type for information such as time. 
resp =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/AWi/20151007/baseline/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue  =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');

%time=cue.freq.time;
%%
%The time periods of interest


stimStart =31;
stimStop  =100;
respStart =40;
respStop  =92;
cueStart  =10;
cueStop   =65;


%%
%regular plot

%set the ylimit for all plots.
setY = [-9 3];

figure(3),clf
title('Contra vs. ipsi lateralization binned by probability of choice')

subplot(1,3,1)
hold on 
plot(nanmean(stimL.avgAFreq.low,2)','LineWidth',2)
plot(nanmean(stimL.avgAFreq.medium,2)','LineWidth',2)
plot(nanmean(stimL.avgAFreq.high,2)','LineWidth',2)
plot(nanmean(stimL.avgAFreq.ceil,2)','LineWidth',2)
time=stim.freq.time;
indT = find(time==0);
set(gca, 'XTick',[stimStart:10:stimStop])
set(gca, 'XTickLabel',time(stimStart:10:stimStop))
xlim([stimStart stimStop])
ylim(setY)
legend Low Medium High Ceiling 

ylabel('% change to baseline')
xlabel('Time (s) relative to stimulus')


%regular plot
subplot(1,3,2)
hold on 
plot(nanmean(cueL.avgAFreq.low,2)','LineWidth',2)
plot(nanmean(cueL.avgAFreq.medium,2)','LineWidth',2)
plot(nanmean(cueL.avgAFreq.high,2)','LineWidth',2)
plot(nanmean(cueL.avgAFreq.ceil,2)','LineWidth',2)
time=cue.freq.time;
indT = find(time==0);
set(gca, 'XTick',[(cueStart:10:cueStop)+1])
set(gca, 'XTickLabel',time((cueStart:10:cueStop)+1))
xlim([cueStart cueStop])
ylim(setY)

legend Low Medium High Ceiling 

ylabel('% change to baseline')
xlabel('Time (s) relative to cue')


%regular plot
subplot(1,3,3)
hold on 
plot(nanmean(respL.avgAFreq.low,2)','LineWidth',2)
plot(nanmean(respL.avgAFreq.medium,2)','LineWidth',2)
plot(nanmean(respL.avgAFreq.high,2)','LineWidth',2)
plot(nanmean(respL.avgAFreq.ceil,2)','LineWidth',2)
time=resp.freq.time;
indT = find(time==0);
set(gca, 'XTick',[respStart:10:respStop])
set(gca, 'XTickLabel',time(respStart:10:respStop))
xlim([respStart respStop])
ylim(setY)

legend Low Medium High Ceiling 

ylabel('% change to baseline')
xlabel('Time (s) relative to resp')

%%
%Plot timecourses in one plot.


timeX = [stim.freq.time(stimStart:stimStop) cue.freq.time(cueStart:cueStop) resp.freq.time(respStart:respStop)];
x = 1:length(timeX);

low     = [nanmean(stimL.avgAFreq.low(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.low(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.low(respStart:respStop,:),2)'];
medium  = [nanmean(stimL.avgAFreq.medium(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.medium(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.medium(respStart:respStop,:),2)'];
high    = [nanmean(stimL.avgAFreq.high(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.high(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.high(respStart:respStop,:),2)'];
ceil    = [nanmean(stimL.avgAFreq.ceil(stimStart:stimStop,:),2)', nanmean(cueL.avgAFreq.ceil(cueStart:cueStop,:),2)',nanmean(respL.avgAFreq.ceil(respStart:respStop,:),2)'];

figure(4),clf

subplot(2,1,1)
title('Contra vs. Ipsi lateralisation: stim / cue / response-locked')

hold on 
plot(ceil,'LineWidth',2)
plot(high,'LineWidth',2)
plot(medium,'LineWidth',2)
plot(low,'LineWidth',2)

time=resp.freq.time;
indT = find(time==0);

           
        indX = find(timeX==0);
        %indX+5
        %indX-5
        
        indX = [indX (indX-10) (indX+10) indX(1)+20 indX(1)+30 indX(1)+40 indX(1)+50 indX(2)-20 indX(2)-30 indX(3)-20 indX(3)-30];
        indX = sort(indX);
        set(gca,'YDir','normal')
        set(gca,'XTick',[x(indX)])
        set(gca,'XTickLabel',timeX(indX))
%set(gca, 'XTick',[respStart:10:respStop])
%set(gca, 'XTickLabel',time(respStart:10:respStop))
%xlim([respStart respStop])
%ylim(setY)
ylim(setY)
       line([x(stimStop-stimStart)+2 x(stimStop-stimStart)+2],get(gca,'Ylim'),'Color',[0 0 0],'LineWidth',10)
        line([(x(stimStop-stimStart)+2)+(cueStop-cueStart) (x(stimStop-stimStart)+2)+(cueStop-cueStart)],get(gca,'Ylim'),'Color',[0 0 0],'LineWidth',10)


legend Ceiling High Medium Low 

%ylabel('% change to baseline')

%%
%Calulate response time distribution

%To go cue
respDis = Ttotal.resp_sample-Ttotal.goQ_sample;
histfit(respDis(respDis>1)./1200,[],'gamma')
title('Response time (s) from cue')
%print('ResponseFromCue','-depsc2') %epsc2

%To simulus onset
respDis = Ttotal.resp_sample-Ttotal.stim_onset;
histfit(respDis(respDis>1)./1200,[],'gamma')
title('Response time (s) from stimulus onset')
%print('ResponseFromStim','-depsc2') %epsc2


%General stimulus presentation length to go q

respDis = Ttotal.goQ_sample-Ttotal.stim_onset;
histfit(respDis(respDis>1)./1200,[],'gamma')
title('Time (s) from simulus onset to go cue')
%print('StimOnsetToGoCue','-depsc2') %epsc2

%%
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
print('betaProbChoiceCUELOCKED','-depsc2') %epsc2


