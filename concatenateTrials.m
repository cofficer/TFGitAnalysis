function [ conTrials ] = concatenateTrials( participantID, preFreq )
%Combine all trials from a single sessions per particpant. Either data
%which has been preproceed or TF analysed. Loop over blocks and trials. 

%Use participant ID and data of session to change to correct directory. 


%Move to path for either preprocessed or frequency data. 

switch preFreq 
    case 'freq' 
        path            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/low/%s/baseline/',participantID);
        cd(path)
        %Store name of block file. 
        load_dir  = dir('*.mat');%Think its better to baseline on everything.
        
        
        
    case 'pre'
        path            = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/preprocessed/%s/',participantID);
        cd(path)
        %Store name of block file. 
        load_dir  = dir('*resp_b*.mat');
        %Potential issue here is if I want to have seperate baseline for
        %left or righ trials. Does not seem necessary. 
end


%Loop over all blocks to load and concatenate the trials.
for iblock = 1: length(load_dir)
    mesB   = sprintf('Currently concatenating trials from block %d out of %d\n\n' ,iblock, length(load_dir));
    disp(mesB)  
    %Need to be treated differetly depending on the freq or pre data.
    switch preFreq
        case 'pre'
            
            data      = load(load_dir(iblock).name);
            
            data      = data.data;
            
            if iblock  == 1
                
                %In the first loop store all the fields.
                dataAll       = data;
                
                %Starting with the second loop only add trials.
            else
                dataAll.trial = cat(1,dataAll.trial,data.trial);
            end
            
        case 'freq'
                        
            freq      = load(load_dir(iblock).name);
            
            freq      = freq.freq;
            
            if iblock  == 1
                
                %In the first loop store all the fields.
                freqAll       = freq;
                
                %Starting with the second loop only add trials.
            else
                freqAll.powspctrm = cat(1,freqAll.powspctrm,...
                                    freq.powspctrm);
            end
            
    end
end

switch preFreq
    case 'freq'
        conTrials = freqAll;
    case 'pre' 
        conTrials = dataAll;
end

