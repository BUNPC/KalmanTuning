function [bbci, data]= fb_bbci_calibrate_nirs_advanced_extended_eval(bbci, data)
%fb_bbci_calibrate_nirs_advanced - Calibrate fNIRS data for BBCI
%
% by Alexander von Lühmann 2020, avolu@bu.edu

%
%This function is called by fb_final_offlineCLA_extended_kalman_ProcessfNIRS

%Synopsis:
% [BBCI, DATA]= bbci_calibrate_NIRS_tiny(BBCI, DATA)
%
%Arguments:
%  BBCI -  the field 'calibrate.settings' holds parameters specific to
%          calibrate NIRS-based BCI processing.
%  DATA -  holds the calibration data
%
%Output:
%  BBCI - Updated BBCI structure in which all necessary fields for
%     online operation are set, see bbci_apply_structures.
%  DATA - As input.
%

default_clab=  {'*'};
default_model= {@train_RLDAshrink, 'Gamma', 'auto', 'StoreMeans',1, 'Scaling',1};

props= {'clab'       default_clab    'CELL{CHAR}'
    'train_ival'   []     '!DOUBLE[1 2]'
    %  'n_ivalCuts'    1
    'ref_ival'   [-2000 0]     '!DOUBLE[1 2]'
    'doLowpass'  true          '!BOOL'
    'lpCutoff'   0.5            '!DOUBLE'
    'nChan'     []      '!DOUBLE'
    'doHighpass'  true          '!BOOL'
    'hpCutoff'   0.01            '!DOUBLE'
    'doOnlineBLremoval'     false   '!BOOL'
    'doOfflineBLremoval'    true    '!BOOL'
    'model'      default_model   'FUNC|CELL'
    'fnirsChIdx'   '*'              'CHAR'
    'doPCA'     []           '!DOUBLE'
    'reject_artifacts'    1     '!BOOL'
    'reject_channels'    1      '!BOOL'
    'rem_outliers'  0           '!BOOL'
    'SD'            []      '!STRUCT'
    'visSignals'    true    '!BOOL'
    };
opt= opt_setDefaults('bbci.calibrate.settings', props);




%% Feature Extraction & Train classifier for fNIRS
%select channels
cnt_sel = proc_selectChannels(data.cnt, opt.fnirsChIdx);

%% Identify and reject bad channels and trials
[rChIdx, rTrials] = fb_fnirsRejectChTrials(data.cnt, data.mrk, opt.SD, opt.reject_channels, opt.reject_artifacts);
if opt.reject_artifacts
    bbci_log_write(data, 'Rejected: %d trial(s).', length(rTrials));
    BC_result.rejected_trials= rTrials;
end
if opt.reject_channels
    bbci_log_write(data, 'Rejected channels: <%s>', str_vec2str(rChIdx));
    BC_result.rejected_clab= rChIdx;
    % update channel list for training
    if ~isempty(rChIdx)
        cnt_sel = proc_selectChannels(cnt_sel, 'not', cnt_sel.clab(str2double(rChIdx)));
    end
end

%% Convert Intensity to Optical Density


% Index_Int = find(contains(data.cnt.clab,'INT'));
% for i = Index_Int
%     data.cnt.x(:,i) = hmrIntensity2OD(data.cnt.x(:,i));
% end
% cnt_sel.x=data.cnt.x(:,opt.fnirsChIdx);

%% save signal
cnt_selbuf = cnt_sel;


