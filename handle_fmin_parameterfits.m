function [ bestfit ] = handle_fmin_parameterfits( cfg,path )
%Purpose: fasciliate the use of fminsearchbnd function.
%1st iteration: Use single participant AWi. 
%Goal. Dynamically take in all different participants to simplify parameter
%fits, as well as simulated parameter fits. 



%Analyse using single or double-parameter model
setting.modeltype              = '3';

%Define the scope of parameter space. 
cfg1.beta                   = cfg(1);
cfg1.tau                    = cfg(2);
cfg1.ls                     = cfg(3);
cfg1.simulate               = 1;


cfg1.runs                   = 1; %Irrelevant
cfg1.session                = 'AWi/20151007';
cfg1.simulateLoseSwitch     = 0; %1 for yes, 0 for no. 
cfg1.drugEffect             = 1;
cfg1.numparameter           = '3';
cfg1.path                   = path;
 
bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
cd(bhpath);

%setting.bhpath          = bhpath;
%How many participants should be analysed?
%setting.numParticipants        = 29; %need to remove JRu and MGo somehow. 

%Get parameter fits for the number of participants defined. 
%[ paramFits, cfg1, PLA, ATM]   = parameterFitting( setting);
[allMLE,choiceStreamATM,choiceStreamPLA] = Model_performanceK(cfg1);

%Reaload the participant behavior to match the against the model.
if cfg1.simulate
    load(cfg1.PLApath)
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    choiceStreamPLA = choiceStreamAll;
    load(cfg1.ATMpath)
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    choiceStreamATM = choiceStreamAll;

end


%%
% Maxium likelihood estimation procedure:
%Placebo
plaMLE = allMLE.PLA;
%Atomoxetine
atmMLE = allMLE.ATM;

%Matrix for all parameter values
%if AllPart==1;
    tableTBplaAll     = zeros(size(plaMLE,3),size(plaMLE,2),size(plaMLE,4));
    tableTBatmAll     = zeros(size(plaMLE,3),size(plaMLE,2),size(plaMLE,4));
%end

%Matrix per participant
tableTBpla     = zeros(size(plaMLE,3),size(plaMLE,2));
tableTBatm     = zeros(size(plaMLE,3),size(plaMLE,2));

%Loop over both parameters
for eachBeta = 1:size(plaMLE,3)
    for eachTau = 1:size(plaMLE,2)
        for eachLS = 1:size(plaMLE,4)
        
        
        
        %Calulate the log likelihood for placebo and atomoxetine.
        logLikelihoodPLA = -sum(log(binopdf(choiceStreamPLA,1,plaMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));
        logLikelihoodATM = -sum(log(binopdf(choiceStreamATM,1,atmMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));
        
        %Store all the log likelihood estimations 
        tableTBpla(eachBeta,eachTau,eachLS) = logLikelihoodPLA;
        tableTBatm(eachBeta,eachTau,eachLS) = logLikelihoodATM;
        
        end
    end
end

%Insert MLE into larger matrix
tableTBplaAll(:,:,:) = tableTBpla;
tableTBatmAll(:,:,:) = tableTBatm;


%%
%Find the best it negative log. 
%Get the actual parameter fits for each session


atmMLE      = tableTBatmAll(:,:,:);
plaMLE      = tableTBplaAll(:,:,:);

[paramVALatm, idxatm] = min(atmMLE(:));
[paramVALpla, idxpla] = min(plaMLE(:));


bestfit = paramVALpla; 


end

