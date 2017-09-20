

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

inputpar  = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/';



cd(inputpar)
subj   = dir('*mat');


%Loop over all subjects.
for isubtmp = 1:length(subj)
%
    isub=isubtmp;
    if strcmp(subj(isub).name,'BPe.mat')
      continue

    else

        %for each simulation per participant
        for isims =1:10
            endfits = load(sprintf('%s%s%i.mat',optimFits,subj(isub).name(1:3),isims));

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

            endlsfit(isub,isims) = endfits.optimizedFits(pos).xbest(3);

        end



        %Store the original randomized parameter used for model simulation.
        startfit          = load(sprintf('%s%s',inputpar,subj(isub).name));
        startbeta(isub,:) = startfit.cfg1.beta;
        starttau(isub,:)  = startfit.cfg1.tau;
        startls(isub,:)   = startfit.cfg1.ls;
    end

end


%%
%Plot simulated participants and recovered parameters, lose switch
figure(1),clf
s=scatter(startls(:,1),endlsfit(:,1),'filled');
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
s=scatter(log(startbeta(:)),log(endbetafit(:)),'black');
s.MarkerEdgeColor='black';
s.MarkerFaceColor='black';
title('Beta - noise of value on choice')
xlabel('log(Simulated parameter)')
ylabel('log(Recovered parameter)')


%Tau parameter
figure(3),clf
s=scatter(starttau(:),endtaufit(:),'filled');
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
