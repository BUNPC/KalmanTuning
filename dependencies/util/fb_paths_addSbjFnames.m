function [paths] = fb_paths_addSbjFnames(paths,sbj)
%ADDS subject files for bbci execution to paths struct
% bbci loggin files
paths.tccaCalFname = ['tCCA_calib_sbj' num2str(sbj)];
paths.calFname = ['calib_sbj' num2str(sbj)];
paths.fbFname = ['feedback_sbj' num2str(sbj)];
paths.logFname = ['bbci_apply_log' num2str(sbj)];
%LiveAmp LSL logging files
paths.LALtccaCalFname = ['LALtCCA_calib_sbj' num2str(sbj)];
paths.LALcalFname = ['LALcalib_sbj' num2str(sbj)];
paths.LALfbFname = ['LALfeedback_sbj' num2str(sbj)];
end

