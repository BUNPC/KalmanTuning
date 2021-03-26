%% Initializes paths for FB-SOW2 project


% personalized ID (for stream identification etc)
paths.ID = 'X';

%current folder
cdir=fileparts(mfilename('fullpath'));
wdir=fileparts(cdir);
addpath(genpath(wdir))

% % DATASETs path (preliminary and main experimental data)
paths.data = [wdir,filesep,'DATA'];
% % sprint folders 
% paths.dataSprintf = {'', 'Sprint2\', 'Sprint3\', 'Sprint4\', 'Sprint5\', 'Sprint6\', 'Sprint7\', 'Sprint8\', 'Sprint9\'};
% % subject IDs and folders
for ss = 1:99; paths.dataSbjID{ss} = ['FB_Sbj' num2str(ss)]; end
% paths.dataFtappingf = '\FINGER_TAPPING\';
% paths.dataRestingf = '\RESTING\';
% paths.dataBehavf = 'BEHAVIORAL\';
% paths.dataEEGf = 'EEG\';
% paths.datafNIRS1kf = 'FNIRS-NIRS1k\';
% paths.datafNIRScwf = 'FNIRS-CW\';
% paths.dataFsuffixFtapping = '_motion';
% paths.dataFsuffixFtappingTraining = '_motion_training';
% paths.dataFsuffixFtappingFeedback = '_motion_feedback';
% paths.dataFsuffixResting = '_resting';
% % synch data
% paths.synchAnalysisf = 'SynchPrecision';
% % offline analysis
% paths.offlanalysis = 'Offline_analysis\';
% 
% % bbci toolbox paths
paths.bbciDir = [wdir,filesep,'dependencies',filesep,'bbci'];
% addpath(genpath(paths.bbciDir))
% 
% % data acquisition paths
paths.bbciDataDir = [wdir,filesep,'data',filesep,'temp'];
paths.bbciTmpDir = [wdir,filesep,'data',filesep,'temp',filesep,'tmp'];
% 
% % homer2 toolbox paths
% paths.homerDir = 'C:\Users\Antonio\Documents\MATLAB\work\BU\boas lab\homer2_src_v2_3_10202017\';
% addpath(genpath(paths.homerDir))
% 
% % project files and code path
paths.ProjectDir = [wdir,'\'];
addpath(genpath(paths.ProjectDir))
% 
% % LSL paths
% paths.LslDir = 'C:\Users\Antonio\Documents\MATLAB\work\BU\boas lab\rtfNIRS\liblsl-Matlab';
% addpath(genpath(paths.LslDir))
% 
% % simulated HRF and data path
% paths.simulDir = 'simul\';
% paths.simulDataDirFinal = 'simul\data_hybrid\';
% paths.simulDataDirEEG = 'simul\EEG\data\';
% paths.simulDataDirfNIRS = 'simul\fNIRS\data\';
% paths.fnirsRestData = 'resting_sbj98.nirs';
% paths.eegFingerTapData1 = 'EEG_EOG_left_right_final.mat';
% paths.eegFingerTapData2 = 'eeg_tLvsRvsRest_EOG.mat';
% paths.eogSrcData1 = 'tLvsR_EOG_src_final.mat';
% paths.eogSrcData2 = 'tLvsR_EOG_src.mat';
% paths.hybridSimulData1= 'simEEGfNIRS_LvR_EOG_final.mat';
% paths.hybridSimulData2= 'simEEGfNIRS_LvR_EOG.mat';
% paths.hybridtCCAData= 'simEEGfNIRS_tCCA.mat';
% paths.simHrf = 'hrf_simdat_100.mat';
% 
% % analysis folder and temp data
% paths.analysisDir = 'analysis\';
% paths.analysisTempData = 'tmp_data';
% 
