% The function find_BP_P300_randSW_modifOA aims at counting:
% - the number of operant actions before which there is at least one pre-wave, (it doesn't matter about the number of SWs)
% - the number of operant actions after which there is at least one post-wave,
% - the number of random windows (windows occurring anywhere else than around pre-waves or postwaves) in which there is at least one slow wave.

% It displays a list with all the operant actions, indicating for each of them, if there are slow waves identified as pre-waves or post-waves occurring around (with their timings of negative and positive peaks). 

% It also displays a list of random windows and indicates for each one whether there are slow waves in them.
% The random windows are taken such that the detected slow waves won't be the detected pre-waves and post-waves. 
% Moreover, the function was built such as all the random windows are different, to ensure that there will not be any redundant random slow waves. 

% The inputs of the function are:
% - the original signal of the chosen channel;
% - the TTL signal, which is a vector containing the beginning and the end (in seconds) of each operant action (beginnings (up-down) correspond to odd indexes of the vector and ends (down-up) correspond to even indexes);
% - 'SW', the output from 'find_slow_waves', containing the timings of the negative and positive peaks of each detected slow wave.

% The function returns 3 outputs: countBP, countP300 and countrandSW corresponding to the 3 kinds of events cited above.
% 20*3 outputs will be found for each of the 8 channels. 
% Via the function 'mean_and_SD' taking in inputs the 3*8 outputs returned successively by find_BP_P300_randSW_modifOA, 
% will be found the mean and the standard deviation of the 3 measures cited above.

% 1. If you run principal_timelocking.m : 				Please check the name of the channel 11 
% 2. If you don't run principal_timelocking.m, but only run find_BP_P300_randSW: 
%		- Either run principal_NOcorrelation.m: 	gives 'SW' as we need 'SW'. 
% 
% 			e.g. >> 			SW = principal(SA34_20_06_2014_0003.values);						% Don't forget 'SW' 
% 	   			 >> 			 [countBP, countP300, countrandSW] = find_BP_P300_randSW(ttl.times, SW, SA34_20_06_2014_0003.values)		% Don't forget 'values' 
% 
% 		- Or open the corresponding 'SW.mat' if already saved.
% 	   			 >> 			 [countBP, countP300, countrandSW] = find_BP_P300_randSW_modifOA(ttl.times, SW, SA34_20_06_2014_0003.values)		% ! Don't forget 'values' 



function [countBP, countP300, countrandSW] = find_BP_P300_randSW_modifOA(vertical, SW, V)				

global def			

lfp_defaults;				
oa = zeros(length(vertical)/2, 1);
countOA = 0;
countBP = 0;
countP300 = 0;
countrandSW = 0;
deadzone = zeros(ceil(length(V)/def.rate), 1);		% The indexes of 'deadzone' are IN SECONDS, not in INDEXES

for i = 1:length(oa)				% until the last OA up-down, where up-down is an odd index of 'vertical' as the first up-down is the index 1 of 'vertical'. We suppose 'vertical' is of even length as we admit the last element is a down-up. 
	if vertical(2*i) - vertical(2*i-1) > def.minimal_duration_OA	
		oa(i) = vertical(2*i-1);	
		countOA=countOA+1; 		
		duration = vertical(2*i) - vertical(2*i-1);
		
		%% Pre-wave 
		indexBP = find([SW(1,:).negpeak_seconds] > (oa(i)-def.OAsemiwindow)  &  [SW(1,:).negpeak_seconds] < oa(i) );	% gives the order number of SW of the list of SWs, which is detected as a pre-wave. Ex: If indexBP=1, it means the first SW in the list is a pre-wave
		if isempty(indexBP)
			indexBP = find([SW(1,:).pospeak_seconds] > (oa(i)-def.OAsemiwindow)  &  [SW(1,:).pospeak_seconds] < oa(i) ); % same as before, but we look at the positive peak instead of the negative, in the case the negative peak is too far from OA to be detected as pre-wave
		end 	
		if ~isempty(indexBP) 				% in the case we have found something as a pre-wave, then we can find the time of the pre-wave. (It has no sense to search the time of pre-wave if we haven't found any pre-wave)
			countBP = countBP+1;			% We only add 1, not 2 or 3 because, even if we find 2 pre-wave or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one pre-wave per OA.
			disp(' ');

			disp(['OA', num2str(countOA), ': [', num2str(oa(i)), 's, ', num2str(vertical(2*i)), 's];  duration: ', num2str(duration), 's']);
			if length(indexBP) == 1
				disp(['     -> Possible pre-wave :    ', num2str(SW(1,indexBP).valmin), ' microV at ', num2str(SW(1,indexBP).negpeak_seconds), 's;    ', num2str(SW(1,indexBP).valmax), ' microV at ', num2str(SW(1,indexBP).pospeak_seconds), 's']);
			elseif length(indexBP) == 2 	
				disp(['     -> Possible pre-wave :    ', num2str(SW(1,indexBP(1)).valmin), ' microV at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(1)).valmax), ' microV at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexBP(2)).valmin), ' microV at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(2)).valmax), ' microV at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);		
			elseif length(indexBP) == 3	
				disp(['     -> Possible pre-wave :    ', num2str(SW(1,indexBP(1)).valmin), ' microV at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(1)).valmax), ' microV at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexBP(2)).valmin), ' microV at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(2)).valmax), ' microV at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexBP(3)).valmin), ' microV at ', num2str(SW(1,indexBP(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(3)).valmax), ' microV at ', num2str(SW(1,indexBP(3)).pospeak_seconds), 's']);		
			elseif length(indexBP) == 4	
				disp(['     -> Possible pre-wave :    ', num2str(SW(1,indexBP(1)).valmin), ' microV at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(1)).valmax), ' microV at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexBP(2)).valmin), ' microV at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(2)).valmax), ' microV at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexBP(3)).valmin), ' microV at ', num2str(SW(1,indexBP(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(3)).valmax), ' microV at ', num2str(SW(1,indexBP(3)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexBP(4)).valmin), ' microV at ', num2str(SW(1,indexBP(4)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(4)).valmax), ' microV at ', num2str(SW(1,indexBP(4)).pospeak_seconds), 's']);							
			end 	
		else 	
			disp(' ');
			disp(['OA', num2str(countOA), ': [', num2str(oa(i)), 's, ', num2str(vertical(2*i)), 's];  duration: ', num2str(duration), 's']);
			disp(['     -> No pre-wave detected'])
		end		
		
		%% Post-wave
		indexP300 = find([SW(1,:).negpeak_seconds] < (oa(i)+def.OAsemiwindow)  &  [SW(1,:).negpeak_seconds] > oa(i) );	% gives the order number of SW of the list of SWs, which is detected as a post-wave. Ex: If indexP300=1, it means the first SW in the list is a post-wave

		if ~isempty(indexP300) 					% in the case we have found something as a post-wave, then we can find the time of the post-wave. (It has no sense to search the time of post-wave if we haven't found any post-wave)
			countP300 = countP300+1;			% We only add 1, not 2 or 3 because, even if we find 2 post-wave or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one post-wave per OA.
			if length(indexP300) == 1
				disp(['     -> Possible post-wave :    ', num2str(SW(1,indexP300).valmin), ' microV at ', num2str(SW(1,indexP300).negpeak_seconds), 's;    ', num2str(SW(1,indexP300).valmax), ' microV at ', num2str(SW(1,indexP300).pospeak_seconds), 's']);
			elseif length(indexP300) == 2 	
				disp(['     -> Possible post-wave :    ', num2str(SW(1,indexP300(1)).valmin), ' microV at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(1)).valmax), ' microV at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexP300(2)).valmin), ' microV at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(2)).valmax), ' microV at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);		
			elseif length(indexP300) == 3	
				disp(['     -> Possible post-wave :    ', num2str(SW(1,indexP300(1)).valmin), ' microV at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(1)).valmax), ' microV at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexP300(2)).valmin), ' microV at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(2)).valmax), ' microV at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexP300(3)).valmin), ' microV at ', num2str(SW(1,indexP300(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(3)).valmax), ' microV at ', num2str(SW(1,indexP300(3)).pospeak_seconds), 's']);			
			elseif length(indexP300) == 4	
				disp(['     -> Possible post-wave :    ', num2str(SW(1,indexP300(1)).valmin), ' microV at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(1)).valmax), ' microV at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexP300(2)).valmin), ' microV at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(2)).valmax), ' microV at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexP300(3)).valmin), ' microV at ', num2str(SW(1,indexP300(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(3)).valmax), ' microV at ', num2str(SW(1,indexP300(3)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexP300(4)).valmin), ' microV at ', num2str(SW(1,indexP300(4)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(4)).valmax), ' microV at ', num2str(SW(1,indexP300(4)).pospeak_seconds), 's']);							
			end 	
		else 	
			disp(['     -> No post-wave  detected'])
		end

		%% The current zone around the oa(i) is now a new part of 'deadzone'
		if floor(oa(i)) - def.OAsemiwindow > 0 
			lowerboundwindow = floor(oa(i)) - def.OAsemiwindow;
		else 
			lowerboundwindow = 1;										% Not 0 because 0 is not authorized as an index 
		end 

		
		if ceil(oa(i)) + def.OAsemiwindow < ceil(length(V)/def.rate)
			upperboundwindow =  ceil(oa(i)) + def.OAsemiwindow;
		else 
			upperboundwindow = ceil(length(V)/def.rate);
		end 	
		
			
		deadzone(lowerboundwindow:upperboundwindow) = 1;		
	
	end
