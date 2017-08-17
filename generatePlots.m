%Generate plots for time frequency.

%Load all the sessions as response-locked and stimulus-locked
[ fullMatrixR,fullMatrixS,fullMatrixC ] = loadFullMatrixResp;
%Also load one response freq strct to get the labels for sensors. And time
%points...
resp=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/resp/AWi_d01_250_type1event2_totalpow_freq16.mat');
stim=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/stim/AWi_d01_250_type1event2_totalpow_freq16.mat');
cue =load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/freq/short/low/AWi/20151007/cue/AWi_d01_250_type1event2_totalpow_freq16.mat');
%Load all the sessions as stimulus-locked



%%
%Get sensors for each sensor group:
sensR = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
         'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
         'MRF54','MRF55','MRF56','MRF66','MRF46'};
sensL = {'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
         'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
         'MLF54','MLF55','MLF56','MLF66','MLF46'};
[~,idxR]=intersect(resp.freq.grad.label,sensR);
[~,idxL]=intersect(resp.freq.grad.label,sensL);
idxLR = [idxL idxR];


%%
%Plot the average for each sensor group and for each button press. 
figure(1)
plotT={'Left motor sensor group, Left button press','Left motor sensor group, Right button press';'Right motor sensor group, Left button press','Right motor sensor group, Right button press'};

xplot=1;

for isensG=1:2

    for ibutG=1:2
        
        
        timestart = 25;
        timestop  = 90;
        
        subplot(4,1,xplot)
        
        %Squeezing removes both 1-dimensions. Keep in mind if looking at 1
        %participants. 
        data=squeeze(nanmean(fullMatrixR.powsptrcm(:,ibutG,idxLR(:,isensG),1:end,timestart:timestop),3)); 
        
        x = resp.freq.time(timestart:timestop);%21:end-42
        y = resp.freq.freq(1:end);
        
        %plot contra vs ipsi:
        
        clims=[-60 -20];
        
        
        imagesc(x,y,squeeze(nanmean(data,1)),clims) %insert clims
        
        %Comment out for more than one participant. 
        %imagesc(x,y,((data)),[-40 40]) %testing removing mean
        
        set(gca,'YDir','normal')
        colorbar
        
        title(plotT(isensG,ibutG))
        
        xplot=xplot+1;
        
    end
end


%%
%Appending the reponse-locked and stimulus-locked data.

stimStart =31;
stimStop  =100;
respStart =40;
respStop  =92;
cueStart  =10;
cueStop   =65;

wholeFM = cat(5,fullMatrixS.powsptrcm(:,:,:,:,stimStart:stimStop),fullMatrixC.powsptrcm(:,:,:,:,cueStart:cueStop),fullMatrixR.powsptrcm(:,:,:,:,respStart:respStop));
%%
%all the short data put together

stimStart =10;
stimStop  =21;
respStart =23;
respStop  =31;
cueStart  =1;
cueStop   =12;

%just add whole range
wholeFM = cat(5,fullMatrixS.powsptrcm(:,:,:,:,stimStart:stimStop),fullMatrixC.powsptrcm(:,:,:,:,cueStart:cueStop),fullMatrixR.powsptrcm(:,:,:,:,respStart:respStop));


%%
%Generate contra vs ipsi plot
%Figure 2b. Buildup of choice-predictive...

