function [ data ] = triggerOffsetDataTime( data, begsample )
%Make data.time from our data more similar to the example data from
%fieldtrip website. This is done by making the timestamps relative to the
%offset of the event of interest. 

%Find the time stamp of the trigger of interest 
%Should be 0.8s after start of data.time
%500 samples per second
triggerTimeStamp = data.time{1}(round(begsample+1)); %add 1 to get the 0 point, which should be the sample of the trigger. But +2 is for some reason closer. 

S=repmat(round(begsample+1),length(data.time),1); % S contain the indexes for each cell.

idxData=cellfun(@(c,idx)c(:,idx),data.time,num2cell(S)','UniformOutput',false); 

newDataTime=cellfun(@minus,data.time,idxData,'UniformOutput',false);

data.time=newDataTime; %Making time data relative to trigger. With no loops! 

end

