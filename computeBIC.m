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







