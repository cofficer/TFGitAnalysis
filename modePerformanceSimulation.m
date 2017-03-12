function [ output_args ] = modePerformanceSimulation( input_args )
%Compute which parameters give the best performance given the simulations.
%I should actually instead simulate millions of trials, which should be
%relatively easy considering how fast it is.



simPath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/';


cd(simPath)

subj = dir('*.mat');


for isub = 1:length(subj)

    load(subj(isub).name)
    
    for irun = 1:cfg1.runs
    
    %Raw peformance, not relative to the available rewards, should be 0.8
    %max
    %though.
    performance(isub,irun) = (sum(rewardStreamAll(:,irun))/size(rewardStreamAll,1))/0.8;
    
    beta(isub,irun)=cfg1.beta(irun);
    tau(isub,irun)=cfg1.tau(irun);
    ls(isub,irun)=cfg1.ls(irun);
    
    
    end

end

%Find the position highest performers and check their parameters. 

betas=beta(:);
taus =tau(:);
lss  =ls(:);
perfs = mean(performance,1);
poshighPerf = perfs>0.72;


lowbetas = betas<0.3;
middlebetas = (1>betas) & (betas>0.1);
highbetas =betas>1;

lowls= lss<0.7;
middlels =  (0.8>lss) & (lss>0.5);
hightau=taus>150;

figure(1),clf
plot(taus(poshighPerf))
figure(2),clf
plot(betas(poshighPerf))
figure(3),clf
plot(lss(poshighPerf))

%plot performance in relation to different parameters
figure(4),clf
a=scatter(taus,perfs,'filled')
semilogx(tau(:,1:10:end),performance(:,1:10:end))
title('Optimal tau level for performance')
xlabel('Tau parameter values in log')
ylabel('Model performance')
a.MarkerEdgeColor='blue';
a.MarkerFaceColor='blue';
hold on
b=scatter(perfs(highbetas),taus(highbetas),'filled')
b.MarkerEdgeColor='green';
b.MarkerFaceColor='green';
c=scatter(perfs(middlebetas),taus(middlebetas),'filled')
c.MarkerEdgeColor='black';
c.MarkerFaceColor='black';

%Plot performance and ls
a=scatter(perfs(hightau),lss(hightau),'filled')



scatter(perfs,betas,'filled')
scatter(perfs,lss,'filled')


hist(performance(:))






end

