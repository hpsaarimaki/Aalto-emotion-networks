close all
clear all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));
load networks_mapping.mat
load vsneutral_subnetworks_0_35/all_subnetworks.mat
load rois_Power264



outnet=zeros(length(rois));

for s1=1:length(subids)
    for s2=s1:length(subids)
        temp=all_subnetworks{s1,s2};
        temp2=reshape(temp,[],size(temp,4));
        temp2=temp2';
        temp2=mean(temp2,2);
        if(s1==3 && s2==8)
            tempids=networks_mapping{s1,s2};
            outnet(tempids(1:length(temp2)))=temp2;
        else
            outnet(networks_mapping{s1,s2})=temp2;
        end
        
    end
end

map=parula(9);
imagesc(outnet+outnet',[-.3 .3])
colormap(map)
colorbar
axis square