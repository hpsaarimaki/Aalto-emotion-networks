clear all
close all
%addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));

load rois_Power264
files=dir('./movie_parcellation/*.nii');

% load all files and store parcellatio labels
for f=1:length(files)
    filename=files(f).name;
    groupname{f}=filename(19:end-4);
    nii=load_nii(['./movie_parcellation/' filename]);
    all_parc(:,:,:,f)=nii.img;
    
end
    
R=length(rois);
for r=1:R
   thisroi=rois(r);
   xyz=thisroi.centroid;
   ids=squeeze(all_parc(xyz(1),xyz(2),xyz(3),:));  
   winner=find(ids>0);
   if(length(winner)>1)
       error('not possible!')
   end
   if(length(winner)>0)
       rois(r).groupLabel2=groupname{winner};
       rois(r).glerean_id=winner;
   else
       rois(r).groupLabel2='Not Defined';
       rois(r).glerean_id=-1;
   end
   
   disp([rois(r).groupLabel ' -> ' rois(r).groupLabel2])
end

save rois_Power264_v2 rois