function Noise=estMeasNoise(X,Y,fs,tipo)
%Estimate measurement noise from tCCA regression
%X are the resting LS channels. Y is their tCCA regression
%Noise can be estimated from std(X) (worse), or extrpolating its noise
%spectrum for higher frequencies (better) or by calculating the standard
%deviation E, where X=Y*beta+E (might be even better, let's check!).


switch tipo
    case 'regression'
        beta=pinv(Y)*X;
        E=X-Y*beta;
        Noise=var(E);
    case 'WelchExtrapolation'
        [pxx,f]=pwelch(X,[],[],[],fs);
        %now I assume physiological noise is below 8 Hz
        fcutoff=8;
        indi=find(f>=fcutoff&f<fs/2);
        subnoiseVar=trapz(f(indi),pxx(indi,:));
        %Now I assume the non physiological noise is white to scale the variance
        noiseVarEstimated=subnoiseVar/(fs/2-fcutoff)*fs;
        Noise=(noiseVarEstimated);
        
        %semilogy(f,pxx(:,1)),xlabel('Frequency [Hz]'),xlim([0,fs/2]),ylabel('Squared spectral magnitude'),grid on
    case 'stdev'
        Noise=var(X);
    case 'WelchRegression'
        beta=pinv(Y)*X;
        E=X-Y*beta;
        [pxx,f]=pwelch(E,[],[],[],fs);
        %         semilogy(f,pxx)
        %xlim([0,fs/2])
        fcutoff=8;
        indi=find(f>=fcutoff&f<fs/2);
        subnoiseVar=trapz(f(indi),pxx(indi,:));
        noiseVarEstimated=subnoiseVar/(fs/2-fcutoff)*fs;
        Noise=(noiseVarEstimated);
    otherwise
        Noise=var(X);
end








