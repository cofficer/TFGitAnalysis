function [ output_args ] = computeBIC( input_args )
%Compare the different models, by the use of bayesian information
%criterion.

%%
optim3Path = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/optimized/';

optim2Path = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/optimized/';

optim1Path = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/1params/optimized/';

cd(optim3Path)
subj   = dir('*mat');


%Loop over all subjects.
for isub = 1:length(subj)

        %for each simulation per participant

            endfits3 = load(sprintf('%s%s1.mat',optim3Path,subj(isub).name(1:3)));
            endfits2 = load(sprintf('%s%s1.mat',optim2Path,subj(isub).name(1:3)));
            endfits1 = load(sprintf('%s%s1.mat',optim1Path,subj(isub).name(1:3)));

            for istart = 1:30

                MLE3 (isub,istart)   = endfits3.optimizedFits(istart).MLE ;
                MLE2 (isub,istart)   = endfits2.optimizedFits(istart).MLE ;
                MLE1 (isub,istart)   = endfits1.optimizedFits(istart).MLE ;
            end
            %position of best fit out of 30 parameter starting points
            [v,pos3]=min(MLE3(isub,:));
            [v,pos2]=min(MLE2(isub,:));
            [v,pos1]=min(MLE1(isub,:));

            %if there is more than one minimum value, pick the first one.
            if length(pos3)>1
                pos3=pos3(1);
            end
            if length(pos2)>1
                pos2=pos2(1);
            end
             if length(pos1)>1
                pos1=pos1(1);
            end

            %Compute the criterion
            BIC3(isub) = log(525)*3+MLE3(isub,pos3);

            BIC2(isub) = log(525)*2+MLE2(isub,pos2);

            BIC1(isub) = log(525)*1+MLE1(isub,pos1);

            %endtaufit(isub) = endfits.optimizedFits(pos).xbest(2);

            %endbetafit(isub) = endfits.optimizedFits(pos).xbest(1);

          %  endlsfit(isub,isims) = endfits.optimizedFits(pos).xbest(3);

end

%%
%Make a barplot of the BIC
P1  = mean(BIC1);
se1 = std(BIC1)/sqrt(length(BIC1));

P2  = mean(BIC2);
se2 = std(BIC2)/sqrt(length(BIC2));

P3  = mean(BIC3);
se3 = std(BIC3)/sqrt(length(BIC3));

%Create gramm plot versions
figure('Position',[100 100 300 250]),clf
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
clear g1
x_val = num2str([ones(1,29),ones(1,29)*2,ones(1,29)*3]')';
%x_val, Stor the variable of grouping as cell string.
for ix = 1:length(x_val)
  x_valn{ix} = x_val(ix);
end

g1= gramm('x',x_valn,'y',[BIC1,BIC2,BIC3],'color',[ones(1,29),ones(1,29)*2,ones(1,29)*3]);
%g.geom_interval('geom','errorbar','dodge',0.2,'width',0.8);
% g2=copy(g1);

%g(1,1).geom_point()
g1.stat_boxplot('dodge',0.1,'width',0.9);
%Averages with confidence interval
% g1.geom_point()
%g(1,2).set_title('stat_summary()');
g1.set_names('column','Origin','x','','y','BIC','color','Model');
g1.draw();

%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('BIC_model_comparison_boxplot');%fractionTrialsRemaining
filetype    = 'svg';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
g1.export('file_name',figurename,'file_type',filetype);

%%Plot a jittered scatter gramm, of BIC delta 3-2 and
%BIC delta 2-1.
idxBIC1 = logical(BIC1<BIC2) .* logical(BIC1<BIC3);
idxBIC2 = logical(BIC1>BIC2) .* logical(BIC2<BIC3);
idxBIC3 = logical(BIC1>BIC3) .* logical(BIC2>BIC3);

idxColBIC = ones(1,29);
idxColBIC(logical(idxBIC2)) = 2;
idxColBIC(logical(idxBIC3)) = 3;

%Plot the model selection BIC deltas.

figure('Position',[100 100 800 600]),clf
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
clear g2

g2= gramm('x',[BIC1-BIC2],'y',[BIC2-BIC3],'color',idxColBIC)
%g.geom_interval('geom','errorbar','dodge',0.2,'width',0.8);
% g2=copy(g1);

g2.geom_point()
%g2.stat_boxplot('dodge',0.1,'width',0.9);
%Averages with confidence interval
% g1.geom_point()
g2.set_title('BIC model selection');
g2.set_names('column','Origin','x','delta BIC 1-2','y','delta BIC 2-3','color','Model');
g2.set_text_options('base_size',20)
g2.set_point_options('base_size',10);
% g2.facet_grid('space','fixed')

% Color mapping for the polygons
cmap = [1   0.5 0.5; % red (bad gas mileage)
        0.5 1   0.5; % blue (reasonable gas mileage)
        0.1,  0.5,  1]; % green (good gas mileage)

% g2.geom_polygon('y',{[-10 0];[0 200]},'color',cmap(1:2,:)); %'x',{[-8 -5] ; [10 20]},
g2.geom_polygon('x',{[-10 0 0 -10];[0 30 30 0];[-10 30 30 -10]},'y',{[-15 -15 0 0];[-15 -15 0 0];[0 0 230 230]},'color',cmap,'alpha',0.1)%,'color',cmap(1,:),'alpha',0.3);

g2.draw();

%%%%%%%%
%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
% namefigure = sprintf('testing_example_cars_polygon');%BIC_model_comparison_individual
namefigure = sprintf('BIC_model_comparison_individual');%BIC_model_comparison_individual
filetype    = 'svg';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
g2.export('file_name',figurename,'file_type',filetype);




figure(1),clf
hold on;
bar([1 2 3],[P1 P2 P3])
xlim([0 4])
errorbar([P1 P2 P3],[se1 se2 se3],'.','color',[0 0 0])
% for ip=1:length(BIC2)
% plot([BIC2(ip),BIC3(ip)],'color','k')
% end
xnames = {'1 Parameter Model';'2 Parameter Model';'3 Parameter Model'};
set(gca,'XTick',1:3,'xticklabel',xnames)

title('Comparing BIC for all model versions')
ylabel('Bayesian information criterion')

%%
%Make a plot comparing each subj

plot([BIC2 ;BIC3]')

figure(2),clf
hold on
for ip=1:length(BIC2)
plot([BIC2(ip),BIC3(ip)],'color','k')
end
xlim([0 3])

%%
%Per subject differences in the BIC
figure(3),clf
plot((BIC2-BIC3),'.','markers',20,'color','k')
hold on
line([0 30],[0 0],'color','r')
title('Evidence against higher BIC')
xlabel('Participant (n)')
ylabel('BIC difference: BIC (2P) - BIC(3P)')

%%
%compare model 1 and 3
figure(4),clf
plot((BIC1-BIC3),'.','markers',20,'color','k')
hold on
line([0 30],[0 0],'color','r')
title('Evidence against higher BIC')
xlabel('Participant (n)')
ylabel('BIC difference: BIC (1P) - BIC(3P)')

%%
%compare model 1 and 2
figure(5),clf
plot((BIC1-BIC2),'.','markers',20,'color','k')
hold on
line([0 30],[0 0],'color','r')
%ylim([-10 2])
title('Evidence against higher BIC')
xlabel('Participant (n)')
ylabel('BIC difference: BIC (1P) - BIC(2P)')

end
