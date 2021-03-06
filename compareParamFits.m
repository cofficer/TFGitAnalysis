

%Compare parameter fits. Compare the new approach with fmin to finer grid
%search.

%Directories
optimPath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/optimized/';
roughPath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/';
param100path = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/paramspace100/';

cd(roughPath)
subj   = dir('*mat');


for isub = 1:length(subj)

    optim = load(sprintf('%s%s1.mat',optimPath,subj(isub).name(1:3)));
    rough = load(sprintf('%s%s',roughPath,subj(isub).name));
    p100  = load(sprintf('%s%s',param100path,subj(isub).name));


    %Find the lowest MLE parameter pair
    for istart = 1:30
        %newtaufit(isub,istart) = optim.optimizedFits(istart).xbest(2);
        MLE (istart)   = optim.optimizedFits(istart).MLE ;

        %newbetafit(isub,istart) = optim.optimizedFits(istart).xbest(1);

        %newlsfit(isub,istart) = optim.optimizedFits(istart).xbest(3);

    end

    [v,pos]=min(MLE);
    %if there is more than one minimum value, pick the first one.
    if length(pos)>1
        pos=pos(1);
    end

    roughtaufit(isub) = rough.paramFits.taufits(1);
    oldtaufit(isub) = p100.paramFits.tauPLAfits;
    newtaufit(isub) = optim.optimizedFits(pos).xbest(2); %2tau, 1beta, 3ls.

    roughbetafit(isub) = rough.paramFits.betafits(1);
    oldbetafit(isub) = p100.paramFits.betaPLAfits;
    newbetafit(isub) = optim.optimizedFits(pos).xbest(1); %2tau, 1beta, 3ls.

    roughlsfit(isub) = rough.paramFits.lsfits(1);
    oldlsfit(isub) = p100.paramFits.lsPLAfits;
    newlsfit(isub) = optim.optimizedFits(pos).xbest(3); %2tau, 1beta, 3ls.


end

%%
%Check the difference in fits of all the starting points.

for isub = 1:length(subj)

    optim = load(sprintf('%s%s',optimPath,subj(isub).name));

    for istart = 1:30
        newtaufit(isub,istart) = optim.optimizedFits(istart).xbest(2);
        MLE (isub,istart)   = optim.optimizedFits(istart).MLE ;

        newbetafit(isub,istart) = optim.optimizedFits(istart).xbest(1);

        newlsfit(isub,istart) = optim.optimizedFits(istart).xbest(3);

    end

    [v,pos]=min(MLE(isub,:));
    posAll(isub)=pos;
end

%imagesc()
%%
%Plotting

%scatter rough fits and old fits
scatter(oldtaufit,roughtaufit)
scatter(oldbetafit,roughbetafit)
scatter(oldlsfit,roughlsfit)


%scatter rough fits and old fits
scatter(oldtaufit,newtaufit)
scatter(oldbetafit,newbetafit)
scatter(oldlsfit,newlsfit)

%scatter rough and optimal
figure(1)
scatter(newtaufit,roughtaufit)
figure(2)
scatter(newbetafit,roughbetafit)
figure(3)
scatter(newlsfit,roughlsfit)



%%
%Compare parameters to generate simulation with the parameter fitted model
%of these simulations

optimFits = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/optimized/';
roughPath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/roughfit/';
inputpar  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/';



cd(inputpar)
subj   = dir('*mat');

isub=0;
%Loop over all subjects.
for isubtmp = 1:length(subj)
  %

  % if strcmp(subj(isubtmp).name,'BPe.mat')
  %   continue
  % %elseif strcmp(subj(isubtmp).name,'RWi.mat')
  % %  parnum(isub+1) = isubtmp;
  % elseif strcmp(subj(isubtmp).name,'BFu.mat')
  %   continue
  % else
      isub=isub+1;


      %Store the roughfit found with grid search.
      roughfit= load(sprintf('%s%s.mat',roughPath,subj(isubtmp).name(1:3)));

        %for each simulation per participant
        for isims =1:10

            endfits = load(sprintf('%s%s%i.mat',optimFits,subj(isubtmp).name(1:3),isims));
            roughbeta(isub,isims)=mean(roughfit.paramFits(isims).betafits);
            roughtau(isub,isims)=mean(roughfit.paramFits(isims).taufits);
            roughls(isub,isims)=mean(roughfit.paramFits(isims).lsfits);

            for istart = 1:1%30

                MLE (isub,istart)   = endfits.optimizedFits(istart).MLE ;


            end
            %position of best fit out of 30 parameter starting points
            [v,pos]=min(MLE);

            %if there is more than one minimum value, pick the first one.
            if length(pos)>1
                pos=pos(1);
            end
            endtaufit(isub,isims) = endfits.optimizedFits.xbest(2);

            endbetafit(isub,isims) = endfits.optimizedFits.xbest(1);

            endlsfit(isub,isims) = endfits.optimizedFits.xbest(3);

        end

        %Store the original randomized parameter used for model simulation.
        startfit          = load(sprintf('%s%s',inputpar,subj(isubtmp).name));
        startbeta(isub,:) = startfit.cfg1.beta;
        starttau(isub,:)  = startfit.cfg1.tau;
        startls(isub,:)   = startfit.cfg1.ls;
    %end

