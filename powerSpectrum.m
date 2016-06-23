

%Plot frequency spectra per participant, averaged over trials. 

%Conatenate together all the trials of one participant for one session. 
%Loopz
close



%%
%Loop over participants. 

%Store name of block file. 
load_dir  = dir('*resp_b*.mat');

%Loop over all blocks to load and concatenate the trials. 
for ipart = 1: length(load_dir)

data      = load(load_dir(ipart).name);

data      = data.data; 

if ipart  == 1
    
    %In the first loop store all the fields.
    dataAll       = data;

    %Starting with the second loop only add trials. 
else
    dataAll.trial = cat(1,dataAll.trial,data.trial);
end

end


%Loop over trials.
%If NaNs are present, skip trial.
for itrial = 1:length(data.trial)
    if sum(sum(isnan(data.trial{itrial})))>0
        a=1;
    else
        %Loop over channels.
        for ichan = 1:size(data.trial{1},1)
            
            [p(ichan,:,itrial),f]=pwelch(data.trial{itrial}(ichan,:),hanning(1000),0.5,1:0.5:50,500);
             
        end
    end
    
end

loglog(f,nanmean(nanmean(p,3)))
size(nanmean(p,3))
