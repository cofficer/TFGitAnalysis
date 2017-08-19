function [ output_args ] = plotRTvsParameters( input_args )
%Test the hypothesis that Reaction time vary as a function of heuristic.


load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/fullTable1203-5PC.mat')

[x,idxID] = unique(Ttotal.ID,'rows');

ID = Ttotal.ID;
ID = cellstr(ID);
cmID = strcmp(ID,session.name(1:3));
posID = find(cmID == 1);

    
    
for ipart = 1:length(idxID)
   
    
    respSample = Ttotal.resp_sample(strcmp(ID,x(ipart,:)));
    goQSample  = Ttotal.goQ_sample(strcmp(ID,x(ipart,:)));
    
    %index to bad presses
    respSample = respSample(Ttotal.resp_type(strcmp(ID,x(ipart,:)))>0);
    goQSample  = goQSample(Ttotal.resp_type(strcmp(ID,x(ipart,:)))>0);
    
    %Get mean reaction time for each participant
    meanRT(ipart) = mean(respSample - goQSample)/1200;
    
end

%load the various parameter fits and compare to meanRT
[ newtaufit,newbetafit,newlsfit,end1taufit ] = load_params_matching;

%plot the relationships
figure(1),clf
scatter(newlsfit,meanRT)
figure(2),clf
scatter(newbetafit,meanRT)
figure(3),clf
scatter(newtaufit,meanRT)

[a,b]=corr(newlsfit(newtaufit<19)',meanRT(newtaufit<19)')

end

