function [Xout, state] = fb_maHpFilt(Xin, state, type)
% performs point by point zero phase moving average high pass filtering. 
%
% inputs:
%   Xin:    [ TIMEPOINTS x CHANNELS ] data matrix that is to be
%           low pass filtered. CAUTION: ALL CHANNELS WILL BE FILTERED
%   state:  state struct initialized by cnfg_init() containing filter
%           parameters and channel indices
%   type:   string defining either 'eeg' or 'fnirs'
%
% outputs:
% Xout:    [ CHANNELS x CHANNELS ] data with filtered channels 
% state:    state struct with updated filter conditions


switch type
    case 'eeg'  
        Xout = Xin;
        [eBL, state.pproc.eegMavgHpFilter.zi] = ...
            filter(state.pproc.eegMavgHpFilter.b, state.pproc.eegMavgHpFilter.a, Xin(:,[state.eegChIdx, state.eogChIdx]), state.pproc.eegMavgHpFilter.zi, 1);
        Xout(:,[state.eegChIdx, state.eogChIdx]) = Xin(:,[state.eegChIdx, state.eogChIdx])-eBL;
    case 'tccaAux'
        Xout = Xin;
        [nBL, state.pproc.fnirsMavgHpFilter.zi] = ...
            filter(state.pproc.fnirsMavgHpFilter.b, state.pproc.fnirsMavgHpFilter.a, Xin(:,state.tccaAuxChIdx), state.pproc.fnirsMavgHpFilter.zi, 1);
        Xout(:,state.tccaAuxChIdx) = Xin(:, state.tccaAuxChIdx)-nBL;
    case 'fnirsLS' % uses same settings as for tccaAux, but dedicated state memory
        Xout = Xin;
        [nBL, state.pproc.fnirsLSMavgHpFilter.zi] = ...
            filter(state.pproc.fnirsMavgHpFilter.b, state.pproc.fnirsMavgHpFilter.a, Xin(:,state.fnirsLSChIdx), state.pproc.fnirsLSMavgHpFilter.zi, 1);
        Xout(:,state.fnirsLSChIdx) = Xin(:, state.fnirsLSChIdx)-nBL;
end


end

