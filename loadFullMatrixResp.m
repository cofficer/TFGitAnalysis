function [ fullMatrixR,fullMatrixS ] = loadFullMatrixResp( ~ )
%The function first loads data from response time-frequency and later from
%stimulus-locked TF.


%Load all the participants for response
cd ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedResp');


baselined       = dir('*mat');

%Store the first powspctrm
load(baselined(1).name)

fullMatrixR.powsptrcm = zeros([length(baselined) size(partMatrix.powsptrcm)]);
fullMatrixR.powsptrcm(1,:,:,:,:) = partMatrix.powsptrcm;


%Loop and load all powspctrm data into fullMatrix
for iparticipants = 2:length(baselined)

load(baselined(iparticipants).name)

fullMatrixR.powsptrcm(iparticipants,:,:,:,:) = partMatrix.powsptrcm;

end

disp('Finished storing all participants in one 5-D matrix')


%Load all the participants for stimulus
cd ('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/avgLowFreq/baselinedStim');


baselined       = dir('*mat');

%Store the first powspctrm
load(baselined(1).name)

fullMatrixS.powsptrcm = zeros([length(baselined) size(partMatrix.powsptrcm)]);
fullMatrixS.powsptrcm(1,:,:,:,:) = partMatrix.powsptrcm;


%Loop and load all powspctrm data into fullMatrix
for iparticipants = 2:length(baselined)

load(baselined(iparticipants).name)

fullMatrixS.powsptrcm(iparticipants,:,:,:,:) = partMatrix.powsptrcm;

end

disp('Finished storing all participants in one 5-D matrix')


end

