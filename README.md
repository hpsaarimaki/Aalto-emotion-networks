## DATA DESCRIPTION

- 16 subjects (double-data from 11 subjects, can be used for validation)
- DRIFTER data only from 14 subjects (excluding 005 and 011)

- 6 emotions (anger, fear, disgust, happiness, sadness, surprise) and neutral
- 5 stories per emotion (60-s long) = 35 stories
- 5 runs, one story per emotion in one run

- TR = 1.7s
- number of volumes per run: 365

---

## PREPROCESSING

standard bramila preprocessing (/scratch/braindata/heikkih3/EmotionNetworks/data/bramila_preproc.m)

including:
- slice timing correction
- motion correction (MCFLIRT)
- temporal filtering (butterworth)
- DRIFTER (breathing, heart rate from left finger)
- no frames removed
- registration to standard space (FLIRT)
- noise and motion cleaning (as in Power et al. 2014):
    - detrending (Savitzky-Golay)
    - anything else here?
-spatial smoothing (FWHM = 6, FSLGauss)

## NETWORKS
- Full connectivity matrices based on Power et al 2011 ROIs are in /m/nbe/scratch/braindata/eglerean/emotionnetworks/networks/
- Links have also been grouped by subnetwork paird in file /m/nbe/scratch/braindata/eglerean/emotionnetworks/subnetworks/all_subnetworks.mat (the file is generated with script get_subnetwork.m)
- Variable 'all_subnetworks' is a Matlab cell of size 10 x 10 (only top triangle) corresponding to 10 x 10 subnetworks:
```
    'MotorandSomatosensory'
    'Cingulo-opercular'
    'Auditory'
    'Defaultmode'
    'Visual'
    'Fronto-parietal'
    'Salience'
    'Subcortical'
    'Ventralattention'
    'Dorsalattention'
```
  Each cell contains a numeric matrix with dimensions
```	
	Nsubj x Nclasses x Nstories x Nlinks

	Nsubj = 16 % subject ID
	Nclasses = 7 % emotion classes with order 'anger'    'disgust'    'fear'    'happy'    'sad'    'surprise'    'neutral'
	Nstories = 5 stories
	Nlinks = it varies between subnetwork pairs
```
---

## CLASSIFICATION:

- LinSVC leave-one-out across-participants classifier was run on between and within networks (classification.py) and for DMN subnetworks (classification_dmn_subnetworks.py). 







