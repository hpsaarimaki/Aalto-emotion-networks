function regress_intrinsic(dd,bl)
	load rois_Power264_v2
	R=length(rois);
	ids=find(triu(ones(R),1));
	delay=dd;
	block_lenght=bl;
	
	stimuli_v2
	netfolder=['networks_' num2str(dd) '_' num2str(bl) '/'];

	% compute intrinsic
	intrinsic_nets=zeros(length(ids),16);
	for s=1:16
		disp(num2str(s));
    	subjnets=dir([netfolder 'net_subj' num2str(s) '_' '*.mat']);
	    netdata=zeros(length(ids),length(subjnets));
    	disp([num2str(s) '-' num2str(length(subjnets))])
	    for n=1:length(subjnets);
    	    temp=load(['networks/' subjnets(n).name]);
        	netdata(:,n)=temp.adj(ids);
	    end
    	intrinsic_nets(:,s)=mean(atanh(netdata),2);
	end
	mkdir(['avg_' netfolder])
	mkdir(['extrinsic_' netfolder])
	save(['avg_' netfolder '/instrinsic_nets.mat'],'intrinsic_nets','ids');


	% regress for each network
	for c1=1:7
	    class1=class_labels{c1};
	    disp(class1)
	    nets1_data=[];
	    for s=1:16
	    	disp(num2str(s));
    	    nets1=dir([netfolder '/net_subj' num2str(s) '_' class1 '*.mat']);
		    nets1_data_ind=zeros(length(ids),length(nets1));
	        for n=1:length(nets1);
    	        temp=load([netfolder nets1(n).name]);
        	    [B BINT RESI]=regress(atanh(temp.adj(ids)),[intrinsic_nets(:,s) ones(length(ids),1)]);
            	nets1_data_ind(:,n)=tanh(RESI);
		        adj=.5*eye(size(temp.adj));
        		adj(ids)=nets1_data_ind(:,n);
		        adj=adj+adj';

        		save(['extrinsic_' netfolder nets1(n).name],'adj');
	        end
	    	nets1_data=[nets1_data nets1_data_ind];
    	end
	end
