%% Initializes paths 

% personalized ID (for stream identification etc)
paths.ID = 'X';

%current folder
cdir=fileparts(mfilename('fullpath'));
wdir=fileparts(cdir);
addpath(genpath(wdir))

% % DATASETs path (preliminary and main experimental data)
paths.data = [wdir,filesep,'DATA'];
% % sprint folders 
% paths.dataSprintf = {'', 'Sprint2\', 'Sprint3\', 'Sprint4\', 'Sprint5\', 'Sprint6\', 'Sprint7\', 'Sprint8\', 'Sprint9\'};
% % subject IDs and folders
for ss = 1:99; paths.dataSbjID{ss} = ['FB_Sbj' num2str(ss)]; end

% 
% % bbci toolbox paths
paths.bbciDir = [wdir,filesep,'bbci'];
% addpath(genpath(paths.bbciDir))
% 
% % data acquisition paths
paths.bbciDataDir = [wdir,filesep,'data',filesep,'temp'];
paths.bbciTmpDir = [wdir,filesep,'data',filesep,'temp',filesep,'tmp'];
% 
% % project files and code path
paths.ProjectDir = [wdir,'\'];
addpath(genpath(paths.ProjectDir))
