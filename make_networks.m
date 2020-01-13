clear all
close all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));
overwrite = 1; % set to one if you want to overwrite files
stimuli
Nruns=5
subjIDs={
'004'
'005'
'006'
'007'
'008'
'009'
'010'
'011'
'012'
'013'
'014'
'015'
'016'
'017'
'018'
'019'
};
Nsubj=length(subjIDs);
load rois_Power264
for s=1:Nsubj
    
	for run=1:Nruns
		basepath=['/m/nbe/scratch/braindata/heikkih3/EmotionNetworks/data/' subjIDs{s} '/epi' num2str(run) '/preprocessed'];
        
		thisdatafile=[basepath '/epi_preprocessed.nii'];
        cfg=[];
        cfg.rois=rois;
        cfg.infile=thisdatafile;
        cfg.write=0;
        cfg.usemean=1;
        
		% skip if brain file doesn't exist
		if(exist(cfg.infile,'file')==2)
			disp(['loading ' thisdatafile])
		else	
        	disp(['skipping ' thisdatafile])
			continue;
		end

        % extract rois
        [nodeTS perc]=bramila_roiextract(cfg);
        
        % for each block make a network
        for storyblock=1:7

           storyID=storyblock+(run-1)*7;
           outfile=['./networks/' 'net_subj' num2str(s) '_' story_labels{storyID} '_id' num2str(storyID) '.mat'];
			if(exist(outfile,'file')==2)
                if(overwrite == 0)
                    disp([outfile ' already exists, skipping...'])
                    continue
                else
                    disp([outfile ' already exists, overwriting...'])
                end
			end

           start=onsets(storyID);
           toi=(start:(start+block_length-1));
           adj=corr(nodeTS(toi,:));
           % replace NaN if any
           adj(find(adj==NaN))=0;
           
           % stored as net_subject_emotion_storyID
           disp(['Storing network as ' outfile])
           save(outfile,'adj','nodeTS','toi');
           
           
        end
        
	end
end



