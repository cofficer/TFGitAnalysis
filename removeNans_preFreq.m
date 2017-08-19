function [ data ] = removeNans_preFreq( data,typeEvent )
%Create a funtion whereby data is segmented and padded to
%not include any NaNs. Reject trials where NaNs occur
%during critical periods. 


cfg1.trialsReject = [];

%find position of NaNs, in one sensor is fine. 
idxNAN = find(isnan(data.trial{20}(1,:))==1);


data.trial{20}(:,idxNAN)


idxNAN

diffIdx = diff(idxNAN);

diff(idxNAN)>1



plot(data.trial{20}(1,:))




%need to make a evaluation of the indNAN to make a judgment on trial rejection 

length(data.trial{8})

%Insert nans n the data.time to know where data has been removed from.
data.time{8}

data.time{8}(1,idxNAN)

%Are there nans during critical period. 


%nansPos 

%identify if nansPos is in the critical period. 
%if yes, then reject the trial
%if no, then define a new cutoff for the trial.
%also cutoff in data.time?



%caveats, multiple 



%redefine the data structure using fieldtrip 
%return data. 



end

