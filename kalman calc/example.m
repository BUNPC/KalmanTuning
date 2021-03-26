%%This example file reads an fNIRS time series and performs Kalman
%%filtering on it. It can accept a tuning structure that will update the
%%Kalman parameters, or will use default values if not provided. 

clear all
subject=14;
'FB_Sbj14_motion.nirs';

%% load fNIRS data

paths_init

global BTB
BTB.TypeChecking=0;
fname=['calib_sbj',num2str(subject)];
FILE=[wdir,filesep,'data',filesep,'temp',filesep,['FB_Sbj',num2str(subject)],filesep,fname];
[cnt, mrk, hdr]= file_readBV(FILE);

%create array containing the location of the stims
mrkIdx=mrk.time/1000*cnt.fs;  %convert to samples
mrkIdx(mrk.event.desc'~=1)=[];%only keep the stims for working data
%mrkIdx(1:2)=[];  %remove the dummy triggers

% auxiliary variables
load('state','state') %state variable with information on what each channel is etc
load('tuning','tuning') %assumes the tuning code was ran already

%% Initialize Kalman filter
state=KalmanFilt_init(state,tuning,40,0);

%% Now call Kalman function
%Important: it assumes the stims do not overlap.
disp('Starting Kalman filtering...')
tic
[cntxout, stateout]=kalman_filter(cnt.x, mrkIdx, state);
B=toc;
disp([num2str(size(cnt.x,1)),' samples processed in ',num2str(B),' seconds'])
disp(['Processed: ',num2str(size(cnt.x,1)/B), ' samples/second for 24 channels simultaneously'])

%%
outputHRF=cntxout(:,state.fnirsLSChIdx(13:24));
t=(0:size(outputHRF,1)-1)/cnt.fs;
figure(1)
plot(t,outputHRF)

%%
figure(2)
[psd1,fra]=pwelch(outputHRF,[],[],[],state.fs);
loglog(fra,mean(psd1,2))
title('Mean power spectrum')