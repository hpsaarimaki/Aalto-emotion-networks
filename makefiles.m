function [input,output] = makefiles(dataroot,nSubs);

% required input:
% - dataroot = folder where subject-wise data folders are(now it assumes
% that these subject-wise folders are (alphabetically) the first ones in
% the folder - if not; change line 16 
% - nSubs = number of subjects

%dataroot = '/m/nbe/scratch/braindata/heikkih3/EmotionNetworks/data';
%nSubs = 16

D = dir(dataroot);

subs = [];
for s = 1:nSubs;
    subs{end+1} = D(2+s).name;  % change 2 to sth else if your folder contains other subfolders alphabetically before the sub-wise folders
end

input = [];
output = [];

for i=1:length(subs);
    
    sub = subs{i};

    for run = 1:5;
        input{end+1,1} = ['/m/nbe/scratch/braindata/heikkih3/EmotionNetworks/data/' sub '/epi' num2str(run)];
        output{end+1,1} = ['/m/nbe/scratch/braindata/heikkih3/EmotionNetworks/data/' sub '/epi' num2str(run) '/preprocessed'];
    end
    
end

end
