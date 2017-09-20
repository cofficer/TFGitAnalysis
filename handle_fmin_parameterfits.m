function [ bestfit ] = handle_fmin_parameterfits( cfg,cfg1 )
%Purpose: fasciliate the use of fminsearchbnd function.
%1st iteration: Use single participant AWi.
%Goal. Dynamically take in all different participants to simplify parameter
%fits, as well as simulated parameter fits.



%Analyse using single or double-parameter model
setting.modeltype              = cfg1.numparameter;

%Define the scope of parameter space.

if cfg1.numparameter=='2'
    %No ls if only two parameters.
    cfg1.tau                    = cfg(2);
    cfg1.ls                     = 0;
    cfg1.beta                   = cfg(1);
elseif cfg1.numparameter=='1'
    %since only one parameter tau needs to be in cfg(1)
    cfg1.tau                    = cfg(1);
    cfg1.ls                       = 0;
    cfg1.beta                     = 0.0015;
else
    cfg1.tau                    = cfg(2);
    cfg1.ls                     = cfg(3);
    cfg1.beta                   = cfg(1);
end
cfg1.simulate               = cfg1.simulate;


%cfg1.runs                   = 1; %Irrelevant
%cfg1.session                = 'AWi/20151007';
cfg1.simulateLoseSwitch     = 0; %1 for yes, 0 for no.
cfg1.drugEffect             = 1;
cfg1.numparameter           = cfg1.numparameter;
cfg1.path                   = cfg1.path;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';
cd(bhpath);

%setting.bhpath          = bhpath;
%How many participants should be analysed?
%setting.numParticipants        = 29; %need to remove JRu and MGo somehow.

%Get parameter fits for the number of participants defined.
%[ paramFits, cfg1, PLA, ATM]   = parameterFitting( setting);
[allMLE,choiceStreamAll] = Model_performanceK(cfg1);

%Only take the first choicestream for now.
if cfg1.modelchoices
    cfg1.runs = 1; %I think only 1 run is necessary inside the optimization. 
    choiceStreamAll=choiceStreamAll(:,cfg1.runs)';
    allMLE         =squeeze(allMLE(:,1,1,cfg1.runs));
end

%Reaload the participant behavior to match the against the model.
if cfg1.simulate
    load(cfg1.path)
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);


end

%Choicestream vector need to be in certain format.
if size(choiceStreamAll,2)==1
    choiceStreamAll=choiceStreamAll';
end
%%
% Maxium likelihood estimation procedure:


%Matrix for all parameter values
tableTBAll     = zeros(size(allMLE,3),size(allMLE,2),size(allMLE,4));


%Matrix per participant
tableTB     = zeros(size(allMLE,3),size(allMLE,2));

%Loop over both parameters
for eachBeta = 1:size(allMLE,3)
    for eachTau = 1:size(allMLE,2)
        for eachLS = 1:size(allMLE,4)

            %Calulate the log likelihood for placebo and atomoxetine.
            logLikelihood = -sum(log(binopdf(choiceStreamAll,1,allMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));

            %Store all the log likelihood estimations
            tableTB(eachBeta,eachTau,eachLS) = logLikelihood;

        end
    end
end

%Insert MLE into larger matrix
tableTBAll(:,:,:) = tableTB;


%%
%Find the best it negative log.
%Get the actual parameter fits for current session
MLE      = tableTBAll(:,:,:);

[paramVAL, idx] = min(MLE(:));

bestfit = paramVAL;


end
