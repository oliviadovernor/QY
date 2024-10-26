%EEM plot code taking data from the Horiba Duetta and plotting a surface
%plot

wd = uigetdir('C:Users');
cd(wd)

%Import files for sample dye
EEMFiles = dir('**/TableHeaderData_OJD01_5uM_CB[8]_2(1).txt');
EEMFileName = fullfile(EEMFiles.folder, EEMFiles.name);
SampleData = importdata(EEMFileName);

% %Import files for CB-complexed dye
% EEMFiles = dir('**/TableHeaderData_CB8_5uM_EEM.txt');
% EEMFileName = fullfile(EEMFiles.folder, EEMFiles.name);
% SampleData_CB8 = importdata(EEMFileName);

%Need to get rid of all NaN
EMData = rmmissing(SampleData.data(:,1:72));
%EMData_CB = rmmissing(SampleData_CB8.data(:,1:72));
%AbsData = SampleData.data(:,47);

x = EMData(:,1);
y = transpose(SampleData.data(1,2:72));
z = transpose(EMData(1:end,2:end));
z(z<0) = 0; %All negative values are replaced with 0

% figure();
figure('units','normalized','outerposition',[0 0 1 1])
h = surf(x,y,z, 'FaceColor','interp');
view(2);
set(h,'LineStyle','none');
xlabel('Emission Wavelength / nm');
ylabel('Excitation Wavelength / nm');
zlabel('Intensity / -');
xlim([250 800]);
ylim([250 600]);
zlim([0 500]);
colormap('default');
c = colorbar('eastoutside');
c.Label.String = 'Intensity';
box on;
pbaspect([1 1 1]);
ax = gca;
h.LineWidth = 5;
ax.LineWidth = 5;
set(gca,'FontSize',32);
set(gca,'color','w');
set(gcf,'color','w');

% %Calculate Integrated Emission over certain range
% EM485 = EMData(:,5);
% EM405 = EMData(:,21);
% 
% xmin = 500;
% xmax = 800;
% 
% int_min = min(find(EMData(:,1) > xmin));
% int_max = max(find(EMData(:,1) <= xmax));
% int_region_405 = EM405(int_min:int_max,:);
% I_int_405 = trapz(int_region_405);
% int_region_485 = EM485(int_min:int_max,:);
% I_int_485 = trapz(int_region_485);
%
print('OJD01_2.1 ratio-z','-dpng')