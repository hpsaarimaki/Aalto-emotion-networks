clear all
close all
%addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila//bramila'));
addpath(('/m/nbe/scratch/braindata/shared/toolboxes/export_fig/'));

% this is just an example that gets the DMN for net_subj1_surprise_id1.mat

nets=dir('networks/*.mat');

load rois_Power264_v2
R=length(rois);
ids=find(triu(ones(R),1));
stimuli

subnet_labels={};
subnet_ids=[];
for r=1:length(rois)
    subnet_ids(r,1)=rois(r).glerean_id;
    if(subnet_ids(r,1)>0);
        subnet_labels{subnet_ids(r,1),1}=strrep(rois(r).groupLabel2,' ',''); % note the new group label
    end
end
subids=[1  3 4 5  7 8 9 10 11 12];
subids=1:12;


mm=zeros(7,7,length(subids)+1);
for c1=1:7
    class1=class_labels{c1};
    nets1=dir(['networks/*' class1 '*.mat']);
    nets1_data=zeros(length(ids),length(nets1));
    for n=1:length(nets1);
        temp=load(['networks/' nets1(n).name]);
        nets1_data(:,n)=temp.adj(ids);
    end
    
    for c2=(c1+1):7
        class2=class_labels{c2};
        nets2=dir(['networks/*' class2 '*.mat']);
        nets2_data=zeros(length(ids),length(nets2));
        for n=1:length(nets2);
            temp=load(['networks/' nets2(n).name]);
            nets2_data(:,n)=temp.adj(ids);
        end
        disp(['Run ' class1 ' vs ' class2 ])
        stats{c1,c2}=bramila_ttest2_np([nets1_data nets2_data],[ones(1, length(nets1)) 2*ones(1, length(nets2))],0);
        mm(c1,c2,1)=median(stats{c1,c2}.tvals);
        thisadj=zeros(R);
        thisadj(ids)=stats{c1,c2}.tvals;
        thisadj=thisadj+thisadj';
        for id=1:length(subids)
            thisid=subids(id);
            nodes=find(subnet_ids==thisid);
            subnetwork=thisadj(nodes,nodes);
            mm(c1,c2,1+id)=median(subnetwork(find(triu(ones(length(nodes)),1))));
        end
        
        
    end
end
close all
map=cbrewer('div','RdBu',15);
map(8,:)=[1 1 1];
final_labels=[{'Whole network'}; subnet_labels];
%final_labels(7)=[];
%final_labels(3)=[]

figure(1)
for subn=1:length(final_labels)
    subplot(4,4,subn)
    temp=squeeze(mm(:,:,subn));
    h=imagesc(temp,[-1.5 1.5])
    
    axis square
    colormap(map)
    title(final_labels{subn})
    set(gca,'YTick',1:7)
    set(gca,'YTickLabel',class_labels)
    set(gca,'XTick',[]);
    if(subn>=9)
        set(gca,'XTick',1:7);
        set(gca,'XTickLabel',class_labels)
        set(gca,'XTickLabelRotation',90)
    end
end
subplot(4,4,subn+1)
imagesc([],[-1.5 1.5])
axis square
axis off
box off
colormap(map)
colorbar
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'Color',[1 1 1])
export_fig figs/pairwise_median_tvalues.png


%% a big happy vs sad picture
class1='happy';
nets1=dir(['networks/*' class1 '*.mat']);
class2='sad';
nets2=dir(['networks/*' class2 '*.mat']);
nets1_data=zeros(length(ids),length(nets1));
for n=1:length(nets1);
    temp=load(['networks/' nets1(n).name]);
    nets1_data(:,n)=temp.adj(ids);
end

nets2_data=zeros(length(ids),length(nets2));
for n=1:length(nets2);
    temp=load(['networks/' nets2(n).name]);
    nets2_data(:,n)=temp.adj(ids);
