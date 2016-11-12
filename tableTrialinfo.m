function [ T ] = tableTrialinfo( pathA )
%create a table with all the variables for all the sessions and
%participants, for each trial. 



%Load the local fractional income for each trial

%Match up trial number from trialinfo with the LFI, 

load(pathA);


%take the old trialinfo that contains all of the trials that were presented
trialinfo = freq.cfg.previous.previous.previous.previous.previous.previous.previous.previous.trl;

sample_start = trialinfo(:,1); %Minus 2 seconds, guessing before stim?

sample_end   = trialinfo(:,2); %Feedback + 2s

start_fix    = trialinfo(:,3); %Fixation point, at start of trial

cue_trigger  = trialinfo(:,4);

stim_onset   = trialinfo(:,5);

stim_orient  = trialinfo(:,6);

goQ_sample   = trialinfo(:,7); %Response go cue

goQ_trigger  = trialinfo(:,8);

resp_sample  = trialinfo(:,9);

resp_type    = trialinfo(:,10);

feedb_sample = trialinfo(:,11);

feedb_type   = trialinfo(:,12);

if strcmp(pathA(1:3),'DWe')
    new_block    = trialinfo(:,14);
    
    trialN       = trialinfo(:,15);
else
    new_block    = trialinfo(:,13);
    
    trialN       = trialinfo(:,14);
end
ID           = cell(1,length(sample_start));

dataSet      = cell(1,length(sample_start));

for nt       = 1:length(sample_start)
ID{nt}       = pathA(1:3);
dataSet{nt}  = pathA(end-5:end-4);
end

ID      = char(ID');
dataSet = char(dataSet');

T = table(sample_start,sample_end,start_fix,cue_trigger,stim_onset,...
    stim_orient,goQ_sample,goQ_trigger,resp_sample,resp_type,...
    feedb_sample,feedb_type,new_block,trialN,dataSet,ID);




end

