%% 
% This script will call the function to perform the classification
% performance estimation, and then plot it. The data is read from the temp
% folder. The cross-validation results are stored in the results folder.
% The claResExt subfolder contains the raw crossvalidation results, while
% the fig folder contains the figures for the results
%% Adapted by Antonio Ortega, aortegam@bu.edu

clear all
sublist = [8 14]; %subject list
xval  %this script runs the cross-validation itself
plotxval %this script plot the results and saves them to file