# KalmanTuning

tuning folder
tuningcode.m will read the example resting data (subject 14 here) and calculate the tuning using the appropriate functions. Creates a tuning.mat file containing the tuning results.


xval rlda folder
example.m will calculate the classification performance for the subjects specified in the variable sublist. Creates a bunch of plots in the folder results->fig (the generated data is in results->claResExt)

folder kalman calc
example.m will calculate the Kalman regression of the example file using the tuning results obtained from runing tuningcode.m
