%% Performs offline classification latency analysis (CLA),
%% extended by additional metrics precision, sensitivity, specificity, F1 and export of single trial signals
% by Alexander von Lühmann, avolu@bu.edu, 2020
% adapted by Antonio Ortega, aortegam@bu.edu 2021



flags.mode.Sprint=10;
flags.mode.Part=1;
flags.mode.Variation=1;

%initialize paths and system configuration
%cd('D:\Office\Research\Software - Scripts\Matlab\BU-FB-SOW2\util')
%fb_paths_init_avl_laptop;
paths_init; 

% initialize BBCI toolbox
cd(paths.bbciDir);
startup_bbci_toolbox('DataDir', paths.bbciDataDir, 'TmpDir',paths.bbciTmpDir);
BTB.TypeChecking=0;




% define classes to investigate
classes = {{1, 2;'Action Left','Action Right'}, {3, 4;'Imagery Left','Imagery Right'}};

% define feature extraction intervals
% fnirsIval = [0 16000];%[5000 16000];
fnirsBL = [-2000 0];

% which way of windowed analysis?
% wdwtype = 1; % increasing time window
wdwtype = 2; % sliding wdw s time window

% parameters to evaluate
wdw_nirs = {3};%{1,2,3,4,5};
nirsLpFc = {.1};%{.1, .5, 5, 10};
nirsNch = {[]};%;{[], 10, 6};

%% ********** fNIRS ***************
%% process for each subject
for sbj = sublist
    disp(['Evaluating NIRS Subject ' num2str(sbj)])
    
    %for all window sizes
    for ww = 1:numel(wdw_nirs)
        switch wdwtype
            case 1
                for ii= 1:90
                    fnirsIval{ii} = [0 ii*200];
                end
            case 2
                for ii= 1:90
                    fnirsIval{ww,ii} = [(ii-1)*200 (ii-1)*200+wdw_nirs{ww}*1000-1];
                end
        end
    end
    
    %add filename paths for subject
    paths=fb_paths_addSbjFnames(paths,sbj);
    
    % for both tasks
    for cc = 1:2
        % for all interval settings [0 ii*200ms]
        disp(['Subj ' num2str(sbj) ' task ' num2str(cc)])
        
        % init config
        flags.mode.type= 'expProcPcTrain';
        flags.mode.sbj = sbj;
        %state = fb_cnfg_init(paths, flags.mode);
        load('state.mat','state')
        % folder and files
        %calibfolder = [paths.bbciDataDir '\sprint 4 with Kalman\'];
        calibfolder = fullfile(paths.bbciDataDir, paths.dataSbjID{sbj});

        
        %% do CV for the fNIRS stream:
        BC= [];
        BC.fcn= @fb_bbci_calibrate_nirs_advanced_extended_eval;        
        BC.settings.fnirsChIdx = state.fnirsLSChIdx;        
        BC.folder= calibfolder;
        BC.file= paths.calFname;
        BC.marker_fcn= @mrk_defineClasses;
        BC.marker_param = {classes{cc}};
        % feature specific settings
        BC.settings.train_ival = fnirsIval;
        BC.settings.ref_ival = fnirsBL;
        BC.settings.visSignals = false;
        BC.settings.doLowpass = true;
        BC.settings.lpCutoff = nirsLpFc;
        BC.settings.doHighpass = false;
        BC.settings.hpCutoff = [];
        BC.settings.doOfflineBLremoval = true;
        BC.settings.nChan = nirsNch;
        BC.settings.reject_artifacts = true;
        BC.settings.reject_channels = true;
        BC.settings.rem_outliers = false;
        BC.settings.SD = state.fnirs.SD;
        % perform calibration
        bbci_nirs= struct('calibrate', BC);
        [bbci_nirs, data_nirs]= bbci_calibrate(bbci_nirs);
        % save cv results
        stats.loss(sbj,cc,:,:,:,:) = data_nirs.loss;
        %stats.TP(sbj,cc,:,:,:,:,:,:) = data_nirs.TP;
        %stats.FP(sbj,cc,:,:,:,:,:,:) = data_nirs.FP;
        %stats.TN(sbj,cc,:,:,:,:,:,:) = data_nirs.TN;
        %stats.FN(sbj,cc,:,:,:,:,:,:) = data_nirs.FN;
        stats.F1g(sbj,cc,:,:,:,:) = data_nirs.F1g;
        stats.precisiong(sbj,cc,:,:,:,:) = data_nirs.precisiong;
        stats.sensitivityg(sbj,cc,:,:,:,:) = data_nirs.sensitivityg;
        stats.specificityg(sbj,cc,:,:,:,:) = data_nirs.specificityg;
        % save single trial signals
        data.fvsig(sbj,cc,:,:,:)= data_nirs.fvsig;
        % save single trial features
        data.fv(sbj,cc,:,:,:,:)= data_nirs.fv;
    end
end
%%
% save results

cloudDir = 'C:\Users\Antonio\Documents\MATLAB\work\BU\boas lab\rtfNIRS\BU-FB-SOW2\Sprint10\results_data';
%cloudDir = 'C:\Users\Alex\Google Drive (avolu@bu.edu)\Facebook_SOW2\Sprint7\results_data';
save(fullfile([wdir,filesep,'results'], 'claResExt', 'cv_results_kalman_nirs_extended.mat'), 'stats', 'data')

disp('data saved.')


