
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Collect all the files into plots for time course.
%Create the timecourses to plot locked to different events
%Script or creating the timecourses that will later make it into final
%plots.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%Put together first by event and then by LFI level.
%loop over all event types
clear;
param = '1';
lfiPC = '';

BPallCue  = NaN(33,21,15,2); %low prob choice
BPallStim = NaN(33,21,15,2); %medium prob choice
BPallResp = NaN(33,31,15,2); %high prob choice
% BPallCue4 = zeros(33,141,29); %ceiling prob choice

%decide if timecourses should be split according to lose-switch rate.
sortPart = 1;

if sortPart == 1
    %The old IDs
    %load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/lowswitchID.mat');
    %load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/highswitchID.mat');
    %The new IDs
    %[ lowswitchID,highswitchID ] = groupLoseSwitchHeuristic;
    %IDs based on tau parameter
    %load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/lowTauFitsID.mat');
    %load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/highTauFitsID.mat');
        %IDs based on performance
    %load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/perfLowID.mat');
    load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/perfOptimID1param.mat');
end



inputPath=sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/contraipsi/short/param%s/%s',param,lfiPC);
cd(inputPath)


for ievent = 1:2
    
    cueN = dir('*Cue.mat');

    
    stimN = dir('*Stim.mat');
    
    respN = dir('*Resp.mat');
    
    
    %replace all of the sessions with the sessions defined according to
    %low or high switch lose rate.
    if sortPart == 1
        
        allcue = {cueN.name};
        highS = cellfun(@(n) n(1:3),partNotOptim,'UniformOutput',0);
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
%save the time courses, change the names of the mat files according to low
%high are all participants. 
%
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short')

BPallCue  = squeeze(nanmean(BPallCue(10:end,:,:,:),1));

BPallStim = squeeze(nanmean(BPallStim(10:end,:,:,:),1));

BPallResp = squeeze(nanmean(BPallResp(10:end,:,:,:),1));

strDate = '12-Mar-2017';
strCue  = sprintf('timecourseCue%sP%s%sNOTOPTIM.mat',param,lfiPC,strDate);
strStim = sprintf('timecourseStim%sP%s%sNOTOPTIM.mat',param,lfiPC,strDate);
strResp = sprintf('timecourseResp%sP%s%sNOTOPTIM.mat',param,lfiPC,strDate);


save(strCue,'BPallCue')
save(strStim,'BPallStim')
save(strResp,'BPallResp')






