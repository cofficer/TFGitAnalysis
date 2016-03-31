function [ data ] = loadMEGpreproc()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

names=dir('JRu*.mat');

names=names([names.bytes]>60000);

names=names(1);

cfg=[];

for n = 1:length(names)
    disp('loading preprocessed datafile:')
    disp(names(n))
    load(names(n).name);
    if n==1
         dataAll=data;
    elseif n==2
        dataAll=ft_appenddata(cfg,dataAll,data);
    else
        dataAll=ft_appenddata(cfg,dataAll,data);
    end
end
data=dataAll;
clear('dataAll');

disp('Finished loading current preprocessed data')

end

