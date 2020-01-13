close all
clear all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));
addpath(('/m/nbe/scratch/braindata/shared/toolboxes/export_fig/'));
stimuli % script for stimuli related variables

% subjects are stored in /m/nbe/scratch/braindata/heikkih3/EmotionNetworks/data/[[sub]]/[[run]]/preprocessed
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
mFD=zeros(Nstimuli,Nsubj);
for s=1:Nsubj
    
	for run=1:Nruns
		basepath=['/m/nbe/scratch/braindata/heikkih3/EmotionNetworks/data/' subjIDs{s} '/epi' num2str(run) '/preprocessed'];
        disp(['loading ' basepath '/bramila/diagnostics.mat'])
		thisdata=load([basepath '/bramila/diagnostics.mat']); % variable thisdata.FD
        % check thisdata.FD
        for storyblock=1:7
           storyID=storyblock+(run-1)*7;
           start=onsets(storyID);
           temp=thisdata.FD(start:(start+block_length-1));
           mFD(storyID,s)=mean(temp);
           
        end
        
	end
end
[temp resort_per_class]=sort(story_labelIDs);
sortedmFD=mFD(resort_per_class,:);
boxplot(sortedmFD');
map=cbrewer('qual','Set1',7);
hold on
for c=1:length(class_labels)
    plot([.5 5.5]+5*(c-1),[0 0],'Color',map(c,:),'LineWidth',15)
    text(1+5*(c-1),0,class_labels{c})
end
axis([0 36 -.1 .6])
grid on
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]); 
xlabel('Story ID')
set(gca,'XTickLabel',resort_per_class)
export_fig figs/motion_checks.png


    


