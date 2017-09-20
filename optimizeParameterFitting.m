
function optimizeParameterFitting(cfg1)
%---------------------------------------------------------
%Attempting new parameter fit procedure using fmnisearch
%---------------------------------------------------------


%Code from konstantinos:
opts = optimset('Display','off','TolX',1e-15,'TolFun',1e-15,'MaxIter',cfg1.iter,'MaxFunEvals',cfg1.funceval);

%opts2 =  optimset('PlotFcns',@optimplotfval,'TolX',1e-15,'TolFun',1e-15,'MaxIter',1000,'MaxFunEvals',20000);



orig_cfg1 = cfg1;

%Loop over all the simulations per sessions if modelchoices.
for irun = 1:orig_cfg1.runs
  %  tauA(irun) = paramFits(irun).taufits(1);
    disp(irun)
    if cfg1.modelchoices
        load(cfg1.path)
        %For each simulation parameter pair, use that as starting point.
        paramFits=paramFits(irun);
        cfg1.runs=irun;
    else
        if cfg1.numparameter =='2'
            load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/%s.mat',cfg1.path(1:3)))

        elseif cfg1.numparameter =='1'
            load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/1params/%s.mat',cfg1.path(1:3)))

        else
            load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/%s.mat',cfg1.path(1:3)))
        end
    end

    a(:,1)=paramFits.betafits;
    a(:,2)=paramFits.taufits;
    a(:,3)=paramFits.lsfits;


    for iparampairs = 1:1%length(paramFits.betafits)

        if cfg1.numparameter =='2'
                    [xbest,fx,exitflag,output] = fminsearchbnd(['handle_fmin_parameterfits'],...
            [a(iparampairs,1) a(iparampairs,2)],[0.0015 1],[2 20],opts,cfg1);
        elseif cfg1.numparameter =='1'
                    [xbest,fx,exitflag,output] = fminsearchbnd(['handle_fmin_parameterfits'],...
            [a(iparampairs,2)],[1],[20],opts,cfg1);

        else
            %FunctionNameAsString, I can only assume to be my model function.
            cfg1.sim_task=0
            [xbest,fx,exitflag,output] = fminsearchbnd(['handle_fmin_parameterfits'],...
                [a(iparampairs,1) a(iparampairs,2) a(iparampairs,3) ],[0.0015 1 0],[2 20 1],opts,cfg1);
        end
        %Store the outcome, and starting point

        optimizedFits(iparampairs).startfit=a(iparampairs,:);
        optimizedFits(iparampairs).xbest=xbest;
        optimizedFits(iparampairs).output=output;
        optimizedFits(iparampairs).MLE=fx;


    end
    %Store all bestfits equal to the number of parameter pairs that were used.
    outputfilen=sprintf('%s%i%s',cfg1.outputfile(1:end-4),irun,cfg1.outputfile(end-3:end));

    save(outputfilen,'optimizedFits','-v7.3');

end

%%





end
