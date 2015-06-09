% principal.m is the main function.

% e.g. 
%			   >> SW = principal(SA34_27_06_2014_0003.values, ttl.times);						
% will give the list of artifacts and slow waves for the file SA34_27_06_2014_0003 

% NB: Please change the sampling frequency if necessary (in lfp_defaults.m), as it can be different from a file to another one:

	% def.fsample = 10000;		% e.g. for SA34 
	% def.fsample = 20000;		% e.g. for SA14 	

	
function SW = principal(V, vertical)		% if there is a TTL signal, then the detection of slow waves occurring just before and after operant actions is possible

global def b bHP artifact red t s SW

disp(' ');
disp('*********************************************************************************************************');
disp('                                       I. DETECTION OF ARTIFACTS                                         ');
disp('*********************************************************************************************************');
disp(' ');
[red, bHP] = find_artifacts(V);		

disp(' ');
disp(' ');
disp('*********************************************************************************************************');
disp('                                      II. DETECTION OF SLOW WAVES                                        ');
disp('*********************************************************************************************************');
disp(' ');
SW = find_slow_waves(b);

disp(' ');
disp(' ');
disp('*********************************************************************************************************');
disp('              III. DETECTION OF SLOW WAVES OCCURRING JUST BEFORE AND AFTER OPERANT ACTIONS               ');
disp('*********************************************************************************************************');
find_BP_P300_randSW_modifOA(vertical, SW, V);				

% close all

% figure;
% plot(t,b);
% grid
% xlabel('Timepoints [-]');
% ylabel('Low-pass filtered signal [microV]');

% figure;
% plot(s,b);
% grid
% xlabel('Time [s]');
% ylabel('Low-pass filtered signal [microV]');

% figure;
% plot(s,V);
% grid
% xlabel('Time [s]');
% ylabel('Original signal [microV]');

% figure;
% plot(s,bHP, 'c');
% grid
% xlabel('Time [s]');
% ylabel('High-pass filtered signal [microV]');		

