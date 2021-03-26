function [Ubase] = fb_kalman_createUbase(cnfg)
% Creates a base for the design matrix to simplify the generation of the
% full design matrix and increase computational efficienty; for this to
% work correctly, regressed stim marks need to be separated for a time
% longer than dt*Nw
dt=0.5;
sigma=0.5;
g=@(t,k,ts) exp(-0.5*((t-k*dt-ts)/sigma).^2)/sigma/sqrt(2*pi);
fs=cnfg.fs;
Nw=cnfg.pproc.kalman.Nw;

dt0=sqrt(sigma^2*log(1e20)); %time after which the Gaussian is 1e-10 from the maximum
tf=Nw*dt+2*dt0; %final time; after this, the base functions have negligible amplitude
Nsupport=ceil(tf*fs); %required size for the basis functions

Ubase=zeros(Nsupport,Nw); %initialize design matrix template
t1=linspace(0,tf,Nsupport);
for k=1:Nw
    Ubase(:,k)=g(t1,k-2,0)';
end

end