%for all window sizes
for ww = 1:size(opt.train_ival,1)
    %for all Lp filter settings
    for ll = 1:numel(opt.lpCutoff)
        %for all Channel reduction settings
        for nn = 1:numel(opt.nChan)
            % restore from buffer
            cnt_sel = cnt_selbuf;
            
            % filtering
            if opt.doHighpass
                fprintf('Highpass filtering signal\n')
                [filtHP_b,filtHP_a]=butter(3, opt.hpCutoff*2/data.cnt.fs,'high');
                cnt_sel = proc_filtfilt(cnt_sel,filtHP_b,filtHP_a);
            end
            if opt.doLowpass
                fprintf('Lowpass filtering signal\n')
                [filtLP_b,filtLP_a]=butter(3, opt.lpCutoff{ll}*2/data.cnt.fs,'low');
                cnt_sel = proc_filtfilt(cnt_sel,filtLP_b,filtLP_a);
            end
            
            %% do the windowed evaluation
            for ii = 1:size(opt.train_ival,2)
                %% segment epochs
                fv= proc_segmentation(cnt_sel, data.mrk, [opt.ref_ival(1) opt.train_ival{ww,ii}(2)]);
                % reject bad trials
                fv = proc_selectEpochs(fv, 'not', rTrials);
                % baseline correct
                if opt.doOfflineBLremoval
                    fv= proc_baseline(fv, opt.ref_ival, 'channelwise', 1);
                end
                fvsig = fv;
                % feature (mean) calculation
                fv= proc_jumpingMeans(fv, opt.train_ival{ww,ii});
                
                %% plot signals for sanity check
                if opt.visSignals
                    figure
                    opt.PlotStat = 'sem';
                    nCH = size(fvsig.x,2);
                    for ii=1:nCH
                        subplot(2,nCH/2,ii)
                        plot_channel(fvsig, ii, opt);
                    end
                end
                
                % detect and reject outlier trials (aims to remove early trials that suffer from MA HP)
                if opt.rem_outliers
                    olidx = isoutlier(mean(squeeze(fv.x)));
                    fv = proc_selectEpochs(fv, ~olidx);
                    disp([num2str(sum(olidx)) ' outlier trials removed']);
                end
                
                %select channels and chromophores (CURRENTLY NOT WITHIN CV - for online calibration OK!)
                if ~isempty(opt.nChan{nn})
                    r2 = proc_rSquareSigned(fv);
                    %select channels
                    [m,i] = sort(abs(fv.x),'descend');
                    fv = proc_selectChannels(fv, i(1:opt.nChan{nn}));
                end
                % save selected channels
                bbci.csel{ww,ii,ll,nn} = fv.clab;
                
                disp(['Perform CV.. iteration  #' num2str(ii)])
                
                folds = 10;
                % check number of available trials and adapt folds
                nt1 = sum(fv.y(1,:));
                nt2 = sum(fv.y(2,:));
                if  nt1 < folds || nt2 < folds
                    folds = min(nt1,nt2)-2;
                end
                opt_xv= struct('SampleFcn',  {{@sample_chronKFold, folds}});
                
                if ~isempty(opt.doPCA)
                    %% 10fold chron crossvalidation with PCA (inside CV)
                    disp(['Performing PCA feature dimensionality reduction to ' num2str(opt.doPCA) '% of Variance in the data.'])
                    % pca variance threshold
                    varThresh = opt.doPCA;
                    proc.train= {{'PCADat', @fb_pcaDimRedTrain, varThresh}
                        };
                    proc.apply= {{@fb_pcaDimRedApply, '$PCADat'}};
                    [loss,loss_std, ~, stats]= crossvalidation_extended(fv, opt.model, opt_xv, ...
                        'Proc', proc);
                else
                    %% 10fold chron. Crossvalidation
                    [loss,loss_std, ~, stats]= crossvalidation_extended(fv, opt.model, opt_xv);
                end
                %                 [fvbuf, pcaDat] = fb_pcaDimRedTrain(fv, 95);
                %                 [fv] = fb_pcaDimRedApply(fv, pcaDat);
                
                
                %% Calc metrics and save results
                % save CV result
                data.loss(ww,ii,ll,nn) = loss;
                % save other metrics
                %                 data.TP(ww,ii,ll,nn,:,:)= stats.TP;
                %                 data.FP(ww,ii,ll,nn,:,:)= stats.FP;
                %                 data.TN(ww,ii,ll,nn,:,:)= stats.TN;
                %                 data.FN(ww,ii,ll,nn,:,:)= stats.FN;
                TPg = sum(stats.TP(:));
                FPg = sum(stats.FP(:));
                TNg = sum(stats.TN(:));
                FNg = sum(stats.FN(:));
                data.TPg(ww,ii,ll,nn)= TPg;
                data.FPg(ww,ii,ll,nn)= FPg;
                data.TNg(ww,ii,ll,nn)= TNg;
                data.FNg(ww,ii,ll,nn)= FNg;
                data.F1g(ww,ii,ll,nn)= 2*TPg / (2*TPg + FPg + FNg);
                data.precisiong(ww,ii,ll,nn)= TPg/(TPg+FPg);
                data.sensitivityg(ww,ii,ll,nn)= TPg/(TPg+FNg);
                data.specificityg(ww,ii,ll,nn)= TNg/(TNg+FPg);
                % save single trial data (but only for previously identified optimal time intervall)
                if ii == 57 %11.4s
                    data.fvsig(ww,ll,nn)= fvsig;
                end
                % save single trial features
                data.fv(ww,ii,ll,nn)= fv;
                
            end
        end
    end
end
