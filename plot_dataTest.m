

%Plot the data

figure(1),clf
hold on;
for currentTrial=1:size(freq.powspctrm,1)
    for currentFreq=1:size(freq.powspctrm,3)

    plot(nanmean(squeeze(freq.powspctrm(currentTrial,:,33,40))),currentTrial,'o');
    
%     if isnan(val)
%         a=1;
%     else
%         disp(currentFreq)
%         disp(currentTrial)
%     end
    end
end