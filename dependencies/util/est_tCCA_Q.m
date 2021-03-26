function [Q_tCCA_est,x0_tCCA_est]=est_tCCA_Q(Xtrain,Ytrain,tau,embbeds,nReg,flag)

Ntime=size(Xtrain,1);
Nwindows=5;  %Number of subintervals to divide the training data
WindSize=floor(Ntime/Nwindows); %number of samples per subinterval
limis=1:WindSize:Ntime+1;  %sample starts of each sample
betasub=nan([nReg,size(Xtrain,2),Nwindows]); %initialize buffer
ADD=cell(0);
% [REG_train,ADD1] = rtcca(Xtrain,Ytrain,struct('tau',tau,'NumOfEmb',embbeds,'ct',0),struct('pcaf',[0,0],'shrink',1));
%% Analyze the tCCA regression for each subwindow of the training data
for ki=1:Nwindows
    indi=limis(ki):limis(ki+1)-1;
    [REG_train1,ADD{ki}] = rtcca(Xtrain(indi,:),Ytrain(indi,:),struct('tau',tau,'NumOfEmb',embbeds,'ct',0),struct('pcaf',[0,0],'shrink',1));    
%     ADD1.tembAuxZ.mu
%     ADD1.tembAuxZ.sigma
%     REG_train2=    
    betasub(:,:,ki)=pinv(REG_train1(:,1:nReg))*Xtrain(indi,:);
end
x0_tCCA_est=mean(betasub,3);
Q_tCCA_est=var(betasub,[],3)/WindSize; %each column would be the diagonal for the Q submatrix corresponding to the tCCA components for that channel



%% Experimental
% Q_tCCA_est=var(betasub(:,:,2:end)-betasub(:,:,1:end-1),[],3)/WindSize;

% for ki=1:5
%     Av(:,:,ki)=ADD{ki}.Av_red;
% end

%Experimental

%%
if flag %try method 2, estimates covar
    Q_tCCA_est=zeros([size(betasub,1),size(betasub,1),size(betasub,2)]);
    for ki=1:size(betasub,2)
        foo1=squeeze(betasub(:,ki,:))';
        Q_tCCA_est(:,:,ki)=cov(foo1)/WindSize;
    end
end