end


%%
%Plot simulated participants and recovered parameters, lose switch

%High noise levels
avg_noise=mean(startbeta(:));
y = quantile(startbeta(:),[0.1 0.9]);
hig_noise_ind=startbeta(:)>y(end);
col_ind=repmat(1:25,[10,1])';
%ab=[1:25].*ones(1,10)';

%Group data wrt tau, beta and heuristic
tau1dim = endtaufit(:);
tau_max = tau1dim>18;

beta1dim = endbetafit(:);
beta_min = beta1dim<0.00151;

ls1dim = endlsfit(:);
ls_min = ls1dim>0.5;

%Get a rank of the different lsfits, low to high
[~, ~, ranking] = unique(endlsfit(:));
% [~, idx_s] = sort(endlsfit(:));
% mean_ranks = accumarray(idx_u(:), idx_s(idx_s), [], @mean);
% ranking = mean_ranks(idx_u);

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
%Plot simulated parameter recovery
figure(1),clf
clear g
g(1,1)=gramm('x',startls(:),'y',endlsfit(:))%,'color',ranking);
g(1,1).geom_point();
%g(1,1).stat_glm();
  g(1,1).set_names('column','Origin','x','Real value','y','Opim fit','color','#');
g(1,1).set_text_options('base_size',15);
g(1,1).set_title('Heuristic');

g(1,2)=gramm('x',log(startbeta(:)),'y',log(endbetafit(:)))%,'color',ranking);,'color',ranking);
g(1,2).geom_point();
%g(1,2).stat_glm();
g(1,2).set_names('column','Origin','x','Real value','y','Optim fit','color','#');
g(1,2).set_text_options('base_size',15);
g(1,2).set_title('Noise');

g(2,1)=gramm('x',starttau(:),'y',endtaufit(:))%,'color',ranking);,'color',ranking);
g(2,1).geom_point();
%g(2,1).stat_glm();
g(2,1).set_names('column','Origin','x','Real value','y','Optim fit','color','#');
g(2,1).set_text_options('base_size',15);
g(2,1).set_title('Reward');

g.draw();

%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('parameter_recovery_optimized');%fractionTrialsRemaining
filetype    = 'svg';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);  %2012-06-28 idyllwild library - sd - exterior massing model 04.skp

g.export('file_name',figurename,'file_type',filetype);



figure(1),clf
s=scatter(startls(:),roughls(:),'filled');
s.MarkerEdgeColor='black';
s.MarkerFaceColor='black';
title('Heuristic - lose-switch win-stay')
xlabel('Simulated parameter')
ylabel('Recovered parameter')

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('recovered_parameter');%fractionTrialsRemaining
filetype    = 'png';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype)  %2012-06-28 idyllwild library - sd - exterior massing model 04.skp


saveas(gca,figurename,'png')

%Beta parameter
figure(2),clf
s=scatter(log(startbeta(:)),log(roughbeta(:)),'black');
s.MarkerEdgeColor='black';
s.MarkerFaceColor='black';
title('Beta - noise of value on choice')
xlabel('log(Simulated parameter)')
ylabel('log(Recovered parameter)')


%Tau parameter
figure(3),clf
s=scatter(starttau(:),roughtau(:),'filled');
s.MarkerEdgeColor='black';
s.MarkerFaceColor='black';
title('Tau - leak of value integration')
xlabel('Simulated parameter')
ylabel('Recovered parameter')



%%
%Only plot the low beta parameter pairs to look at the recovery of tau.

staus=starttau(:);
etaus=endtaufit(:);

scatter(staus(startbeta(:)>2),etaus(startbeta(:)>2))

