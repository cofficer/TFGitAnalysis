function [ output_args ] = modePerformanceSimulation( input_args )
%Compute which parameters give the best performance given the simulations.
%I should actually instead simulate millions of trials, which should be
%relatively easy considering how fast it is.
%%
clear

numParam='1'; % only 1 or 3, for 3 with ls level='' is the same as 2

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/performance')
subj = dir('*.mat');


simPath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/performance/param%s/',numParam);


cd(simPath)

noiselevel={''};%,'1','2','3'};%So far '' is 0.05, 1 is 0.1, 2 is 0.2
lslevel = {''};%,'6','9','1'};%3 6 9 1
%
figure(1),clf
hold on
set(gca,'XScale','log','XGrid','on','YGrid','off')

for ils = 1:length(lslevel)
    for inoise=1:length(noiselevel)
%         subjCurr = sprintf('%s%s%s.mat',subj(isub).name,noiselevel{inoise},lslevel{ils});

        for isub = 1:length(subj)
            nowRun = sprintf('%s%s%s.mat',subj(isub).name(1:3),noiselevel{inoise},lslevel{ils});
            disp(nowRun)
            load(nowRun)

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



        %semilogx(tau(1,:),perfs)
        perfs(inoise,:) = mean(performance,1);
    end
    %perfs(5,:) = mean(performance,1);
end
%
title('Optimal tau level for performance')
xlabel('Tau parameter values in log')
ylabel('Model performance')
ylim([0.5 0.8])

colormag=[255,153,204;255,102,178;255,51,153;255,0,127]./255;
colorpup=[204,153,255;178,102,255;153,51,255;127,0,255]./255;
colorgre=[153,255,153;102,255,102;51,255,51;0,255,0]./255;
colorbro=[255,204,153;255,178,102;255,153,51;255,128,0]./255;

colorall=[colorbro;colorbro];
colorall=[colormag;colorbro];
%colorall='k';
for iplot=1:1%size(perfs,1)

   semilogx(tau(1,:),perfs(iplot,:),'color',colorall(4,:))


end


%
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')

figure(1),clf
clear g
g=gramm('x',[(tau(1,:)),(tau(1,:)),(tau(1,:))],'y',[param1perform,param2perform,param3perform],...
'color',[ones(1,length(tau(1,:))),ones(1,length(tau(1,:)))*2,ones(1,length(tau(1,:)))*3]');

g.geom_line()
% g.stat_summary('sem')
g.set_names('column','Origin','x','Tau value','y','Performance','color','#');
g.set_text_options('base_size',15)
g.set_title('Model simulations')
g.draw();
g.facet_axes_handles.XScale='log';

%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('performanceSim_Par2');%fractionTrialsRemaining
filetype    = 'svg';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype)  %2012-06-28 idyllwild library - sd - exterior massing model 04.skp

g.export('file_name',figurename,'file_type',filetype)


%%
semilogx(tau(1,:),perfs(1,:),'color','k')

%plot participant behavior 1st , 2P M beta 0.3,
s=scatter(end1taufit',performance(1:2:end),'filled')
s.MarkerEdgeColor='black';%colorall(4,:)
s.MarkerFaceColor='black';%colorall(4,:)

%%

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
semilogx(tau(1,:),perfs)
ylim([0.5 0.8])
title('Optimal tau level for performance')
xlabel('Tau parameter values in log')
ylabel('Model performance')
hold on
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
