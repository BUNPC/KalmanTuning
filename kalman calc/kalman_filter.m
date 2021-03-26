function [cntx1, state]=kalman_filter(cntx, mrkIdx, state)
%% process the fNIRS data received from the stream with a Kalman filter in order to estimate HRF
%cntx data package
%state state variable for the data
%mrkIdx is the location of the trigger in the package in units of samples
%(if there is a trigger in the package, empty otherwise)
% By Antonio Ortega, 2021, aortegam@bu.edu

cntx1=cntx;
% return

%% constants for the size of design matrix
Nw=state.pproc.kalman.Nw;  %number of coefficients for HRF
Nr=state.pproc.tcca.nReg;  %number of regressors
Nt=Nw+1+Nr;

%% Identify the size of the channel
Nlambdas=2;  %number of wavelengths used in this device
Nls=length(state.fnirs.LongActChIdx)/Nlambdas;  %number of long separation channels

%% parse previous Kalman state
P=state.pproc.kalman.P;
Q=state.pproc.kalman.Q;
R=state.pproc.kalman.R;
xe=state.pproc.kalman.xe;

%% initializations and data buffers
datalen=size(cntx,1);   %number of samples in package
data=cntx(:,state.fnirsLSChIdx); %select long separation data

%%let's remember the model is y=C*xe+E, where E is the residual; however,
%%we are usually only interested in the part of the regression
%%corresponding to the HRF, which is only the first Nw components of x, so
%%we can write y=C1*xe1+C2*xe2+E. Where C1 is the first Nw columns of C,
%%and xe1 is the first Nw rows of xe. Thus HRF=C1*xe1 and we will call the
%%product C2*xe2 'others'. Of course, since the residual is unknown, what
%%we get is ye=C*xe. others=drift+tCCA
HRF=zeros(size(data)); %variable that saves the estimated HRF
drift=zeros(size(data)); % saves the other components of the regression
tCCA=zeros(size(data)); % saves only the "systemic physiology" component of the regression (excludes the drift)

%% main Kalman loop
M=zeros(Nt,Nlambdas*Nls);
for it=1:datalen
    if ~isempty(mrkIdx)        %this will activate when a trigger happens
        if any(it==mrkIdx)
            
            state.pproc.kalman.Uidx=1; %restarts the index for the design matrix after a stim happens IF the stim is a task stim
            if state.pproc.kalman.ResetatStim
                %reset HRF state
                xe(1:Nw,:)=state.pproc.kalman.xeini(1:Nw,:);
                %reset Kalman state
                P(1:Nw,1:Nw,:)=state.pproc.kalman.Pini(1:Nw,1:Nw,:);
                %eliminate covariances with HRF coefficients
                P(1:Nw,Nw+1:end,:)=0*P(1:Nw,Nw+1:end,:);
                P(1+Nw:end,1:Nw,:)=0*P(1+Nw:end,1:Nw,:);
            end
            
        end
    end
    if ~isempty(state.pproc.kalman.Uidx)
        Cd=[state.pproc.kalman.Ubase(min(state.pproc.kalman.Uidx,end),:),1e0]; %element of the design matrix we are interested in plus offset term
        dHb=data(it,:);
        C=[Cd,cntx(it,state.tccaRegChIdx)];  %add tCCA regressors
        for ic=1:2*Nls
            M(:,ic)=(P(:,:,ic)*C')*(C*P(:,:,ic)*C'+R(ic))^-1; %Kalman gain
            P(:,:,ic)=P(:,:,ic)-M(:,ic)*C*P(:,:,ic)+Q(:,:,ic);
        end
        xe=xe+M.*(dHb-C*xe);
        HRF(it,:)=C(:,1:Nw)*xe(1:Nw,:);
        drift(it,:)=C(:,Nw+1)*xe(Nw+1,:);
        tCCA(it,:)=C(:,Nw+2:end)*xe(Nw+2:end,:);
        state.pproc.kalman.Uidx=state.pproc.kalman.Uidx+1;
    end
end



%% calculate best estimate of output
ye=HRF+drift;
residual=cntx(:,state.fnirsLSChIdx)-ye;

%% update state variables
state.pproc.kalman.xe=xe;
state.pproc.kalman.P=P;
state.pproc.kalman.Q=Q;
state.pproc.kalman.R=R;

%decides what to output based on type of regression flag; if we are not
%estimating HRF, returns the residual
if state.pproc.kalman.est_HRF
    cntx1(:,state.fnirsLSChIdx)=HRF;
else
    cntx1(:,state.fnirsLSChIdx)=residual;
end

%% check whether end of run trigger was received. if yes, turn kalman off
if state.acq.mrkDesc(state.acq.trgIdx) == state.acq.stopMarker
    state.pproc.kalman.enable = false;
end