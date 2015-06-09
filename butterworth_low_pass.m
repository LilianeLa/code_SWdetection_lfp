% This function returns the filtered signal from low-pass filter: 'b'. 

% The first step in the detection algorithm is the low-pass filtering of the signal from a given channel. We
% opted for a Butterworth second-order low-pass filter with a cut frequency equal to 10 Hz.

% The low-pass filtered signal will be used for next steps: firstly in the detection of artifacts to identify
% their slow components (see find_artifacts.m), and secondly as input for the detection of slow waves (see find_slow_waves.m).


function b = butterworth_low_pass(V)

global def b t 			
lfp_defaults;			

t = [1:1:size(V,1)];		

[num,den] = butter(def.butterorder, def.fcutlow/(def.fsample/2), 'low'); 		
b = filter(num,den,V); 

% figure; 
% plot(t,b,'g');
% hold on
% plot(t,V); 
% grid
% xlabel('Timepoints (index) [-]');
% ylabel('Voltage [microV]');
% legend('Filtered signal (low-pass)', 'Original signal');
% title(['Low-pass filter (fc = ', num2str(def.fcutlow), 'Hz, second order)']);

% figure; 
% plot(s,b,'m');
% grid
% xlabel('Time [seconds]')
% ylabel('Voltage [microV]')