figure(4)
subplot(2,1,2)
plotT={'Left motor sensor group, Left button press','Left motor sensor group, Right button press';'Right motor sensor group, Left button press','Right motor sensor group, Right button press'};

        fullMatrix = wholeFM;

        startT=1;
        stopT =262;
        
        %data11, left response with left sensors
        data11=squeeze(nanmean(fullMatrix(:,1,idxLR(:,1),1:end,1:end),3));
        %data21, right response with left sensors
        data21=squeeze(nanmean(fullMatrix(:,2,idxLR(:,1),1:end,1:end),3));
        %data12, left response with right sensors
        data12=squeeze(nanmean(fullMatrix(:,1,idxLR(:,2),1:end,1:end),3));
        %data22, right response with right sensors 
        data22=squeeze(nanmean(fullMatrix(:,2,idxLR(:,2),1:end,1:end),3));

        timeX = [stim.freq.time(stimStart:stimStop) cue.freq.time(cueStart:cueStop) resp.freq.time(respStart:respStop)];
        x = 1:length(timeX);%linspace(-0.025,size(fullMatrix,5)*0.025-1,size(fullMatrix,5)); %[stim.freq.time(startT):0.025:5.525]; %[stim.freq.time(31:85) resp.freq.time(50:92)]%
        y = stim.freq.freq(1:end);
          dataL=data21-data11;
        dataR=data12-data22;
        
        avgData=dataR+dataL;      
    
        imagesc(x,y,squeeze(nanmean(avgData./2,1)),[-14 14])
             
        indX = find(timeX==0);
        indX2= find(timeX==-0.2);
        indX3= find(timeX==0.5);
        indX4= find(timeX==0.3);
        indX=[indX indX2 indX3 indX4];
        
        %indX+5
        %indX-5
        
        %indX = [indX    indX(2)-20  ];
        indX = sort(indX);
        set(gca,'YDir','normal')
        set(gca,'XTick',[x(indX)])
        set(gca,'XTickLabel',timeX(indX))
        
        %Create a lines seperating the three plots
        line([x(stimStop-stimStart)+2 x(stimStop-stimStart)+2],get(gca,'Ylim'),'Color',[1 1 1],'LineWidth',10)
        line([(x(stimStop-stimStart)+2)+(cueStop-cueStart) (x(stimStop-stimStart)+2)+(cueStop-cueStart)],get(gca,'Ylim'),'Color',[1 1 1],'LineWidth',10)
        %ylim([-8 8])
        %colorbar
        xlabel('Time (s) relative to event')

        %title('Contra vs. Ipsi')
        
        %xplot=xplot+1;

        %%
        %test plot cue-locked data. 
        

        figure(1),clf
        %data11, left response with left sensors
        data11=squeeze(nanmean(fullMatrixC.powsptrcm(:,1,idxLR(:,1),1:end,1:end),3));
        %data21, right response with left sensors
        data21=squeeze(nanmean(fullMatrixC.powsptrcm(:,2,idxLR(:,1),1:end,1:end),3));
        %data12, left response with right sensors
        data12=squeeze(nanmean(fullMatrixC.powsptrcm(:,1,idxLR(:,2),1:end,1:end),3));
        %data22, right response with right sensors 
        data22=squeeze(nanmean(fullMatrixC.powsptrcm(:,2,idxLR(:,2),1:end,1:end),3));

        x = cue.freq.time(1:end);%linspace(-0.025,size(fullMatrix,5)*0.025-1,size(fullMatrix,5)); %[stim.freq.time(startT):0.025:5.525]; %[stim.freq.time(31:85) resp.freq.time(50:92)]%
        y = cue.freq.freq(1:end);
          dataL=data21-data11;
        dataR=data12-data22;
        
        avgData=dataR+dataL;      
        colormap default
        imagesc(x,y,squeeze(nanmean(avgData./2,1)),[-9 9])
        set(gca,'YDir','normal')

       colorbar
        
        title('Contra vs. Ipsi cue-locked')
        
        
        %response
        

        figure(2),clf
        %data11, left response with left sensors
        data11=squeeze(nanmean(fullMatrixS.powsptrcm(:,1,idxLR(:,1),1:end,1:end),3));
        %data21, right response with left sensors
        data21=squeeze(nanmean(fullMatrixS.powsptrcm(:,2,idxLR(:,1),1:end,1:end),3));
        %data12, left response with right sensors
        data12=squeeze(nanmean(fullMatrixS.powsptrcm(:,1,idxLR(:,2),1:end,1:end),3));
        %data22, right response with right sensors 
        data22=squeeze(nanmean(fullMatrixS.powsptrcm(:,2,idxLR(:,2),1:end,1:end),3));

        x = stim.freq.time(1:end);%linspace(-0.025,size(fullMatrix,5)*0.025-1,size(fullMatrix,5)); %[stim.freq.time(startT):0.025:5.525]; %[stim.freq.time(31:85) resp.freq.time(50:92)]%
        y = stim.freq.freq(1:end);
          dataL=data21-data11;
        dataR=data12-data22;
        
        avgData=dataR+dataL;      
        colormap default
        imagesc(x,y,squeeze(nanmean(avgData./2,1)),[-9 9])

        set(gca,'YDir','normal')

       colorbar
        
        title('Contra vs. Ipsi stim-locked')
        
        %stim
        
        

        figure(3),clf
        %data11, left response with left sensors
        data11=squeeze(nanmean(fullMatrixR.powsptrcm(:,1,idxLR(:,1),1:end,1:end),3));
        %data21, right response with left sensors
        data21=squeeze(nanmean(fullMatrixR.powsptrcm(:,2,idxLR(:,1),1:end,1:end),3));
        %data12, left response with right sensors
        data12=squeeze(nanmean(fullMatrixR.powsptrcm(:,1,idxLR(:,2),1:end,1:end),3));
        %data22, right response with right sensors 
        data22=squeeze(nanmean(fullMatrixR.powsptrcm(:,2,idxLR(:,2),1:end,1:end),3));

        x = resp.freq.time(1:end);%linspace(-0.025,size(fullMatrix,5)*0.025-1,size(fullMatrix,5)); %[stim.freq.time(startT):0.025:5.525]; %[stim.freq.time(31:85) resp.freq.time(50:92)]%
        y = resp.freq.freq(1:end);
          dataL=data21-data11;
        dataR=data12-data22;
        
        avgData=dataR+dataL;      
        colormap default
        imagesc(x,y,squeeze(nanmean(avgData./2,1)),[-9 9])

        set(gca,'YDir','normal')

       colorbar
        
        title('Contra vs. Ipsi resp-locked')

%% Save figure
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
print('ContraVSipsi1stSetBOTH','-dpdf') %epsc2




