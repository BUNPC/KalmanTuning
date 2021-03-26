%% Performs the tuning for the Kalman filter assuming we have a resting data set for the subject

clear all
subjectNumber=14;

paths_init
%the state variable contains information needed for the processing such as
%which channels of the data stream contain the fNIRS data, which ones will
%be used for regression etc
load('variables.mat','state')  


%% code for compatibility with functions
global BTB
BTB.TypeChecking=0;
BTB.History=0;

%% auxiliary variables
flags.shrink=1;
flags.pcaf=[0,0];

%tcca parameters
param.tau=8;
param.NumOfEmb=37;
param.ct=0;

%% read training data
file=['tCCA_calib_sbj',num2str(subjectNumber)]; %resting data to use for tuning
state.acq.sbj=subjectNumber;
paths.tccaCalFname = file;
flist = dir(fullfile(paths.bbciDataDir, paths.dataSbjID{state.acq.sbj}, [paths.tccaCalFname '.eeg']));
[~, fname, ~] = fileparts(flist(1).name);
[cnt, mrk] = file_readBV(fullfile(paths.bbciDataDir, paths.dataSbjID{state.acq.sbj}, fname));

%% segmentation
[cnt.x, state] = fb_maHpFilt(cnt.x, state, 'fnirsLS');
% segment the resting state data, take 150s
ival = [5000 155000];
epo = proc_segmentation(cnt, mrk, ival);
epo = proc_selectClasses(epo, 'S  1');

Y = epo.x(:,state.fnirsLSChIdx);
AUX = epo.x(:,state.tccaAuxChIdx);


%% Calculate tCCA coefficients for training data
[ REG, ADD] = rtcca( Y, AUX, param, flags );
[REG, state.pproc.tcca.tccaZ.mu, state.pproc.tcca.tccaZ.sigma ] = zscore(REG);

%% Kalman tuning

%constants
Nw=40;  %number of coefficients for HRF model
Nr=2;  %number of tCCA regressors
Nt=Nw+1+Nr;
Nlambdas=2;  %number of wavelengths used in this device
Nls=length(state.fnirs.LongActChIdx)/Nlambdas;  %number of long separation channels

state.pproc.kalman.Nr=Nr;

%parameter calculation
state.pproc.kalman.tccaEx=pinv(REG)*Y; %contains an approximation of the expected value of the tcca coefficients
state.pproc.kalman.RNoise=9*estMeasNoise(Y,REG,state.fs,'WelchExtrapolation');
state.pproc.kalman.Qdrift=estQdrift(Y,REG,state.fs);
[Q_tCCA_est,~]=est_tCCA_Q(Y,AUX,param.tau,param.NumOfEmb,state.pproc.tcca.nReg,0);
state.pproc.kalman.Qtcca=Q_tCCA_est;

%As there are no priors for the HRF states, we make them zero; the
%drift term is also zero mean by definition;
state.pproc.kalman.xe=[zeros(Nw,2*Nls);zeros(1,2*Nls);state.pproc.kalman.tccaEx(1:Nr,:)];

%Initialize Q. Assume HRF is static. Qtcca will be set as diagonal
%based on the estimation perfomed from the resting data from the tcca
%initialization function fb_tCCAtfilt_init. Same for Qdrift
state.pproc.kalman.Q=zeros(Nt,Nt,2*Nls);
for k=1:2*Nls
    Qtcca=state.pproc.kalman.Qtcca(1:state.pproc.kalman.Nr,k)'/state.pproc.mBLL.chScalingFactor^2;
    state.pproc.kalman.Q(:,:,k)=diag([0*ones(1,Nw),1e-18,Qtcca]);
end
state.pproc.kalman.Q(Nw+1,Nw+1,:)=state.pproc.kalman.Qdrift/state.pproc.mBLL.chScalingFactor^2;

%measurement noise, estimated from resting data. The scaling factor is used
%to convert to the correct units, as the data is stored in micromolars due
%to data precision issues
state.pproc.kalman.R=state.pproc.kalman.RNoise/state.pproc.mBLL.chScalingFactor^2;

%initialize error; I will assume the error for the drift will be Qdrift
%I will also assume the error for the tCCA components is
%Qtcca. The error for the HRF coefficients is arbitrary, but based on
%optimizing the coefficients with augmented data

if state.pproc.mBLL.enable
    state.pproc.kalman.P=repmat(5e-12*eye(Nw+1+Nr),[1,1,Nlambdas*Nls]); %initialization of Kalman state Hb space
else
    state.pproc.kalman.P=repmat(1e9*5e-12*eye(Nw+1+Nr),[1,1,Nlambdas*Nls]); %initialization of Kalman state OD space
end
state.pproc.kalman.P(Nw+1,Nw+1,:)=state.pproc.kalman.Qdrift/state.pproc.mBLL.chScalingFactor^2;
state.pproc.kalman.P(Nw+2:end,Nw+2:end,:)=state.pproc.kalman.Q(Nw+2:end,Nw+2:end,:);

%% tuned results summary
tuning.x0=state.pproc.kalman.xe; %estimation of initial state
tuning.P0=state.pproc.kalman.P; %estimation of initial error
tuning.R=state.pproc.kalman.R;  %estimation of initial measurement noise
tuning.Q=state.pproc.kalman.Q; %estimation of initial process noise

save('tuning.mat','tuning')