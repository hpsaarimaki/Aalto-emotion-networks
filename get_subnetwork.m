%clear all
%close all
function get_subnetwork(EN)
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));

% this is just an example that gets the DMN for net_subj1_surprise_id1.mat
%EN=2;
switch EN
    case 0
    netbasepath='networks'
    netprefix='';
    case 1
    netbasepath='extrinsic_networks';
    netprefix='extrinsic_';
    case 2
        netbasepath='vsneutral_networks';
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

if(0) % obsolete code for storing each in a separete file, not efficient
    for i=1:length(subids)
        disp(['making subnetworks/' subnet_labels{subids(i)}]);
        mkdir(['subnetworks/' subnet_labels{subids(i)}]);
    end    
    for n=1:length(nets);
        load(['networks/' nets(n).name])
        disp(['loading networks/' nets(n).name])
        for id=1:length(subids)
            thisid=subids(id);
            nodes=find(subnet_ids==thisid);
            subnetwork=adj(nodes,nodes);
            linkids=find(triu(ones(size(subnetwork)),1));
            links=subnetwork(linkids);
            outfile=['subnetworks/' subnet_labels{thisid} '/' nets(n).name]; % it already has the .mat at the end
            if(exist(outfile,'file')==2)
                disp(['Skipping ' outfile]);
            else
                disp(['Storing ' outfile]);
                save(outfile,'links','linkids','nodes');
            end
        end
    end
end

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
save(['./' netprefix 'subnetworks/all_subnetworks.mat'],'all_subnetworks','class_labels','all_subnet_labels')




