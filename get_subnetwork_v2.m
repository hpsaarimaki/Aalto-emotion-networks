%clear all
%close all
function get_subnetwork(EN,dd,bl)
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));

% this is just an example that gets the DMN for net_subj1_surprise_id1.mat
%EN=2;
appendix=['_' num2str(dd) '_' num2str(bl)];
switch EN
    case 0
    netbasepath=['networks' appendix];
    netprefix='';
    case 1
    netbasepath=['extrinsic_networks' appendix];
    netprefix='extrinsic_';
    case 2
        netbasepath=['vsneutral_networks' appendix];
        netprefix='vsneutral_';
end

nets=dir([netbasepath '/*.mat']);

load rois_Power264
stimuli
subnet_labels={};
subnet_ids=[];
for r=1:length(rois)
    subnet_ids(r,1)=rois(r).power_id;
    if(subnet_ids(r,1)>0);
        subnet_labels{subnet_ids(r,1),1}=strrep(rois(r).groupLabel,' ','');
    end
end
subids=[1  3 4 5  7 8 9 10 11 12];


Nsubj=16;
all_subnetworks={}; % subnet1 x subnet2
Nspc=5; % story per category

for id1=1:length(subids)
    thisid1=subids(id1);
    nodes1=find(subnet_ids==thisid1);
    for id2=id1:length(subids)
        thisid2=subids(id2);
        nodes2=find(subnet_ids==thisid2);
        Nlinks=length(nodes1)*length(nodes2);
        if(length(nodes1)==length(nodes2))
            Nlinks=(length(nodes1)*length(nodes1)-length(nodes1))/2;
        end
        disp(['Storing ' subnet_labels{subids(id1)} '_' subnet_labels{subids(id2)}]);
        data=NaN*zeros(Nsubj,length(class_labels),Nspc,Nlinks);
        for subj=1:Nsubj
            for class=1:length(class_labels)
                nets=dir([netbasepath '/net_subj' num2str(subj) '_' class_labels{class} '_id*.mat']);
                for i=1:length(nets)
                    load([netbasepath '/' nets(i).name]);
                    subnetwork=adj(nodes1,nodes2);
                    links=subnetwork(:);
                    if(length(nodes1)==length(nodes2))
                        linkids=find(triu(ones(size(subnetwork)),1));
                        links=subnetwork(linkids);
                    end
                    data(subj,class,i,:)=links;
                end
            end
        end
		if(EN==2)
			data=data(:,1:6,:,:); % we get rid of the neutral stuff, which is the 7th class
		end
        all_subnetworks{id1,id2}=data;
    end
end

all_subnet_labels=subnet_labels(subids);
mkdir(['./' netprefix 'subnetworks' appendix '/']);
disp(['./' netprefix 'subnetworks' appendix '/all_subnetworks.mat']);
save(['./' netprefix 'subnetworks' appendix '/all_subnetworks.mat'],'all_subnetworks','class_labels','all_subnet_labels')




