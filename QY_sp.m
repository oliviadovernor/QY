%%%Relative quantum yield calculation using a single absorbance and
%%%emission spectrum from a sample against a single absorbance and emission
%%%spectrum from a reference standard.
%%%
wd = uigetdir('C:Users');
cd(wd)

%Import files for sample dye
AbsEMFiles = dir('**/TableHeaderData_OJD01_5*.txt');

   for k = 1:length(AbsEMFiles)
        AbsEMFileName      = fullfile(AbsEMFiles(k).folder, AbsEMFiles(k).name);
        SampleData{k} = importdata(AbsEMFileName);
   end
   
   %For EM files
   %SampleAbsData = SampleData{1,1}.data(3:end,3:4);
   %SampleEMData = SampleData{1,1}.data(3:end,1:2);
   
   %For EEM files (change final index)
   SampleAbsData = cat(2,SampleData{1,1}.data(3:end,1),SampleData{1,1}.data(3:end,73));
   SampleEMData = cat(2,SampleData{1,1}.data(3:end,1),SampleData{1,1}.data(3:end,53));
        
%% %Import files for reference dye
AbsEMRefFiles = dir('**/TableHeaderData_OJD01_QuinineSulphate*.txt');

   for k = 1:length(AbsEMRefFiles)
        AbsEMRefFileName      = fullfile(AbsEMRefFiles(k).folder, AbsEMRefFiles(k).name);
        RefData{k} = importdata(AbsEMRefFileName);
   end
    RefAbsData = RefData{1,1}.data(3:end,3:4);
    RefEMData = RefData{1,1}.data(3:end,1:2);
    
NormSampleAbs = normalize(SampleAbsData(:,2), 'range');
NormRefAbs = normalize(RefAbsData(:,2), 'range');
NormSampleEM = normalize(SampleEMData(:,2), 'range');
NormRefEM = normalize(RefEMData(:,2), 'range');

figure()
h2 = area(RefAbsData(:,1),NormRefAbs); hold on
h1 = area(SampleAbsData(:,1),NormSampleAbs); hold on
h4 = area(RefEMData(:,1),NormRefEM,'LineStyle','--'); hold on
h3 = area(SampleEMData(:,1),NormSampleEM, 'LineStyle','--'); 
h1.FaceAlpha = 0.7; h1.FaceColor = [0 0.25 0.25]; h1.EdgeColor = [0 0.25 0.25];
h2.FaceAlpha = 0.7; h2.FaceColor = [0.7 0.7 0.7]; h2.EdgeColor = [0.7 0.7 0.7];
h3.FaceAlpha = 0.4; h3.FaceColor = [0 0.25 0.25]; h3.EdgeColor = [0 0.25 0.25];
h4.FaceAlpha = 0.4; h4.FaceColor = [0.7 0.7 0.7]; h4.EdgeColor = [0.7 0.7 0.7];
xlabel('\lambda / nm');
ylabel('Normalized Absorbance/Emission');
xlim([250 800]);

%Extract absorbance at the chosen excitation wavelength.
prompt = {'Enter chosen excitation wavelength:',...
          'Enter lower wavelength bound for integration of emission band (sample):',...
          'Enter upper wavelength bound for integration of emission band (sample):',...
          'Enter lower wavelength bound for integration of emission band (reference):',...
          'Enter upper wavelength bound for integration of emission band (reference):',...
          'Enter reference standard quantum yield:',...
          'Enter sample solvent refactive index:',...
          'Enter reference solvent refractive index:'};
defaultans = {'340','370','650','370','650','0.54','1.33','1.33'};
dlg_title = 'Input Parameters';
dims = [1 50];
z = inputdlg( prompt , dlg_title , dims, defaultans );
excitation_wavelength = str2num(z{1});

%Find Absorbance at excitation wavelength
[d, ix] = min(abs(SampleAbsData(:,1)-excitation_wavelength));
Abs_sample = [SampleAbsData(ix,2)];

[d, ix2] = min(abs(RefAbsData(:,1)-excitation_wavelength));
Abs_ref = [RefAbsData(ix2,2)];

Abs_sample = Abs_sample.';
Abs_ref = Abs_ref.';

%Calculate integrated fluorescence intensity from emission data (450 to 650
%nm)
xmin = str2num(z{2});
xmax = str2num(z{3});
I_int = [];
int_min = min(find(SampleEMData(:,1) > xmin));
int_max = max(find(SampleEMData(:,1) <= xmax));
int_region = SampleEMData(int_min:int_max,:);
I_int = trapz(int_region(:,2));

xmin_ref = str2num(z{4});
xmax_ref = str2num(z{5});
I_int_ref = [];
int_min_ref = min(find(RefEMData(:,1) > xmin_ref));
int_max_ref = max(find(RefEMData(:,1) <= xmax_ref));
int_region_ref = RefEMData(int_min_ref:int_max_ref,:);
I_int_ref = trapz(int_region_ref(:,2));

I_int_ref=transpose(I_int_ref);

%Calculate Absorption factors for the sample and the reference standard

f_sample = 1-10.^-Abs_sample;
f_ref = 1-10.^-Abs_ref;

%Calculate the photoluminescence quantum yield
Qstd = str2num(z{6});

Qx = Qstd*(I_int/I_int_ref)*(f_ref/f_sample)*(str2num(z{7})^2/str2num(z{8})^2);

fprintf('The relative photoluminescence quantum yield is:\n')
fprintf('Qx = %.3g \n', Qx);