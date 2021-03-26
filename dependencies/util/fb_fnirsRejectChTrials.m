function [rChIdx, rTrial] = fb_fnirsRejectChTrials(cnt, mrk, SD, rCh, rTr)
%FB_FNIRSREJECTCHTRIALS identifies channels and trials to reject, using the
%raw intensity data and functions from the established HOMER2 toolbox
%
% by Alexander von Lühmann 2019, avolu@bu.edu
rChIdx= [];
rTrial = [];

% convert into Homer-ready format
clabIntIdx = find(contains(cnt.clab,'_INT'));
% int data
d = cnt.x(:,clabIntIdx);
% time vector
t=0:1:size(d,1)-1;
t=t/cnt.fs;
% stimulus vector
s = zeros(numel(t),1);
% set stimuli
for ss = 1:numel(mrk.time)
    [m, idx(ss)] = min(abs(t-mrk.time(ss)/1000));
end
s(idx) = 1;

if rCh % prune channels
    SD = enPruneChannels(d,SD,ones(size(d,1),1),[0 1000000000], 2, [0 45],0);
    rChIdx = find(~SD.MeasListAct);
end

if rTr % motion correction
    dod = hmrIntensity2OD(d);
    %dod = hmrMotionCorrectSplineSG(dod,d,t,SD,0.99,10,1);
    % identify motion artifacts
    tIncAuto = hmrMotionArtifact(dod,t,SD,ones(size(d,1),1),0.5,1,30,5);
    % flag stims that are to be rejected
    [sout,tRangeStimReject] = enStimRejection(t,s,tIncAuto,ones(size(d,1),1),[-2  15]);
    % 
    rtimes = find(sout < -0);
    for rr = 1:numel(rtimes)
        [m, rTrial(rr)] = min(abs(mrk.time/10-rtimes(rr)));
    end
end


end

