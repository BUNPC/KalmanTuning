function stateout=KalmanFilt_init(statein,tuning,Nw,stimReset)
% This function initializes the Kalman filter based on the existence of
% tuning data. Nw is the number of Gaussians to use for the HRF model. The
% input stimReset determines if the Kalman state will be reset at the
% stimulus onset (0 no reset, other reset)
%By Antonio Ortega, 2021, aortegam@bu.edu

state=statein;

state.pproc.kalman.ResetatStim=stimReset;
state.pproc.kalman.est_HRF=1;
state.pproc.kalman.Nw=Nw; %number of HRF coefficients
state.pproc.kalman.regrIdx = state.tccaRegChIdx;% ! indices of channels in hybrid data to be used as regressors
state.pproc.kalman.Nr=state.pproc.tcca.nReg; %numel(cnfg.tccaRegChIdx) %number of regressors; this will most likely be defined elsewhere
state.pproc.kalman.Ubase=kalman_createUbase(state); %creates base for Kalman design matrix; assumption that the stims are separated enough not to have overlapping HRFs
state.pproc.kalman.Uidx=[];  %indicates Kalman hasn't started running yet

% determine sizes of data
Nw=state.pproc.kalman.Nw;  %number of coefficients for HRF
Nr=state.pproc.tcca.nReg;  %number of regressors
Nt=Nw+1+Nr;
Nlambdas=2;  %number of wavelengths used in this device
Nls=length(state.fnirs.LongActChIdx)/Nlambdas;  %number of long separation channels
targstims = {'Action left','Action right','Imagery left','Imagery right'};
state.pproc.kalman.targetStimDesc = find(ismember(state.acq.mrkName, targstims));

%grab tuning data
state.pproc.kalman.xe=tuning.x0;
state.pproc.kalman.P=tuning.P0;
state.pproc.kalman.Q=tuning.Q;
state.pproc.kalman.R=tuning.R;

%initial tuning saved in case we perform state reset
state.pproc.kalman.Pini=state.pproc.kalman.P;
state.pproc.kalman.xeini=state.pproc.kalman.xe;

stateout=state;