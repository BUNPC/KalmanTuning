%% Displays extended statistics of CLA results for fNIRS and EEG
% by Alexander von Lühmann, avolu@bu.edu, 2019


% load results files
rDir = [wdir,filesep,'results',filesep,'claResExt'];
sDir =  [wdir,filesep,'results'];
NIRS = load(fullfile(rDir, 'cv_results_kalman_nirs_extended.mat'));

% parameters that were evaluated:
nirsLpFc = '.1Hz';
nirsNch = 'all';
n_ww = 3; % '3s' nirs window length
e_ww = 4; % '4s' eeg window length;
eegCspBand = '[8 15 | 20 28]';

% classes
classes = {{1, 2;'Overt L','R'}, {3, 4;'Covert L','R'}};

%% Create GROUP summary plots

%accuracy
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    shadedErrorBar1((1:1:size(NIRS.stats.loss,3))/10*2+n_ww, ...
        mean(1-squeeze(NIRS.stats.loss(sublist,cc,:)),1), ...
        std(1-squeeze(NIRS.stats.loss(sublist,cc,:)),1)/sqrt(numel(sublist)), ...
        '-r', 1)
    axis tight
    ylim([.4 1])
    plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Accuracy')
    title({'Group Results Accuracy ',  [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_group_Accuracy.png'))
%%
%precision
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    shadedErrorBar1((1:1:size(NIRS.stats.precisiong,3))/10*2+n_ww, ...
        mean(squeeze(NIRS.stats.precisiong(sublist,cc,:)),1), ...
        std(squeeze(NIRS.stats.precisiong(sublist,cc,:)),1)/sqrt(numel(sublist)), ...
        '-r', 1)        
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Precision')
    title({'Group Results Precision ',  [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_group_Precision.png'))

%sensitivity
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    shadedErrorBar1((1:1:size(NIRS.stats.sensitivityg,3))/10*2+n_ww, ...
        mean(squeeze(NIRS.stats.sensitivityg(sublist,cc,:)),1), ...
        std(squeeze(NIRS.stats.sensitivityg(sublist,cc,:)),1)/sqrt(numel(sublist)), ...
        '-r', 1)
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Sensitivity')
    title({'Group Results Sensitivity ',  [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_group_Sensitivity.png'))

%specificty
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    shadedErrorBar1((1:1:size(NIRS.stats.specificityg,3))/10*2+n_ww, ...
        mean(squeeze(NIRS.stats.specificityg(sublist,cc,:)),1), ...
        std(squeeze(NIRS.stats.specificityg(sublist,cc,:)),1)/sqrt(numel(sublist)), ...
        '-r', 1)
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Specificity')
    title({'Group Results Specificity ',  [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_group_Specificity.png'))

%F1-Score
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    shadedErrorBar1((1:1:size(NIRS.stats.F1g,3))/10*2+n_ww, ...
        mean(squeeze(NIRS.stats.F1g(sublist,cc,:)),1), ...
        std(squeeze(NIRS.stats.F1g(sublist,cc,:)),1)/sqrt(numel(sublist)), ...
        '-r', 1)
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('F1-score')
    title({'Group Results F1-score ',  [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_group_FScore.png'))

%% Create SINGLE SUBJECT summary plots

%median filter order
e_mforder = 5;
n_mforder = 3;

%accuracy
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    t = (1:1:size(NIRS.stats.F1g,3))/10*2;
    for sbj=sublist        
        mtrc_fnirs = medfilt1((1-squeeze(NIRS.stats.loss(sublist,cc,:))),n_mforder);
        plot(t+n_ww, mtrc_fnirs, 'color', rgb('LightSalmon'))           
    end
    plot(t+n_ww, medfilt1(mean(1-squeeze(NIRS.stats.loss(sublist,cc,:)),1),n_mforder), 'LineWidth', 2, 'Color', 'r')
    axis tight
    ylim([.4 1])
    plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('CV cfy accuracy')
    title({'Single Subject Results Accuracy', [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_SS_Accuracy.png'))

%precision
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    t = (1:1:size(NIRS.stats.F1g,3))/10*2;
    for sbj=sublist        
        mtrc_fnirs = medfilt1((squeeze(NIRS.stats.precisiong(sublist,cc,:))),n_mforder);
        plot(t+n_ww, mtrc_fnirs, 'color', rgb('LightSalmon'))           
    end
    plot(t+n_ww, medfilt1(mean(squeeze(NIRS.stats.precisiong(sublist,cc,:)),1),n_mforder), 'LineWidth', 2, 'Color', 'r')    
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Precision')
    title({'Single Subject Results Precision', [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_SS_Precision.png'))

%sensitivity
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    t = (1:1:size(NIRS.stats.F1g,3))/10*2;
    for sbj=sublist                
        mtrc_fnirs = medfilt1((squeeze(NIRS.stats.sensitivityg(sublist,cc,:))),n_mforder);
        plot(t+n_ww, mtrc_fnirs, 'color', rgb('LightSalmon'))           
    end
    plot(t+n_ww, medfilt1(mean(squeeze(NIRS.stats.sensitivityg(sublist,cc,:)),1),n_mforder), 'LineWidth', 2, 'Color', 'r')    
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Sensitivity')
    title({'Single Subject Results Sensitivity', [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_SS_Sensitivity.png'))

%specificity
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    t = (1:1:size(NIRS.stats.F1g,3))/10*2;
    for sbj=sublist        
        mtrc_fnirs = medfilt1((squeeze(NIRS.stats.specificityg(sublist,cc,:))),n_mforder);
        plot(t+n_ww, mtrc_fnirs, 'color', rgb('LightSalmon'))   
    end
    plot(t+n_ww, medfilt1(mean(squeeze(NIRS.stats.specificityg(sublist,cc,:)),1),n_mforder), 'LineWidth', 2, 'Color', 'r')    
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('Specificity')
    title({'Single Subject Results Specificity', [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_SS_Specificity.png'))

%F-score
figure
for cc=1:2
    subplot(1,2,cc)
    hold on
    t = (1:1:size(NIRS.stats.F1g,3))/10*2;
    for sbj=sublist                
        mtrc_fnirs = medfilt1((squeeze(NIRS.stats.F1g(sublist,cc,:))),n_mforder);
        plot(t+n_ww, mtrc_fnirs, 'color', rgb('LightSalmon'))           
    end
    plot(t+n_ww, medfilt1(mean(squeeze(NIRS.stats.F1g(sublist,cc,:)),1),n_mforder), 'LineWidth', 2, 'Color', 'r')    
    axis tight
    ylim([.4 1])
    %plot([0 23],[0.5 0.5], '--k')
    xlim([n_ww-0.5 17.5])
    grid on
    xlabel('time after onset / s')
    ylabel('F1-Score')
    title({'Single Subject Results F1-Score', [classes{cc}{2,1} ' vs ' classes{cc}{2,2}]})
end
saveas(gca, fullfile(sDir, 'fig', 'CLA_SS_FScore.png'))