end
disp(['Run ' class1 ' vs ' class2 ])
stats_HS=bramila_ttest2_np([nets1_data nets2_data],[ones(1, length(nets1)) 2*ones(1, length(nets2))],0);
[aaa bbb]=sort(subnet_ids);
outnet=zeros(R);
outnet(ids)=stats_HS.tvals;
outnet=outnet+outnet';
outnet=outnet(bbb,bbb);
blocks=find(diff(aaa));
figure(2)
subplot(1,2,1)
imagesc(outnet,[-3 3])
hold on
for b=1:length(blocks)
    plot([0 R],[blocks(b) blocks(b)],'k')
    plot([blocks(b) blocks(b)],[0 R],'k')
end
colormap(flipud(map))
axis square
colorbar
title(['happy vs sad (tvalues)'])
intervals=[[.5; blocks-.5  ] [blocks+.5; R+.5]]
outlabels=final_labels;
outlabels{1}='n/a';

set(gca,'XTick',mean(intervals,2));
set(gca,'YTick',mean(intervals,2));
set(gca,'XTickLabel',outlabels)
set(gca,'XTickLabelRotation',90)
set(gca,'YTickLabel',outlabels)

uu=unique(aaa);
outsummary=zeros(length(uu),length(uu));
for b1=1:length(uu)
    nodes1=find(aaa==uu(b1));
    for b2=b1:length(uu)
        nodes2=find(aaa==uu(b2));
        temp=outnet(nodes1,nodes2);
        outsummary(b1,b2)=median(temp(:));
        [H P]=ttest(temp(:));
        pvals(b1,b2)=P;
    end
end
subplot(1,2,2)
imagesc(outsummary,[-1.5 1.5])
axis square
colorbar
set(gca,'XTick',1:length(uu));
set(gca,'YTick',1:length(uu));
set(gca,'XTickLabel',outlabels)
set(gca,'XTickLabelRotation',90)
set(gca,'YTickLabel',outlabels)
pp=-log(pvals);
for b1=1:length(uu)
    hold on
    plot([b1-.5 b1-.5],[.5 length(uu)+.5],'k');
    plot([.5 length(uu)+.5],[b1-.5 b1-.5],'k');
    for b2=b1:length(uu)
        
        
        
        str='';
        if(pp(b1,b2)>20)
            str=[str '*'];
        end
        if(pp(b1,b2)>50)
            str=[str '*'];
        end
        text(b2,b1,str)
    end
end
title('Happy vs sad summary across networks (median is color and one sample ttest is star)')
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'Color',[1 1 1])
export_fig figs/detailed_happy_vs_sad.png


%% dendrogram for happy vs sad across all links
d=(1-corr([nets1_data nets2_data],'type','Spearman'))/2; % distance between stories
z=linkage(squareform(d),'complete');
dendrolabels=[];
for n1=1:length(nets1)
    dendrolabels{end+1}=strrep(nets1(n1).name,'_','-');
end
for n2=1:length(nets2)
    dendrolabels{end+1}=strrep(nets2(n2).name,'_','-');
end
%dendrogram(z,0,'labels',dendrolabels,'Orientation','left')
% the result is that two story networks are more similar because of the
% intrinsic activity of the subejct rather thant he extrinsic (= stimulus
% related) one

%% reload all subjects for happy and sad but regress out the subjectwise average across allemo
% skip subj 3 because we have less stories for her

intrinsic_nets=zeros(length(ids),16);
for s=1:16
    
    subjnets=dir(['networks/net_subj' num2str(s) '_neutral' '*.mat']);
    netdata=zeros(length(ids),length(subjnets));
    disp([num2str(s) '-' num2str(length(subjnets))])
    for n=1:length(subjnets);
        temp=load(['networks/' subjnets(n).name]);
        netdata(:,n)=temp.adj(ids);
    end
    intrinsic_nets(:,s)=mean(atanh(netdata),2);
end

save(['neutral_networks_movieParc/instrinsic_nets.mat'],'intrinsic_nets','ids');



% redo across all emo pairs WITHIN subnetwork

