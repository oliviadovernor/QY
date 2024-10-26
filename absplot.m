wd = uigetdir('C:Users');
cd(wd)

%Import files for sample dye
AbsEMFiles = dir('**/TableHeaderData_OJD01_H2O_5uM_EEM.txt');

   for k = 1:length(AbsEMFiles)
        AbsEMFileName      = fullfile(AbsEMFiles(k).folder, AbsEMFiles(k).name);
        SampleData{k} = importdata(AbsEMFileName);       
   end
  %SampleAbsData = SampleData{1,1}.data(3:end,3:4);
  %SampleEMData = SampleData{1,1}.data(3:end,1:2);
  
%For EEM files (change final index)
 SampleAbsData = cat(2,SampleData{1,1}.data(3:end,1),SampleData{1,1}.data(3:end,73));
 SampleEMData = cat(2,SampleData{1,1}.data(3:end,1),SampleData{1,1}.data(3:end,66));
  
%Import files for reference dye
% AbsEMRefFiles = dir('**/TableHeaderData_Np14tBu_10uM_CB[7]_20uM_EM.txt');
% 
%    for k = 1:length(AbsEMRefFiles)
%         AbsEMRefFileName      = fullfile(AbsEMRefFiles(k).folder, AbsEMRefFiles(k).name);
%         RefData{k} = importdata(AbsEMRefFileName);     
%    end
%    RefAbsData = RefData{1,1}.data(3:end,3:4);
%    RefEMData = RefData{1,1}.data(3:end,1:2);
  
% %Import files for 2nd reference dye
% AbsEMRef2Files = dir('**/TableHeaderData_Np14tBu_10uM_CB[8]_10uM_EM.txt');
% 
%    for k = 1:length(AbsEMRef2Files)
%         AbsEMRef2FileName      = fullfile(AbsEMRef2Files(k).folder, AbsEMRef2Files(k).name);
%         Ref2Data{k} = importdata(AbsEMRef2FileName);     
%    end
%    Ref2AbsData = Ref2Data{1,1}.data(3:end,3:4);
%    Ref2EMData = Ref2Data{1,1}.data(3:end,1:2);
   
NormSampleAbs = normalize(SampleAbsData(:,2), 'range');
% %NormRefAbs = normalize(RefAbsData(:,2), 'range');
% NormRef2Abs = normalize(Ref2AbsData(:,2), 'range');
NormSampleEM = normalize(SampleEMData(:,2), 'range');
% %NormRefEM = normalize(RefEMData(:,2), 'range');
% NormRef2EM = normalize(Ref2EMData(:,2), 'range');

figure()
h1 = plot(SampleAbsData(:,1),smooth(NormSampleAbs,5), 'DisplayName', 'g Abs'); hold on
%h2 = plot(Ref2AbsData(:,1),smooth(NormRef2Abs,5), 'DisplayName', 'g-CB[8] Abs'); hold on
%h3 = plot(RefAbsData(:,1),smooth(NormRefAbs,5), 'DisplayName', 'g-CB[7] Abs'); hold on
h4 = area(SampleEMData(:,1),smooth(NormSampleEM,5),'LineStyle','--', 'DisplayName', 'g EM'); hold on
%h5 = area(Ref2EMData(:,1),smooth(NormRef2EM,5), 'LineStyle','--', 'DisplayName', 'g-CB[8] EM'); hold on
%h6 = area(RefEMData(:,1),smooth(NormRefEM,5), 'LineStyle','--', 'DisplayName', 'g-CB[7] EM');
h1.Color = [0 0.25 0.25]; 
%h2.Color = [0.3 0 0]; 
%h3.Color = [0 0 0.3];
h4.FaceAlpha = 0.4; h4.FaceColor = [0 0.25 0.25]; h4.EdgeColor = [0 0.25 0.25];
%h5.FaceAlpha = 0.4; h5.FaceColor = [0.3 0 0]; h5.EdgeColor = [0.3 0 0];
%h6.FaceAlpha = 0.4; h6.FaceColor = [0 0 0.3]; h6.EdgeColor = [0 0 0.3];
h1.LineWidth = 2;
%h2.LineWidth = 2;
%h3.LineWidth = 2;
h4.LineWidth = 2;
%h5.LineWidth = 2;
%h6.LineWidth = 2;
xlabel('\lambda / nm');
ylabel('Normalized Absorbance/Emission');
xlim([300 725]);
legend;
pbaspect([1.5 1 1]);
ax = gca;
ax.LineWidth = 2;
set(gca,'FontSize',14);
legend('boxoff');
%legend('Location', 'northeastoutside');
legend('FontSize', 11);
set(gca,'color','w');
set(gcf,'color','w');

%print(gcf, '-dpdf', 'Np26iPr_AbsEM_CB.pdf'); 