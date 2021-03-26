function Qdrift=estQdrift(Xtrain,REG_train,fq)
% Calculates the drift variance per sample of fNIRS resting data

beta=pinv(REG_train)*Xtrain; %regress tCCA
E=Xtrain-REG_train*beta; %try to remove physiology from resting data
Nx=size(Xtrain,1);
subsize=4*fq;  %4 seconds interval; too long interval: more uncertainty in variance; too short: high frequency noise dominates. Size of subinterval in samples
Ns=floor(Nx/subsize);    %Number of subintervals
subintervals=nan(subsize,size(Xtrain,2),Ns);  %will store all subintervals. dim1 time, dim2 channel, dim 3 subintervals
for ki=1:Ns
    temp=E((ki-1)*subsize+1:ki*subsize,:); %ki-th subinterval
    temp=temp-temp(1,:);  %remove the first element to estimate drift from initial
    subintervals(:,:,ki)=temp;
end
varintime=var(subintervals,[],3); %variance as a function of time; dim1 time, dim2 channels
Qdrift=nan(1,size(Xtrain,2));
for ki=1:size(Xtrain,2)
    p1=polyfit(0:subsize-1,varintime(:,ki),1);
    if p1(1)>0
        Qdrift(ki)=p1(1);
    else %if linear fit fails (var can't be negative) use the last (accumulated variance) instead
        Qdrift(ki)=varintime(end,ki)/size(varintime,1);
    end
end