plot(startbeta(:))

%%
%Look at parameter fits for the rough fits for the 2 parameter mode.

par2path =  '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/';

cd(par2path)


subj   = dir('*mat');


for isub = 1:length(subj)

    par2 = load(sprintf('%s%s.mat',par2path,subj(isub).name(1:3)));


    %Find the lowest MLE parameter pair
    for istart = 1:100
        newtaufit(isub,istart) = par2.paramFits.taufits(istart);

        newbetafit(isub,istart) = par2.paramFits.betafits(istart);




    end



end

%%
%Load optimized paramfits for 2 parameter model.

inputpar  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/optimized/';



cd(inputpar)
subj   = dir('*mat');


%Loop over all subjects.
for isub = 1:length(subj)
%
    if subj(isub).name=='BPr1.mat'
        aa=1;
    else

        %for each simulation per participant
        for isims =1:1
            endfits = load(sprintf('%s%s%i.mat',inputpar,subj(isub).name(1:3),isims));

            for istart = 1:30

                MLE (isub,istart)   = endfits.optimizedFits(istart).MLE ;


            end
            %position of best fit out of 30 parameter starting points
            [v,pos]=min(MLE);

            %if there is more than one minimum value, pick the first one.
            if length(pos)>1
                pos=pos(1);
            end
            endtaufit(isub,isims) = endfits.optimizedFits(pos).xbest(2);

            endbetafit(isub,isims) = endfits.optimizedFits(pos).xbest(1);

          %  endlsfit(isub,isims) = endfits.optimizedFits(pos).xbest(3);

        end



        %Store the original randomized parameter used for model simulation.
        %startfit          = load(sprintf('%s%s',inputpar,subj(isub).name));
        %startbeta(isub,:) = startfit.cfg1.beta;
        %starttau(isub,:)  = startfit.cfg1.tau;
        %startls(isub,:)   = startfit.cfg1.ls;
    end

end

%%
%Plot the tau fits for 2 and 3 param model

figure(6),clf
hold on
xlim([0 4])
ylim([0 22])


c=scatter(ones(1,29),end1taufit,'filled');
c.MarkerEdgeColor='black';
c.MarkerFaceColor='black';
scatter(1,mean(end1taufit),'filled','MarkerEdgeColor','red','MarkerFaceColor','red')


c=scatter(ones(1,29)*2,endtaufit,'filled');
c.MarkerEdgeColor='black';
c.MarkerFaceColor='black';
scatter(2,mean(endtaufit),'filled','MarkerEdgeColor','red','MarkerFaceColor','red')

s=scatter(ones(1,29)*3,newtaufit,'filled');
scatter(3,mean(newtaufit),'filled','MarkerEdgeColor','red','MarkerFaceColor','red')

s.MarkerEdgeColor='black';
s.MarkerFaceColor='black';
title('Comparison of tau fits')
ylabel('Tau parameter values')
xnames = {'1 Parameter Model';'2 Parameter Model';'3 Parameter Model'};
set(gca,'XTick',1:3,'xticklabel',xnames)



%%
%Load the tau parameter for the 1 parameter mode
inputpar  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/1params/optimized/';



cd(inputpar)
subj   = dir('*mat');


%Loop over all subjects.
for isub = 1:length(subj)
%
    if subj(isub).name=='BPr1.mat'
        aa=1;
    else

        %for each simulation per participant
        for isims =1:1
            endfits = load(sprintf('%s%s%i.mat',inputpar,subj(isub).name(1:3),isims));

            for istart = 1:30

                MLE (isub,istart)   = endfits.optimizedFits(istart).MLE ;


            end
            %position of best fit out of 30 parameter starting points
            [v,pos]=min(MLE);

            %if there is more than one minimum value, pick the first one.
            if length(pos)>1
                pos=pos(1);
            end
            end1taufit(isub,isims) = endfits.optimizedFits(pos).xbest(1);

            %endbetafit(isub,isims) = endfits.optimizedFits(pos).xbest(1);

          %  endlsfit(isub,isims) = endfits.optimizedFits(pos).xbest(3);

        end



        %Store the original randomized parameter used for model simulation.
        %startfit          = load(sprintf('%s%s',inputpar,subj(isub).name));
        %startbeta(isub,:) = startfit.cfg1.beta;
        %starttau(isub,:)  = startfit.cfg1.tau;
        %startls(isub,:)   = startfit.cfg1.ls;
    end

end
