function [ output_args ] = appendTables( input_args )
%Figure out if there is a match between the model trials and table
ID = Ttotal.ID;
ID = cellstr(ID);

%Store all lfi value to be inserted
LocalFractionalIncome = zeros(1,length(Ttotal.cue_trigger));

correct=1;

%Loop over participants.
for nPart = 1:length(allFracIncome.order)

 %Find the position of the current participant   
 cmpID=strncmp(allFracIncome.order{nPart}(1:3),ID,3);
[posID,~] = find(cmpID==1);

%Storing the length of trial, which is not relevant.
tableT = length(posID);
modelT =length(allFracIncome.LFI{nPart});

%subtract the number of incorrect buttonpresses from the number of trials.
tableT = tableT-sum(Ttotal.resp_type(posID)<20);

[p,a]  =find(Ttotal.resp_type(posID)>=20);
[pN,a] =find(Ttotal.resp_type(posID)<20);



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
end

