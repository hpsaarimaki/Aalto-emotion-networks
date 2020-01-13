clear all
close all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila/'))

% first set delay and block lenght on stimuli.m 
parpool(8)
parfor s=1:16;
	make_networks_fun(s)
end

% run pairwise_comparisons.m to get intrinsic network saved
pairwise_comparisons

% run pairwise_comparisons_vsneutral.m to get network against neutral baseline
pairwise_comparisons_vsneutral



get_subnetwork(0)
get_subnetwork(1)
get_subnetwork(2)
