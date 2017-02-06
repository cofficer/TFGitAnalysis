
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Collect all the files into plots for time course.
%
%Script or creating the timecourses that will later make it into final
%plots.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/contraipsi/short/param3/')
%%
%Put together first by event and then by LFI level.

%loop over all event types


BPallCue  = NaN(33,21,15,2); %low prob choice
BPallStim = NaN(33,21,15,2); %medium prob choice
BPallResp = NaN(33,31,15,2); %high prob choice
% BPallCue4 = zeros(33,141,29); %ceiling prob choice

%decide if timecourses should be split according to lose-switch rate.
sortLS = 1;

if sortLS == 1
    load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/lowswitchID.mat');
    load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/highswitchID.mat');
end


for ievent = 1:2
    
    cueN = dir('*Cue.mat');
    
    stimN = dir('*Stim.mat');
    
    respN = dir('*Resp.mat');
    
    
    %replace all of the sessions with the sessions defined according to
    %low or high switch lose rate.
    if sortLS == 1
        
        allcue = {cueN.name};
        highS = cellfun(@(n) n(1:3),highswitchID,'UniformOutput',0);
        cue = cellfun(@(n) n(1:3),allcue,'UniformOutput',0);
        cueN = cueN(ismember(cue,highS));
        stimN = stimN(ismember(cue,highS));
        respN = respN(ismember(cue,highS));
        
    end
    
    
    eventcmp  = sprintf('_%d_',ievent);
    
    %Cue event
    cueNames  = {cueN.name};
    cueN      =  strfind(cueNames,eventcmp);
    cueNind   = find(~cellfun(@isempty,cueN));
    cueNames  = cueNames(cueNind);
    
    %Stim event
    stimNames = {stimN.name};
    stimN     =  strfind(stimNames,eventcmp);
    stimNind  = find(~cellfun(@isempty,stimN));
    stimNames = stimNames(stimNind);
    
    %Resp event
    respNames = {respN.name};
    respN     =  strfind(respNames,eventcmp);
    respNind  = find(~cellfun(@isempty,respN));
    respNames = respNames(respNind);
    
    %Store for cue event.
    
    %Store for cue event.
    totNansR=0;
    totNansS=0;
    totNansC=0;
    
    ip=1;
    for ipart = 1:length(cueNames)
        
        if mod(ipart,2)==1
            BP1=load(cueNames{ipart});
            BP2=load(cueNames{ipart+1});
            BPallCue(:,:,ip,ievent)= (BP1.BP+BP2.BP)./2';
            
            %Check the number of participants with only nans.
            if    sum(isnan(BP1.BP(:)))>1
                totNansC = totNansC+1;
            end
            
            BP1=load(stimNames{ipart});
            BP2=load(stimNames{ipart+1});
            BPallStim(:,:,ip,ievent)= (BP1.BP+BP2.BP)./2';
            
            %Check the number of participants with only nans.
            if    sum(isnan(BP1.BP(:)))>1
                totNansS = totNansS+1;
            end
            
            BP1=load(respNames{ipart});
            BP2=load(respNames{ipart+1});
            
            BPallResp(:,:,ip,ievent)= (BP1.BP+BP2.BP)./2';
            
            %Check the number of participants with only nans.
            if    sum(isnan(BP1.BP(:)))>1
                totNansR = totNansR+1;
                respNames{ipart}
            end
            respNames{ipart}
            
            ip=1+ip;
        end
        
        
        
    end
    
    
    
end
%%
%save the time courses
%
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short')

BPallCue  = squeeze(nanmean(BPallCue(10:end,:,:,:),1));

BPallStim = squeeze(nanmean(BPallStim(10:end,:,:,:),1));

BPallResp = squeeze(nanmean(BPallResp(10:end,:,:,:),1));


save('timecourseCue3PhighLS.mat','BPallCue')
save('timecourseStim3PhighLS.mat','BPallStim')
save('timecourseResp3PhighLS.mat','BPallResp')





