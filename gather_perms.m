
cd '/m/nbe/scratch/braindata/heikkih3/EmotionNetworks/FC/power/classification_vsneutral_LinSVC'

pvals = zeros(10,10);

% Load subnetwork accuracies
load accuracies.mat

% Load subnetwork permutations

for x = 1:10;
    
    for y = x:10;

        cv_scores = [];

        for i = 0:4
            fn = ['perms/permutations_' num2str(x-1) '_' num2str(y-1) '_' num2str(i) '.mat']
            load(fn)
            cv_scores(end+1:end+1000) = null_cv_scores;

            clear null_cv_scores;

        end


	% Compare subnetwork accuracy to permuted distribution	

        a = acc(x,y);
        onetailed = 1-normcdf(a,mean(cv_scores),std(cv_scores));
        
        pvals(x,y) = onetailed;
        
        clear a; clear onetailed; 

    end
    
end

% BHFDR correction 

pval = [];

for x = 1:10;
    for y = x:10;
        pval(end+1) = pvals(x,y);
    end
end

FDR = mafdr(pval,'BHFDR','true')

% Save things

save('FDR', FDR)
save('pvals', pvals)
csvwrite('pvals.xls',pvals)
