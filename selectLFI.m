function [ BPall ] = selectLFI( LFI,Ttotal,idxLR )


[x,idxID]=unique(LFI.ID,'rows');

BPall = zeros(33,141,length(idxID),2);cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/trialsLowFreq/baselinedCue')


for sideBP = 1:2
    for loopID = 1:length(idxID)
        
        
        session = LFI.ID(idxID(loopID),:);
        
        if session == 'LME'
            session='LMe';
        end
        if sideBP == 1
            session = sprintf('%s*Left.mat',session);
        elseif sideBP == 2
            session = sprintf('%s*Right.mat',session);
        end
        
        session = dir(session);
        
        f = load(session.name);
        
        
        %this needs to be matched up with the equivalent table.
        
        
        %Find the correct participant position in the lare table.
        ID = LFI.ID;
        ID = cellstr(ID);
        cmID = strncmp(ID,LFI.ID(idxID(loopID),:),3);
        posID = find(cmID == 1);
        
        %Store the trial numbers.
        trials = LFI.totalTrials(posID);
        
        %From the same participant there are 262 left BP trials of PLA session
        %It is the trials if they were in order which they arent. They are sorted
        %based on the same button press.
        
        
        %
        %select trials
        ID = Ttotal.ID;
        ID = cellstr(ID);
        
        
        cmID = strncmp(ID,LFI.ID(idxID(loopID),:),3);
        
        pos = find(cmID == 1);
        
        %Subset table of the current participant
        %tA = Ttotal(pos,:);
        t = LFI(posID,:);
       
        %Trialinfo contains the information of the actual TF data. But the trial
        %numbers are incorrect. If there is a new dataset, it starts over from 1
        %again.
        
        %Store the trial numbers as stored in TF trialfinfo
     % TFntrials = f.trialinfo(:,end);
        
        %Find out where the trial numbers change
      %  [peaksTF,idxTF] = findpeaks(TFntrials');
        
        %Store trial numbers as unorderded from subset table
      %  ntrials = t.trialN;
        
        %Find where the subset table has its peaks
       % [peaks,idx] = findpeaks(ntrials');
        
        
        %for npeak = 1:length(peaks)
        
        %Contains the consecutive trial numbers as present in the TF
        %trialinfo
      %  correctedTFntrials =   TFntrials;
        % Work on his later, by making multiple datasets possible
        % peaks=sort(peaks);
        % for npeaks = 1:length(peaks)
        %
        % correctedTFntrials(idxTF(npeaks)+1:end,1) =   TFntrials(idxTF(npeaks)+1:end,1)+peaks(npeaks);
        % npeaks=1;
        % correctedTFntrials(idxTF(npeaks)+1:idxTF(2),1) =   TFntrials(idxTF(npeaks)+1:idxTF(2),1)+peaks(npeaks);
        % plot(correctedTFntrials)
        %
        % end
%         if length(peaks)==1
%             skips = 1;
%             
%             %On all trial numbers after the peak add the peak number.
%             correctedTFntrials(idxTF+1:end,1) =   TFntrials(idxTF+1:end,1)+peaks;
%             
%             %Insert the correct trial numbers
%             f.trialinfo(:,end)  = correctedTFntrials;
            
            %All left choices that are present in the TF data.
            %Find the overlap in totaltrials
           % [interTrials,indT ]= intersect(t.totalTrials,f.trialinfo(:,end));
            
            
            %All the sample numbers from the TF data
           %f.trialinfo(:,2)
            %All the smple numbers from the table data.
            %t.stim_onset
            
            %Find the trials of overlap
            [interTrials,indT ]= intersect(f.trialinfo(:,2),t.stim_onset);

            
          %  sort(f.trialinfo(indT,end))
         %   sort(f.trialinfo(idxCLFI,end))
%             
% %             t.totalTrials
%             [twV,~] = find(tA.resp_type==20);
%             [twH,~] = find(tA.resp_type==21);
%             
%             indL = sort([twV;twH]);
%             
%             plot(tA.stim_onset(indL)-100000)
%             hold on
%             plot(f.trialinfo(:,2))
            %ylim([17 22])
            
            
         %   TFt  = t(indT,:);
            
            %plot the trials from the different Local fractional incomes.
         %   idxCLFI = ismember(f.trialinfo(:,end),trials);%Highest bin LFI, ceiling
            
            
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
            
            
            %Extract the trials with the relevant LFI.
            BPall(:,:,loopID,sideBP) = BP;
%             
%         else
%             skips =0;
%         end
        disp(sprintf('Current particant: %d out of %d. BP: %d',loopID,length(idxID),sideBP))
    end
end



end

