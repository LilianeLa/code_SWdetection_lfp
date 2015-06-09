function def = lfp_defaults 
global def 

def.fsample = 10000;						% for SA26, SA27, SA31 day x, SA32, SA33, SA34 	% The sampling frequency or sampling rate is the average number of samples obtained in one second (samples per second)
% def.fsample = 20000;						% for SA14, SA15, SA16, SA17, SA19, SA31 day 1

def.minimal_duration_OA = 2.8;				% The algorithm will detect both 3 and 6 sec OAs 
% def.minimal_duration_OA = 5;				% The algorithm will detect only 6 sec OAs		% 5.8 before

%=============================================================================================================================================================

def.rate = def.fsample;
def.butterorder = 2; 							% Avoid high order. (risk of high temporal shift with the original signal)
def.fcutlow = 10 ; 								% Butterworth low pass

%% BUTTERWORTH HIGH-PASS AND DETECTION OF ARTIFACTS
% def.amplitude_artifact = 40;			
def.amplitude_artifact = 35;			
% def.amplitude_artifact = 30;			
% def.amplitude_artifact = 25;			
% def.amplitude_artifact = 20;					% Minimal amplitude of fast component of the artifact
def.derivee_artifact = 40; 
def.artifact_cut_length = 1.7*def.fsample;			
% def.artifact_cut_length = 1.1*def.fsample;			
% def.artifact_cut_length = 2.1*def.fsample;			
def.fcuthigh = 100 ; 					

% DETECTION OF THE SLOW COMPONENT
def.amplitude_slow_artifact = 27;			% Minimal amplitude of the slow component of the artifact
% def.amplitude_slow_artifact = 15;		
% def.amplitude_slow_artifact = 30;		
def.endslow = 1;										% Maximum interval authorized between the last high value of bLP found and the first ZC encountered (seconds)
% def.eps1 = 1000;
% def.eps2 = 1000;

def.amplitudediapason = 16;				
def.durationdiapason = 0.65;						% has been fixed upon the artifacts of SA14_0003
% def.durationdiapason = 0.1;		

% def.duration_slow_artifact	= 0.8;			% 0.5 firstly, fixed upon artifact 3 (seconds)
def.duration_slow_artifact	= 1;				% maximal duration threshold authorized from the end of the fast component 
% def.duration_slow_artifact	= 7;				% before the adaptation of 'diapason'	 

% Maximum slope index: criterion on the slope between the negative and the positive peaks (criteria of minimum percentile 90)				
def.percentile = 90; 		
		
% MASSIMINI CRITERIA

% Duration criteria (in ms): 
% def.SWlength(1): minimal duration of negative peak (reduced from 150, upon the event at 184.5 s in SA14, to detect the negative peak)
% def.SWlength(2): maximal duration of negative peak
% def.SWlength(3): maximal duration between: the up-zero-crossing after negative peak and the down-zero-crossing just after the highest positive peak 
% 				   (can be seen as the maximal duration of the positive peak in certain cases of SWs)
% def.SWlength(4): minimal duration between current pos. peak and precedent pos. peak; also minimum duration between current neg. peak and precedent neg. peak; 
%                  = 1500/5 = 300 ms;  i.e. we need 300 ms between SW negativity. But we can try even lower: 200
%    	           the more it's low, the more SWs will be found.  

% def.SWlength      	= [100 1250 1500];		% beginning
% def.SWlength      	= [100 2400 1500];		% 12 may 
% def.SWlength      	= [100 2400 2900];		% 13 may  
% def.SWlength      	= [100 2900 3200];		% 13 may (to be sure)
% def.SWlength      	= [100 3500 2900];		% 14 may: 3200 is exaggerated (we lose some waves); duration of negative peak = 3500: no risk because no risk of overlapping
% def.SWlength      	= [100 3500 1500];		% 15 may: 1500 works for detecting both SWs at 1383 and 1384 sec 
% def.SWlength      	= [100 3500 3000 300];	% 3000: 2900 can be replaced by 3000. 300 comes simply from 1500/5 
% def.SWlength      	= [100 3500 3100 200];	
												% 300 doesn't work for       Possible P3:    -40.8385 microV at 1832.5767s;    21.6972 microV at 1832.6601s
												% because the precedent pos peak and the subsequent neg peak are in the same SW. With 200 instead of 300 it works.
 def.SWlength      		= [45 3500 3500 200];	% 3450 works for 3733 sec in SA16_09_07_2013_0002_Ch3

											
% Magnitude criteria (in microV): criteria of magnitude for SWS (-80 140) and delta waves (-40 75)
% minimum negative peak amplitude: -40 for delta and -80 for SWS, 	% from Massimini		
% minimum total magnitude: 			75 for delta and 140 for SWS 	% from Massimini
% def.SWmAmpl       = [-30 75]; 	
% def.SWmAmpl       = [-30 65]; 			
% def.SWmAmpl       = [-28 49]; 			
% def.SWmAmpl       = [-25 49]; 			
def.SWmAmpl       = [-20 40]; 			

def.OAsemiwindow = 5;

return		% end 
