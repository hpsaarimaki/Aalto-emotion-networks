storyID=[1
6
11
16
21
26
31
7
17
32
2
27
12
22
3
8
33
23
18
28
13
29
4
9
24
34
19
14
10
15
35
5
20
30
25];

story_labels={'surprise'
'happy'
'disgust'
'neutral'
'fear'
'sad'
'anger'
'happy'
'neutral'
'anger'
'surprise'
'sad'
'disgust'
'fear'
'surprise'
'happy'
'anger'
'fear'
'neutral'
'sad'
'disgust'
'sad'
'surprise'
'happy'
'fear'
'anger'
'neutral'
'disgust'
'happy'
'disgust'
'anger'
'surprise'
'neutral'
'sad'
'fear'};

class_labels={
'anger'
'disgust'
'fear'
'happy'
'sad'
'surprise'    
'neutral'
}



original_onsets=[10
60
111
161
211
261
311
10
60
111
161
211
261
311
10
60
111
161
211
261
311
10
60
111
161
211
261
311
10
60
111
161
211
261
311];



%delay=8; % extra time points to shift onsets
%delay=0; % extra time points to shift onsets
% also dding HRF delay = 3 volumes
onsets=original_onsets + 3 +delay;
%block_length = 35; % 60 seconds
%block_length = 27; % 45.9 seconds
TR = 1.7;
Nstimuli=length(onsets);

story_labelIDs=zeros(Nstimuli,1);
for c=1:Nstimuli
    id=0;
    for i=1:length(class_labels);
        if(strcmp(class_labels{i},story_labels{c}))
            id=i;
            break;
        end
    end
    story_labelIDs(c)=id;
end

epiIDs=reshape(repmat([1:5],7,1),[],1);
