
    %specifying processing parameters
fc = 20;        %cut-off frequency for the speech envelope. See Aiken and Picton. Human cortical responses to the speech envelope.
fsE = 256;     %target EEG sampling rate. Records at different fs will be resampled.

%specifying all stimuli as they were presented. Correspond to triggers from 21 to 140
a_files = {'list of audio files'};
e_files = {'list of eeg files'};

for ind1 = 1:length(e_files)
        e = char(e_files(ind1));
        e = strtrim(e);
        load(e);    %load eeg files - contain all necessary data
        
        stim = Audio;
        mod = model;
        resp = validate_data(:, 1:625)';
        tmin = TMIN.(a);
        tmax = TMAX.(a);
        c = C;
        [pr,r,p_v,m] = mTRFpredict_customized(stim,resp,mod,fs,1,tmin,tmax,c);

        %storing results in the structure...
        PRED.(a) = squeeze(pr);
        RHO.(a) = r;
        P_VAL.(a) = p_v;
        MSE.(a) = m;
end
    %storing the results...
clear a model m p_v r pr stim resp tmin tmax fname af_name a ind ;
description = 'File name key: nh - normal hearing, age, gender, time when experiment started. W - structure containing mTRFs, T - structure of stimuli latencies, A - structure of speech envelopes. filed name corresponds to the stimuli. Stimuli key: gender, signal intenc in dB, noise type and intensity, fragment #. fc - cutoff freq for envelope; fsE - target sampling frequency.';