end

oa_new = find(oa ~= 0);			% or 		find (oa > 0 )

disp(' ');
if countOA ~= 0 
	disp('*********************************************************************************************************');
end	
% disp('---------------------------------------------------------------------------------------------------------');
% disp('************************************* List of random windows ********************************************');
disp(' ');
%% Find if there is at least 1 SW in each window
% for i = 1 : length(oa)														% Reduce the length of oa; otherwise it will put a window around each oa < 2 seconds, which is an inconvenient because it detects more random slow waves which are not necessary
for i = 1 : length(oa_new)
	% Update the zone of accessible and authorized centers 
	possiblecenters = find(deadzone == 0);										% for the first iteration, this is simple because deadzone is the first deadzone determined. But at each iteration, possiblecenters is updated because at each iteration a new part of 'deadzone' will be added
	
	% Build the current random window
	randindex = round(rand(1) * length(possiblecenters));  						% Choose a random index of possiblecenters and round it into an integer
	if randindex>0 
		randcenter = possiblecenters(randindex);
	else 
		randcenter = possiblecenters(1);
	end 
	
	if randcenter-def.OAsemiwindow/2 >0 
		randwindow = [floor(randcenter-def.OAsemiwindow/2), floor(randcenter+def.OAsemiwindow/2)];	% 1 colon for the lowerbound, 1 colon for the upperbound
	else 
		randwindow = [1, floor(randcenter+def.OAsemiwindow/2)];
	end
	% if randcenter-def.OAsemiwindow >0 
		% randwindow = [randcenter-def.OAsemiwindow, randcenter+def.OAsemiwindow];	% 1 colon for the lowerbound, 1 colon for the upperbound
	% else 
		% randwindow = [1, randcenter+def.OAsemiwindow];
	% end	
	
	if randwindow(1) == 0		
		randwindow(1) =1;
	end 
	
	% Find random SW in the random window
	indexrandSW = find([SW(1,:).negpeak_seconds] < randwindow(2)  &  [SW(1,:).negpeak_seconds] > randwindow(1) );	% gives the order number of SW of the list of SWs, which is detected as a random SW. Ex: If indexrandSW=1, it means the first SW in the list is a rand SW
	% disp(' ');
	disp(['Random window ', num2str(i), ': [', num2str(randwindow(1)), 's, ', num2str(randwindow(2)), 's]']);	
	% disp(['Random window ', num2str(i), ' is from ', num2str(randwindow(1)), 's to ', num2str(randwindow(2)), 's']);	
	if ~isempty(indexrandSW) 					% in the case we have found something as a rand SW, then we can find the time of the rand SW. (It has no sense to search the time of rand SW if we haven't found any rand SW)
		countrandSW = countrandSW+1;			% We only add 1, not 2 or 3 because, even if we find 2 rand SW or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one rand SW per OA.
		if length(indexrandSW) == 1
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW).valmin), ' microV at ', num2str(SW(1,indexrandSW).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW).valmax), ' microV at ', num2str(SW(1,indexrandSW).pospeak_seconds), 's']);
		elseif length(indexrandSW) == 2 	
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW(1)).valmin), ' microV at ', num2str(SW(1,indexrandSW(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(1)).valmax), ' microV at ', num2str(SW(1,indexrandSW(1)).pospeak_seconds), 's']);
			disp(['                        ', num2str(SW(1,indexrandSW(2)).valmin), ' microV at ', num2str(SW(1,indexrandSW(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(2)).valmax), ' microV at ', num2str(SW(1,indexrandSW(2)).pospeak_seconds), 's']);		
		elseif length(indexrandSW) == 3	
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW(1)).valmin), ' microV at ', num2str(SW(1,indexrandSW(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(1)).valmax), ' microV at ', num2str(SW(1,indexrandSW(1)).pospeak_seconds), 's']);
			disp(['                        ', num2str(SW(1,indexrandSW(2)).valmin), ' microV at ', num2str(SW(1,indexrandSW(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(2)).valmax), ' microV at ', num2str(SW(1,indexrandSW(2)).pospeak_seconds), 's']);		
			disp(['                        ', num2str(SW(1,indexrandSW(3)).valmin), ' microV at ', num2str(SW(1,indexrandSW(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(3)).valmax), ' microV at ', num2str(SW(1,indexrandSW(3)).pospeak_seconds), 's']);			
		elseif length(indexrandSW) == 4	
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW(1)).valmin), ' microV at ', num2str(SW(1,indexrandSW(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(1)).valmax), ' microV at ', num2str(SW(1,indexrandSW(1)).pospeak_seconds), 's']);
			disp(['                        ', num2str(SW(1,indexrandSW(2)).valmin), ' microV at ', num2str(SW(1,indexrandSW(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(2)).valmax), ' microV at ', num2str(SW(1,indexrandSW(2)).pospeak_seconds), 's']);		
			disp(['                        ', num2str(SW(1,indexrandSW(3)).valmin), ' microV at ', num2str(SW(1,indexrandSW(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(3)).valmax), ' microV at ', num2str(SW(1,indexrandSW(3)).pospeak_seconds), 's']);		
			disp(['                        ', num2str(SW(1,indexrandSW(4)).valmin), ' microV at ', num2str(SW(1,indexrandSW(4)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(4)).valmax), ' microV at ', num2str(SW(1,indexrandSW(4)).pospeak_seconds), 's']);							
		end 	
	else 	
		% disp(['     -> No random SW detected'])
		disp(['     -> No SW detected'])
	end
	
	%% Avoid the doubloons of random windows: state the current random window is now a deadzone (i.e. useless to access it at a further iteration)
	deadzone(randwindow(1):randwindow(2)) = 1;			% The zone from current lowerbound and upperbound have become a new part of deadzone because we don't wanna detect twice the same SW
end 	


%% DISPLAY THE RESULTS
disp(' ');
disp('*********************************************************************************************************');
if countOA > 1
	% disp(['For a total of ', num2str(length(oa)), ' operant actions,'])			% length(oa) can be higher than countOA so this is important to write countOA instead
	disp(['For a total of ', num2str(countOA), ' operant actions,'])
 	% disp(['There are ', num2str(length(oa)), ' operant actions.'])			
elseif countOA  == 1 
	disp('There is only 1 operant action.')
else 
	disp('There is no operant action.')
end 	

% NumberOAhavingBP = countBP						% Display the number of operant actions having at least 1 pre-wave (1 or 2 or more pre-wave per operant action)
if countBP > 1 
	disp([' - ', num2str(countBP), ' operant actions show at least one pre-wave .'])
elseif countBP == 1 	
	disp(' - 1 operant action shows at least one pre-wave .')
else 
	disp(' - No operant action shows at least one pre-wave .')
end	

%% Display the number of operant actions having at least 1 post-wave (1 or 2 or more post-wave per operant action)
if countP300 > 1 
	disp([' - ', num2str(countP300), ' operant actions show at least one post-wave .'])
elseif countP300 == 1 	
	disp(' - 1 operant action shows at least one post-wave .')
else 
	disp(' - No operant action shows at least one post-wave .')
end	

if countrandSW > 1 
	disp([' - ', num2str(countrandSW), ' of the ', num2str(countOA), ' random windows show at least one SW (which is neither pre-wave or post-wave).'])
elseif countrandSW == 1 	
	disp([' - 1 of the ', num2str(countOA), ' random windows shows at least one SW (which is neither pre-wave nor post-wave ).'])
else 
	disp([' - 0 of the ', num2str(countOA), ' random windows shows at least one SW.'])
end	
disp('*********************************************************************************************************');
disp(' ');
