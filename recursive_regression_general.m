    clear all;

    %specifying processing parameters
fc = 20;        %cut-off frequency for the speech envelope. See Aiken and Picton. Human cortical responses to the speech envelope.
fsE = 250;     %target EEG sampling rate. Records at different fs will be resampled.
meth = 'a';     %the method for envelope extraction
lam = 1;        %lambda for mTRFs
fs = 250; %default sampling rate
eeg_speech_matches = {%{ List of eeg spech %}    %need to load
                    };
training_data_size = 0.7;
audio_dir = 'path to stimuli folder';   %path to audio and eeg files
eeg_dir = 'path to eeg folder';

for m = 1:size(eeg_speech_matches,2)
    %access audio files
    audio_list = dir([audio_dir, '/*', char(eeg_speech_matches(m)), '.wav']);
    audio_list = struct2table(audio_list);
    audio = audio_list.name; %list audio files
    
    %access eeg files
    eeg_list = dir([eeg_dir, '/*', char(eeg_speech_matches(m)), '_Artifact Rejection.mat']);
    eeg_list = struct2table(eeg_list);
    eeg_list = eeg_list.name; %list of eeg files
        
    %each audio
    for a = 1:size(audio)
        audio_name = char(audio(a, :));    %form audio file name;
        audio_name = strtrim(audio_name);

        a_name = [audio_dir, '/', audio_name];
        a_env = audio_env(a_name, fc, fsE, meth); %read audio
    
        audio_name = replace(audio_name, '-', '_');     %re-format audio name
        audio_name = replace(audio_name, '.wav', '');
        audio_name = ['A_', audio_name];
    
        a_env= [zeros(125, 1); a_env; zeros(2, 1)]; %fill null values
        a_env_p = resample(a_env, 50, 250);
        Audio = a_env_p;
        
        
        %each epoch
        for ep = 1:size(eeg_list)
            eeg_name = char(eeg_list(ep));  %form eeg file name
            eeg_name = strtrim(eeg_name);

            %load eeg file
            e_name = ['/Users/datqngo/Desktop/Research/additional data/pre_processed_data/', eeg_name]';
            e = matfile(e_name);
            eeg_name = replace(eeg_name, '-', '_'); %re-format eeg file name
            eeg_name = replace(eeg_name, ' ', '_');
            eeg_name = replace(eeg_name, '.mat', '');
            disp(eeg_name);     %print eeg file name
            
            eeg_data = e.eeg;   %extract eeg data
            data = eeg_data.data;
            
            data = data(:, 625*10 + 1:size(data,2) - 625*10);   %remove the first and last 10 eeg epochs
            train_data = data(:, 1: size(data,2)*training_data_size;    %train_data takes 70%
            validate_data = data(:, size(data,2)*training_data_size + 1: end);  %validate_data takes 30%
            
            %recursive regression
            for ind = 1:(size(train_data,2)/625)
                sample_f = 625*(ind -1) + 1;    %separate eeg epochs 
                sample_l = sample_f - 1 + 625;
                training_eeg_data = train_data(:, sample_f:sample_l);
                training_eeg_data = resample(double(training_eeg_data)', 50, 250)'; %resample frequency to 50Hz to faciliate procesing and remove odd data points
                
                data_p = training_eeg_data - repmat(mean(training_eeg_data,2),1,size(training_eeg_data,2));     %removing DC - must be done BEFORE resampling (if any)
                data_p = data_p - repmat(mean(data_p,1),size(data_p,1),1);  %common average reference (CAR) spatial filter...

                epoch_d = (detrend(data_p'))';  %detrend epoch

                [A, b, w, M, t, tmin, tmax] = recursive_mTRFtrain(a_env_p, epoch_d', 50, 1, 1, size(epoch_d', 1) , lam);
                
                if ind == 1
                    A_model = A;
                    
                    b_model = b;
                else
                    A_model = A_model + A;  %recursively update the model
                    
                    b_model = b_model + b;
                end
                
                EEG.([eeg_name, '_', num2str(ind)]) = epoch_d'; %save necessary data
                TMAX.([eeg_name, '_', num2str(ind)]) = tmax;
                TMIN.([eeg_name, '_', num2str(ind)]) = tmin;
                T.([eeg_name, '_', num2str(ind)]) = t;
                W.([eeg_name, '_', num2str(ind)]) = squeeze(w);
            end
            
            model_name = [audio_name, '_', eeg_name];
            model = inv(A_model + lam*M)*b_model;   %calculate ridge-regression model
            C = model(1:size(a_env_p,2),:); 
            model = reshape(model(size(a_env_p,2)+1:end,:),size(a_env_p,2),length(tmin:tmax),size(epoch_d',2));
            model = squeeze(model);
            
            fname = [eeg_name, '.mat'];
            save(fullfile('/Users/datqngo/Desktop/Research/additional data', eeg_name), 'W', 'train_data', 'validate_data', 'model', "TMIN", "TMAX", "C", "EEG", "Audio", "eeg_name", "audio_name", 'T');
        end
    end
end
clear