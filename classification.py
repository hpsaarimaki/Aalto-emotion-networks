# -*- coding: utf-8 -*-
"""
Created on Wed May  4 10:26:20 2016

@author: heini
"""

import os
from sklearn import svm
import numpy as np
from sklearn.cross_validation import LeaveOneLabelOut, permutation_test_score
from sklearn.svm import SVC
from sklearn.svm import LinearSVC
from sklearn.metrics import confusion_matrix
import scipy.io as sio

import pickle

acc = np.zeros((10,10))
confmat = np.zeros((10,10,7,7))

mydata = sio.loadmat('/m/nbe/scratch/braindata/eglerean/emotionnetworks/subnetworks/all_subnetworks.mat')
tmp_data = mydata['all_subnetworks']  
#tmp_data.shape  # 10x10 matrix

for x in range(0,10):
    
    for y in range(x,10):
        
        print "Subnetwork:", x, y

        ## Load data

        # tmp_data[0,0].shape # 16x7x5x595 matrix
        data = tmp_data[x,y].reshape(-1, tmp_data[x,y].shape[-1])
        #data.shape



        ## Crossvalidation indices 

        chunks = np.array([np.tile(i,35) for i in range(1,17)]).flatten()
        cv = LeaveOneLabelOut(chunks)

        # Targets

        emotions = ['anger','disgust','fear','happy','sad','surprise','neutral']
        mylabels = np.array([np.tile(i,5) for i in emotions]).flatten()
        labels = np.tile(mylabels,16)

        #emotions = ['surprise', 'happy', 'disgust', 'neutral', 'fear', 'sad', 'anger', 'happy', 'neutral', 'anger', 'surprise', 'sad', 'disgust', 'fear', 'surprise', 'happy', 'anger', 'fear', 'neutral', 'sad', 'disgust', 'sad', 'surprise', 'happy', 'fear', 'anger', 'neutral', 'disgust', 'happy', 'disgust', 'anger', 'surprise', 'neutral', 'sad', 'fear'];
        #emos = [1, 2, 3, 4, 5, 6, 7, 2, 4, 7, 1, 6, 3, 5, 1, 2, 7, 5, 4, 6, 3, 6, 1, 2, 5, 7, 4, 3, 2, 3, 7, 1, 4, 6, 5];
        #mylabels = np.array([np.tile(i,datalength) for i in emotions]).flatten()



        # Classifier

        ## Classification, we store output accuracy for each run, and predicted labels for each run
        cls = SVC() # Adjust the classifier here, sklearn has uniform interface, so you can pretty much plug any classifier here
        cv_scores = []
        yhat = []

        for train, test in cv:
            cls.fit(data[train,:], labels[train]) # For each fold, fit the predictor
            #dec = cls.decision_function([[1]])
            #print dec.shape[1]
            y_pred = cls.predict(data[test,:]) # Get predictions for each testing set
            # Then check how many predicted labels match actual labels, append to cv_scores
            cv_scores.append(np.sum(y_pred == labels[test]) / float(np.size(labels[test]))) # Inspect each expression to see how easy it is to interpret
            yhat.append(y_pred) # Store the predicted labels, this will be needed for your confmats later
        yhat = np.concatenate(yhat)


        
        #lin_clf = svm.LinearSVC()
        #lin_clf.fit(X, Y) 
        #LinearSVC(C=1.0, class_weight=None, dual=True, fit_intercept=True,
        #     intercept_scaling=1, loss='squared_hinge', max_iter=1000,
        #     multi_class='ovr', penalty='l2', random_state=None, tol=0.0001,
        #     verbose=0)
        #dec = lin_clf.decision_function([[1]])
        #dec.shape[1]


        ## Inspect intermediate results
        print(cv_scores)
        print("Mean: {0}".format(np.mean(cv_scores)))
        
        ## Inspect confmat
        # Labels - real labels
        # yhat - predicted labels generated by classifier
        cm = confusion_matrix(labels, yhat)
        # Want it normalized? No problem!
        cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        # Want it visualized? This one is just for inspection, I have a really cute one if you need.
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        def plot_confusion_matrix(cm, title='Confusion matrix', cmap=plt.cm.Blues):
            ''' Parameters:
            cm - confusion matrix,
            title - title
            cmap - colormap, default plt.cm.Blues '''
            plt.close('all')
            fig = plt.figure()
            ax = fig.add_subplot(1,1,1)
            img = ax.imshow(cm, interpolation='nearest', cmap=cmap, vmin=0, vmax=1)
            plt.title(title)
            plt.colorbar(img,ax=ax)
            plt.tight_layout()
            plt.ylabel('True label')
            plt.xlabel('Predicted label')
            plt.tick_params(
                axis='both',          # changes apply to the x-axis
                which='both',      # both major and minor ticks are affected
                bottom='off',      # ticks along the bottom edge are off
                top='off',         # ticks along the top edge are off
                labelbottom='on',  # labels along the bottom edge are off
                labelleft='on',
                right='off')
            return fig
        plot_confusion_matrix(cm_normalized)
        
        print np.diag(cm_normalized)
        
        
        acc[x,y] = np.mean(cv_scores)
        confmat[x,y] = cm_normalized
        
        del data


##  Permutations: http://scikit-learn.org/stable/auto_examples/feature_selection/plot_permutation_test_for_classification.html
# Used to work on triton, but gets stuck on Jouni for some reason, maybe don't use it yet
# If needed, I will find out how to run it.
#n_permutations = 10
#null_cv_scores = permutation_test_score(estimator = cls,
 #                                       X = data,
 #                                       y = labels,
 #                                       scoring="accuracy",
 #                                       cv = cv,
 #                                       n_permutations = n_permutations,
 #                                       n_jobs = -1,
 #                                       verbose = 1)
# Plot it
#def plot_permutation(null_cv_scores):
 #       ''' Make hist of permutation scores, with vertical line for max permutation accuracy and mean accuracy ''' 
 #       plt.close('all')
 #       fig = plt.figure()
 #       ax = fig.add_subplot(1,1,1)
        
 #       plt.title("Permutation threshold, pval = {0:.3f}".format(null_cv_scores[2]))
 #       bins = ax.hist(null_cv_scores[1],bins = 20, histtype="stepfilled", color = "#348ABD", alpha = 0.60, normed = True );
 #       plt.vlines(null_cv_scores[0], 0, max(bins[0])+1, linestyle = "--", linewidth = 2, color = 'red' , label = "Accuracy, {0:.2f}%".format(null_cv_scores[0]))
 #       plt.vlines(np.max(null_cv_scores[1]), 0, max(bins[0])+1, linestyle = "--", linewidth = 2, label = "Permutation threshold, {0:.2f}".format(np.max(null_cv_scores[1])))
 #       plt.legend(loc ="upper right")
        
 #       return fig
                                            
#plot_permutation(null_cv_scores)                          
                               
                               
                               
                               
                               
                               









    
#lin_clf = svm.LinearSVC()
#lin_clf.fit(X, Y) 
#LinearSVC(C=1.0, class_weight=None, dual=True, fit_intercept=True,
#     intercept_scaling=1, loss='squared_hinge', max_iter=1000,
#     multi_class='ovr', penalty='l2', random_state=None, tol=0.0001,
#     verbose=0)
#dec = lin_clf.decision_function([[1]])
#dec.shape[1]