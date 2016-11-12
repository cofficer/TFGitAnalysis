function selectLFI_Tor( cfg1 )

%loading in the total table
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/fullTabeProbC.mat')

%Get all probchoice 
LFIs  = Ttotal.LocalProbChoice(~isnan(Ttotal.LocalProbChoice'));

%divide the data in 4 equal parts, median-split. 
%y=quantile(LFIs,[0 0.4 0.6 1]);

%probability choice level, low-ceil
PBlevel   = cfg1.PBlevel;
% 
% %Select the trial in the proper qunatile of prob choice. 
% if     PBlevel == 1
%     LFI = Ttotal(y(2)>Ttotal.LocalProbChoice & Ttotal.LocalProbChoice>=y(1),:);
% elseif PBlevel == 2
%     LFI = Ttotal(y(4)>Ttotal.LocalProbChoice & Ttotal.LocalProbChoice>=y(3),:);
% end
% 
% [x,idxID] = unique(LFI.ID,'rows');


%sensors for motor cortex
idxLR     = cfg1.idxLR;

for sideBP = 1:2
    
    pathData = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/trialsLowFreq/baselined%s',cfg1.event);
    cd(pathData)
    
    session = cfg1.participant;

    

    if sideBP == 1
        session = sprintf('%s*Left.mat',session);
    elseif sideBP == 2
        session = sprintf('%s*Right.mat',session);
    end
    
    session = dir(session);
    
    f = load(session.name);
    
    if session.name(1:3) == 'LMe'
        session.name='LME';
    end
    %this needs to be matched up with the equivalent table.
    
    
    %Find the correct participant position in the large table. First store
    %the position of the current position in the smaller table for
    %probchoice level. 
    ID = Ttotal.ID;
    ID = cellstr(ID);
    cmID = strcmp(ID,session.name(1:3));
    posID = find(cmID == 1);
    
    %participant table: 
    Tpart = Ttotal(posID,:);

    y=quantile(Tpart.LocalProbChoice,[0 0.4 0.6 1]);

    %Select the trial in the proper qunatile of prob choice.
    if     PBlevel == 1
        LFI = Tpart(y(2)>Tpart.LocalProbChoice & Tpart.LocalProbChoice>=y(1),:);
    elseif PBlevel == 2
        LFI = Tpart(y(4)>Tpart.LocalProbChoice & Tpart.LocalProbChoice>=y(3),:);
    end
    
    %Store the trial numbers.
    %trials = LFI.totalTrials(posID);
    
    %From the same participant there are 262 left BP trials of PLA session
    %It is the trials if they were in order which they arent. They are sorted
    %based on the same button press.
    
    
    
    %select current ID positions from the whole table of trials 
    %ID = Ttotal.ID;
    %ID = cellstr(ID);
    
    %cmID = strcmp(ID,session.name(1:3));
    %pos = find(cmID == 1);
    
    %Subset table of the current participant
    %t = Ttotal(pos,:);
    %t = LFI(posID,:);
    
        %select trials
    %ID = LFI.ID;
    %ID = cellstr(ID);
    
    %cmID = strcmp(ID,session.name(1:3));555
   % pos = find(cmID == 1);

    
    %Find the trials of overlap, its finding all... 
    [interTrials,indT ]= intersect(f.trialinfo(:,2),LFI.stim_onset);
    
    
    %Average the relevant sensors after subtracting the ipsi sensors.
    if sideBP==1
        BPipsi = nanmean(f.powspctrm(indT,idxLR(:,1),:,:),2);
        BPcontra =nanmean(f.powspctrm(indT,idxLR(:,2),:,:),2);
    elseif sideBP ==2
        BPipsi = nanmean(f.powspctrm(indT,idxLR(:,2),:,:),2);
        BPcontra = nanmean(f.powspctrm(indT,idxLR(:,1),:,:),2);
    end
    
    %Get the contra vs ipsi contrast.
    BP = BPcontra-BPipsi;
    
    %Average over trials
    BP = squeeze(nanmean(BP,1));
    
    outfile = sprintf('%s_probChoice_%d_BP%d_%s.mat',session.name(1:3),PBlevel,sideBP,cfg1.event);
    
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/contraipsi/short')
    
    %decide on folder and filenames. 
    save(outfile,'BP')
    
end

%save('BPall','BPall')

end

