function [ data ] = triggerDataSelection( begsample, endsample, trigger, data, trialStartSample)
%select data based around a trigger. Redefine data subsequently. 


%cfg.offset=0; %Realign the time axis of all trials. Single number vector.
%Find the beginsamples of all trials


%No longer need to recreate the original samples based on time. 
% trialStartSample = zeros(1,length(data.time)); % Vector with sample time
% 
% for i=1:length(data.time)
%     
%     %The sample number of when each trial started 
%     trialStartSample(i) = data.time{i}(1)*1200; %trialinfo is based on the original fsample.
% 
% end


cfg=[];

%Ideally, this will get the samples 0.8s before trigger and 1s after
%Sample of response trigger minus sample of each timepoint

buttonpressSample = data.trialinfo(:,trigger);

trigButtonOffsetOldSample = buttonpressSample-(trialStartSample); %Number of samples from start of trial to trigger in original sample rate

trigButtonOffsetTime      = trigButtonOffsetOldSample/1200; %Time in s until trigger from trialstart

trigButtonOffsetNewSample = trigButtonOffsetTime*500; 

cfg.begsample = trigButtonOffsetNewSample-begsample;
cfg.endsample = trigButtonOffsetNewSample+endsample;


data = ft_redefinetrial(cfg,data);


end

