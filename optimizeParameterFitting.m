
%---------------------------------------------------------
%Attempting new parameter fit procedure using fmnisearch 
%---------------------------------------------------------
clear

%Code from konstantinos:
opts = optimset('Display','iter','TolX',1e-15,'TolFun',1e-15,'MaxIter',1000,'MaxFunEvals',20000);

load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated/AWi.mat')

a(1)=paramFits.betaPLAfits(1);
a(2)=paramFits.tauPLAfits(1);
a(3)=paramFits.lsPLAfits(1);

%FunctionNameAsString, I can only assume to be my model function. 
[xbest,fx,exitflag,output] = fminsearchbnd(['handle_fmin_parameterfits'],...
    [a(1) a(2) a(3) ],[0.1 1 0],[2 20 1],opts,path);


 




