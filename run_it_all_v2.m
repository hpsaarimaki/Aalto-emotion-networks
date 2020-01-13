clear all
close all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila/'))

if(0)
% first set delay and block lenght on stimuli.m 
parpool(8)

for dd=[0 8]
	for bl=[27 35]
		disp(['Delay: ' num2str(dd) ' block_length: ' num2str(bl)]);
		parfor s=1:16;
			make_networks_fun_v2(s,dd,bl)
		end
	end
end

%% regress intrinsic

for dd=[0 8]
    for bl=[27 35]
		regress_intrinsic(dd,bl)
	end
end

%% regress neutral

for dd=[0 8]
    for bl=[27 35]
        regress_neutral(dd,bl)
    end
end
end





for netid=0:2
for dd=[0 8]
    for bl=[27 35]
get_subnetwork_v2(netid,dd,bl)
end
end
end