mm=zeros(7,7,length(subnet_ids)+1);
for c1=1:7
    class1=class_labels{c1};
    
    nets1_data=[];
    for s=1:16
        nets1=dir(['networks/net_subj' num2str(s) '_' class1 '*.mat']);
        
        nets1_data_ind=zeros(length(ids),length(nets1));
        
        
        for n=1:length(nets1);
            temp=load(['networks/' nets1(n).name]);
            [B BINT RESI]=regress(atanh(temp.adj(ids)),[intrinsic_nets(:,s) ones(length(ids),1)]);
            nets1_data_ind(:,n)=tanh(RESI);
	    adj=.5*eye(size(temp.adj));
	    adj(ids)=nets1_data_ind(:,n);
	    adj=adj+adj';
	    save(['vsneutral_networks_movieParc/' nets1(n).name],'adj');
        end
        
        nets1_data=[nets1_data nets1_data_ind];
    end
    
    
    for n=1:length(nets1);
        temp=load(['networks/' nets1(n).name]);
        nets1_data(:,n)=temp.adj(ids);
    end
    
    for c2=(c1+1):7
        class2=class_labels{c2};
        nets2_data=[];
        for s=1:16
            nets2=dir(['networks/net_subj' num2str(s) '_' class2 '*.mat']);
            nets2_data_ind=zeros(length(ids),length(nets2));
            for n=1:length(nets2);
                temp=load(['networks/' nets2(n).name]);
                [B BINT RESI]=regress(atanh(temp.adj(ids)),[intrinsic_nets(:,s) ones(length(ids),1)]);
                nets2_data_ind(:,n)=RESI;
                
            end
            nets2_data=[nets2_data nets2_data_ind];
        end
        
        
        disp(['Run ' class1 ' vs ' class2 ])
        stats{c1,c2}=bramila_ttest2_np([nets1_data nets2_data],[ones(1, size(nets1_data,2)) 2*ones(1, size(nets2_data,2))],0);
        mm(c1,c2,1)=median(stats{c1,c2}.tvals);
        thisadj=zeros(R);
        thisadj(ids)=stats{c1,c2}.tvals;
        thisadj=thisadj+thisadj';
        for id=1:length(subids)
            thisid=subids(id);
            nodes=find(subnet_ids==thisid);
            subnetwork=thisadj(nodes,nodes);
            mm(c1,c2,1+id)=median(subnetwork(find(triu(ones(length(nodes)),1))));
        end
        
        
    end
end
close all
map=cbrewer('div','RdBu',15);
map(8,:)=[1 1 1];
final_labels=[{'Whole network'}; subnet_labels];
%final_labels(7)=[];
%final_labels(3)=[]

figure(100)
for subn=1:length(final_labels)
    subplot(4,4,subn)
    temp=squeeze(mm(:,:,subn));
    h=imagesc(temp,[-1.5 1.5])
    
    axis square
    colormap(map)
    title(final_labels{subn})
    set(gca,'YTick',1:7)
    set(gca,'YTickLabel',class_labels)
    set(gca,'XTick',[]);
    if(subn>=9)
        set(gca,'XTick',1:7);
        set(gca,'XTickLabel',class_labels)
        set(gca,'XTickLabelRotation',90)
    end
end
subplot(4,4,subn+1)
imagesc([],[-1.5 1.5])
axis square
axis off
box off
colormap(map)
colorbar
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'Color',[1 1 1])
export_fig figs/pairwise_median_tvalues_extrinsiconly.png



