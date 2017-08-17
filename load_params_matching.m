function [ newtaufit,newbetafit,newlsfit,end1taufit ] = load_params_matching( ~ )

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


end

