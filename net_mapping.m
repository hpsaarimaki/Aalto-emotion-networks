addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));

% this is just an example that gets the DMN for net_subj1_surprise_id1.mat
%EN=2;


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
        disp(['Mapping ' subnet_labels{subids(id1)} '_' subnet_labels{subids(id2)}]);
        adj=zeros(length(rois));
		adj(nodes1,nodes2)=1;
        
		linkids=find(adj);
                  
                    %if(length(nodes1)==length(nodes2))
                    if(id1==id2)    
                        linkids=find(triu(adj,1));
                    end
                    
                    
      	networks_mapping{id1,id2}=linkids;
		
    end
end

save networks_mapping networks_mapping subnet_labels subids