% redo happy vs sad minus the intrinsic activity
class1='happy';
class2='sad';
nets1_data=[];
nets2_data=[];
for s=1:16
    disp(num2str(s))
    nets1=dir(['networks/net_subj' num2str(s) '_' class1 '*.mat']);
    nets2=dir(['networks/net_subj' num2str(s) '_' class2 '*.mat']);
    nets1_data_ind=zeros(length(ids),length(nets1));
    nets2_data_ind=zeros(length(ids),length(nets2));
    for n=1:length(nets1);
        temp=load(['networks/' nets1(n).name]);
        [B BINT RESI]=regress(atanh(temp.adj(ids)),[intrinsic_nets(:,s) ones(length(ids),1)]);
        nets1_data_ind(:,n)=RESI;
    end
    for n=1:length(nets2);
        temp=load(['networks/' nets2(n).name]);
        [B BINT RESI]=regress(atanh(temp.adj(ids)),[intrinsic_nets(:,s) ones(length(ids),1)]);
        nets2_data_ind(:,n)=RESI;
        
    end
    nets1_data=[nets1_data nets1_data_ind];
    nets2_data=[nets2_data nets2_data_ind];
end
disp(['Run ' class1 ' vs ' class2 ])
stats_HS=bramila_ttest2_np([nets1_data nets2_data],[ones(1, size(nets1_data,2)) 2*ones(1, size(nets2_data,2))],0);
[aaa bbb]=sort(subnet_ids);
outnet=zeros(R);
outnet(ids)=stats_HS.tvals;
outnet=outnet+outnet';
outnet=outnet(bbb,bbb);
blocks=find(diff(aaa));
figure(20)
subplot(1,2,1)
imagesc(outnet,[-3 3])
hold on
for b=1:length(blocks)
    plot([0 R],[blocks(b) blocks(b)],'k')
    plot([blocks(b) blocks(b)],[0 R],'k')
end
colormap(flipud(map))
axis square
colorbar
title(['happy vs sad (tvalues)'])
intervals=[[.5; blocks-.5  ] [blocks+.5; R+.5]]
outlabels=final_labels;
outlabels{1}='n/a';

set(gca,'XTick',mean(intervals,2));
set(gca,'YTick',mean(intervals,2));
set(gca,'XTickLabel',outlabels)
set(gca,'XTickLabelRotation',90)
set(gca,'YTickLabel',outlabels)

uu=unique(aaa);
outsummary=zeros(length(uu),length(uu));
for b1=1:length(uu)
    nodes1=find(aaa==uu(b1));
    for b2=b1:length(uu)
        nodes2=find(aaa==uu(b2));
        temp=outnet(nodes1,nodes2);
        outsummary(b1,b2)=median(temp(:));
        [H P]=ttest(temp(:));
        pvals(b1,b2)=P;
    end
end
subplot(1,2,2)
imagesc(outsummary,[-1.5 1.5])
axis square
colorbar
set(gca,'XTick',1:length(uu));
set(gca,'YTick',1:length(uu));
set(gca,'XTickLabel',outlabels)
set(gca,'XTickLabelRotation',90)
set(gca,'YTickLabel',outlabels)
pp=-log(pvals);
for b1=1:length(uu)
    hold on
    plot([b1-.5 b1-.5],[.5 length(uu)+.5],'k');
    plot([.5 length(uu)+.5],[b1-.5 b1-.5],'k');
    for b2=b1:length(uu)
        
        
        
        str='';
        if(pp(b1,b2)>20)
            str=[str '*'];
        end
        if(pp(b1,b2)>50)
            str=[str '*'];
        end
        text(b2,b1,str)
    end
end
title('Happy vs sad summary across networks extrinsic only (median is color and one sample ttest is star)')
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'Color',[1 1 1])
export_fig figs/detailed_happy_vs_sad_exstrinsiconly.png


%% redo dendrogram for happy vs sad across all links
d=(1-corr([nets1_data nets2_data],'type','Spearman'))/2; % distance between stories
z=linkage(squareform(d),'complete');
dendrolabels=[];
for n1=1:length(nets1)
    dendrolabels{end+1}=strrep(nets1(n1).name,'_','-');
end
for n2=1:length(nets2)
    dendrolabels{end+1}=strrep(nets2(n2).name,'_','-');
end
%dendrogram(z,0,'labels',dendrolabels,'Orientation','left')
