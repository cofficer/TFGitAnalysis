%Create the full table of all participants.

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel')

load('fullTable.mat')
load('allFracIncome.mat')

%%
%loop participants

[PLA,ATM] = loadSessions;


folder = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/';

for nPart = 1:length(PLA)
    
    
    folderP = sprintf('%s%s/',folder,PLA{nPart}(1:3));
    
    
    cd(folderP)
    
    aD=dir;
    
    aD=aD(3).name;
    
    folderP = sprintf('%s%s/resp',folderP,aD);
    
    cd(folderP)
    
    sessions = dir('*_type1event1*.mat');
    
    
    for blocks = 1:length(sessions)
        
        path = sessions(blocks).name;
        
        [ T ] = tableTrialinfo( path );
        
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

%%
%Figure out if there is a match between the model trials and table
ID = Ttotal.ID;
ID = cellstr(ID);

%Store all lfi value to be inserted
LocalFractionalIncome = zeros(1,length(Ttotal.cue_trigger));

correct=1;
for nPart = 1:length(allFracIncome.order)
cmpID=strncmp(allFracIncome.order{nPart}(1:3),ID,3);

[posID,~] = find(cmpID==1);

sum(Ttotal.resp_type(posID)<20);


tableT = length(posID);
modelT =length(allFracIncome.LFI{nPart});

%subtract the number of incorrect buttonpresses from the number of trials.
tableT = tableT-sum(Ttotal.resp_type(posID)<20);

[p,a]=find(Ttotal.resp_type(posID)>=20);
[pN,a]=find(Ttotal.resp_type(posID)<20);



%compare if the number of trials in trialinfo overlaps with model
if tableT == modelT
    sprintf('Correct trials for: %s',allFracIncome.order{nPart}(1:3))
    correct=correct+1;
    
    %insert LFI
    LocalFractionalIncome(posID(p))     = allFracIncome.LFI{nPart}';
    LocalFractionalIncome(posID(pN))    = NaN;
    
else
    sprintf('Wrong number of trials for: %s, modelT=%d, tableT=%d',...
    allFracIncome.order{nPart}(1:3),modelT,tableT)
    
    %In sessons without matching trials just place NaNs for now
    LocalFractionalIncome(posID)        = NaN;
end

end

Ttotal.LocalFractionalIncome = LocalFractionalIncome';


%Issue with LME session. 
a=find(Ttotal.LocalFractionalIncome==0);
Ttotal.LocalFractionalIncome(a,:) = NaN;



%%
%Find out the different local fractional income bins from table


ceilLFI = Ttotal(Ttotal.LocalFractionalIncome>=0.75,:);

highLFI = Ttotal(0.75>Ttotal.LocalFractionalIncome & Ttotal.LocalFractionalIncome>=0.5,:);

mediumLFI = Ttotal(0.5>Ttotal.LocalFractionalIncome & Ttotal.LocalFractionalIncome>=0.25,:);

lowLFI = Ttotal(0.25>Ttotal.LocalFractionalIncome & Ttotal.LocalFractionalIncome>=0,:);

%%
%select ceilLFI and average 


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/trialsLowFreq/baselinedStim')

session = ceilLFI.ID(1,:);

session = sprintf('%s*Left.mat',session);

session = dir(data);

f = load(session.name);

%this needs to be matched up with the equivalent table.
f.trialinfo

ID = ceilLFI.ID;
ID = cellstr(ID);

cmID = strncmp(ID,'AWi',3);

posID = find(cmID == 1);

trials = ceilLFI.trialN(posID);


f.powspctrm(trials,:,:,:)
%It is the trials if they were in order which they arent. They are sorted
%based on the same button press. 
trials

%%
%select trials
ID = Ttotal.ID;
ID = cellstr(ID);


cmID = strncmp(ID,'DLa',3);

pos = find(cmID == 1);

t = Ttotal(pos,:);

sum(t.resp_type==21)

sum(t.resp_type==20)

%Trialinfo contains the information of the atually TF data. 
trialinfo
