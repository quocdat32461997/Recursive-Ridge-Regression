# Recursive-Ridge-Regression
Recursive Ride Regression to map EEGs to corresponding speech 

These MATLAB codes were written to implement the Ridge Regression to examine the humans' learning process and predict EEGs from speech stimuli.

The data was not public due to research constraints. However, the dataset has 10 listeners and 20 passages. Every person listened to a passage 150 times at a time. Subjects include normal hearing and coclear implant. 

This repo is to show examples of how to implement to mTRF toolbox (Ridge Regression - based) for training predictive modeling in Neural Engineering. mTRF toolbox is widely used in this field to examine EEG data because it takes cares of multiple features and support time lags that is important in examining EEGs.

As we have 150 EEGs corresponding to a passage, I applied Recursive Regression that I treated each epoch (a duration listening to a pssage) as a data point. I took the first epoch and the corresponding speech to train the initial model. Then, next epochs were fitted to update the model. This work was done with an aim to improve the accuracy of prediciton based on pas experience of achieving high accuracy by applying only Ridge Regression on a single epoch. However, the prediction and accuracy were low. The correlation was in range of -0.3 to 0.3. This result was expected because EEG is a noisy data that cleaning process is complicated. Details about mTRF toolbox and Recursive Regression are available in .pdf files.

The current work is based on my previous research work and other papers.

Following work is to remove noise and apply different (e.g. SVM) to improve the accuracy of prediction.

If you find bugs or suggestion on how to improve to the EEG prediction, please let me know or contact me at email dqn170000@utdallas.edu.
