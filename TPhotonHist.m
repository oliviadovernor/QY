filename = 'TotalPhotonLog.txt'; % name of the file
Dir = 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Rh6G\converted'; % absolute or relative path of base directory
cd 'C:\Users\ojd34\OneDrive - University of Cambridge\Desktop\Rh6G\converted'
Sub = dir(fullfile(Dir,'Analysis_txt*')); % common name of subdirectories to look in
X = [Sub.isdir] & ~ismember({Sub.name},{'.','..'});
N = {Sub(X).name}; % conversion of full file name format to cell array for subdirectories
Data = cell(size(N)); % builds array to input data
for k = 1:numel(N)
    T = fullfile(Dir,N{k},filename);
    Data{k} = importdata(T); % imports data into cell array
end

combi = cat(1,Data{1,:}); %combine data into one table
combi = cat(1,combi.data);

%%
% Gain = (1/0.167)*0.95; %Total gain given in ADU/photon
TE = 0.5*0.95*0.95*0.9; %Transmission efficiency
%Bias = 100*4*500;
%tsignalcorr = (combi(:,3)-Bias)/Gain;
%backgdcorr = combi.Background/Gain;
signalcorr = combi(:,5)/TE; %Corrected signal given in photons
%%
signalcorr = combi(:,5);
signalcorr(signalcorr<0) = nan; %to get rid of negative numbers

histmean = nanmean(signalcorr);
sd = std(signalcorr);

pd = fitdist(signalcorr,'Lognormal'); % fit data with exponential to return mean photon number
mean = exp(pd.mu);

h = histfit(signalcorr,40,'Lognormal'); % plot histogram with exponential fit
pbaspect([1 1 1]);
xlabel('Photon Number');
ylabel('Frequency');
h(1).FaceColor = [1 1 1]; %controls the colour in the bars
%xlim([0, 200000]);
%ylim([0, 200]);
% txt = ['mean = ',num2str(mean,'%10.2e')];
% text(1000000,50, txt, 'Color', 'black', 'FontSize', 32);

ax = gca;
set(gca,'XMinorTick','off','YMinorTick','off')
%ax.Box = 'on';
ax.LineWidth = 3;
set(gca,'FontSize',24);
%set(findall(gcf,'type','text'),'FontSize',50);
set(gca,'color','white');
set(gcf,'color','white');

% figure()
% 
% pd2 = fitdist(combi(:,8),'normal'); % fit data with exponential to return mean photon number
% mean_SNR = pd2.mu;
% 
% h = histfit(combi(:,8),40,'normal'); % plot histogram with exponential fit
% pbaspect([1 1 1]);
% xlabel('SNR');
% ylabel('Frequency');
% h(1).FaceColor = [1 1 1]; %controls the colour in the bars
% %xlim([0, 100]);
% %ylim([0, 200]);
% txt = ['mean = ',num2str(mean_SNR)];
% text(45,5, txt, 'Color', 'black', 'FontSize', 32);
% 
% ax = gca;
% set(gca,'XMinorTick','off','YMinorTick','off')
% ax.Box = 'on';
% ax.LineWidth = 7;
% set(gca,'FontSize',40);
% %set(findall(gcf,'type','text'),'FontSize',40);
% set(gca,'color','white');
% set(gcf,'color','white');

