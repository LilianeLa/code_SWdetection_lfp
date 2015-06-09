% The aim of this function is to detect at which indexes are localised the artifacts, and display them in a list. 
% For this purpose, a vector (named 'red') initialized as a vector of 0 of same length as the original signal, will be used. Its aim is to indicate the occurrences of artifacts: 
% the vector will take the value "1" for each timepoint index of the original signal, when corresponding to an artifact. 

% 'red' will be used in 'find_slow_waves' to indicate if there is an artifact (value equal to 1), or not (value equal to 0)
% 1) For all timepoints where the voltage amplitude (of the high-pass filtered signal) is higher than def.amplitude_artifact, 
%			-> 'red' takes the value 1 at the corresponding time-point index 
% 2) For all timepoints comprised between 2 indexes of the first loop, and verifying def.artifact_cut_length (i.e. not far from each other)
% 		-> 'red' takes the value 1 at all these time-point indexes
% 3) For all timepoints corresponding to the slow component of the artifact,
% 		-> 'red' takes the value 1 

% In 'find_slow_waves', 'red' will be checked at indexes of downward zero-crossing, negative peak, upward zero-crossing and positive peak, to see if they are part of artifact or not.
% (When there is an artifact detected, the algorithm skip the event and doesn't check if it's a slow wave)

% For each detected artifact, are displayed:
% 1. the beginning of the artifact, which is the beginning of the fast component;
% 2. the end of the fast component;
% 3. the end of the first sub-component2 in the slow component, if a slow component exists. It is defined as the first zero-crossing occurring just after the last high value of the first sub-component) 3;
% 4. the end of the total artifact: either the end of the slow component (in most cases), or the end of fast component if there is no slow component;

% NB: thresholds from lfp_defaults used in this file (the user can modify them if necessary). 
% def.butterorder = 2; 		
% def.fcuthigh = 100 ; 					
% def.amplitude_artifact = 35;			% Threshold of amplitude of the fast component of the artifact = amplitude in the high-pass filtered signal 
% def.artifact_cut_length = 1.7*def.fsample;			
% def.amplitude_slow_artifact = 27;		% Threshold of amplitude of the slow component of the artifact 
% def.endslow = 1;						% Maximal interval authorized between the first high value found for bLP and the first zero-crossing (in seconds)
% def.amplitudediapason = 16;				
% def.durationdiapason = 0.65;			
% def.duration_slow_artifact	= 1;		


function [red, bHP] =  find_artifacts(V)	
global def b t bHP	s	
b = butterworth_low_pass(V);
s = t/ def.rate;


[num,den] = butter(def.butterorder, def.fcuthigh/(def.fsample/2), 'high'); 		
bHP = filter(num,den,V); 

%% Initialization
red = zeros(1, size(V,1));
countartifacts=0;

%% Find the peaks of high amplitude in the high-pass filtered signal 
iHighBHP = find(abs(bHP) > def.amplitude_artifact);
red(iHighBHP) = 1;  		% red(iHighBHP) = V(iHighBHP);   						% the signal "red" takes the value 1. It indicates if there is an artifact (value 1) or not (value 0)

%% Artifact 1
if iHighBHP ~= 0 
	countartifacts = 1;   
	beginplot = iHighBHP(1);
end 						
												
%% Consider each interval between 2 peaks as belonging to the same artifact if the 2 peaks are not far from each other 
for h = 1 : length(iHighBHP)-1												
	if  (iHighBHP(h+1) - iHighBHP(h) < def.artifact_cut_length) 			% If the current peak and the following peak are close enough, this means they belong to the same artifact and not to neighbour artifacts
																									% The portion of signal between these 2 peaks is identified as a portion of artifact		 
		red(iHighBHP(h):iHighBHP(h+1)) = 1;										% This segment between the 2 peaks is no longer equal to zero: it takes the corresponding value 1. 
																									
	else																							% The case "else" means we have reached the end of the fast component; and the artifact is not the only one but there are other artifact(s) afterwards
		upperboundmax = iHighBHP(h)+ def.duration_slow_artifact *def.rate;	% As this is the end of fast component, we now examine if there is a slow component.
		testupperboundmax = length(V) - upperboundmax;
		if testupperboundmax > 0 
			iHighBLP = find(abs(b(iHighBHP(h)+1 : upperboundmax)) > def.amplitude_slow_artifact) + iHighBHP(h); 
		else 
			iHighBLP = find(abs(b(iHighBHP(h)+1 : end)) > def.amplitude_slow_artifact) + iHighBHP(h); 
		end 		
		
		if ~isempty(iHighBLP)		
			ZC = min(find(V( iHighBLP(end) : iHighBLP(end)+ def.endslow *def.rate) ==0)) + iHighBLP(end); 	% The first ZC encountered, just after the last high-value of slow component
			if ~isempty(ZC) 												
				endplot = ZC;
				if countartifacts~=1 
					disp(['A', num2str(countartifacts),  ' begins at ', num2str(beginplot/def.fsample), 's;    ',...
						 num2str(iHighBHP(h)/def.fsample), 's: end of fast comp.;    ',... 		
						 num2str(ZC/def.fsample), 's: end of first slow comp.']);
				else 
					disp(['A1 begins at ', num2str(iHighBHP(1)/def.fsample), 's;    ',...					
						 num2str(iHighBHP(h)/def.fsample), 's: end of fast comp.;    ',... 		
						 num2str(ZC/def.fsample), 's: end of first slow comp.']);
				end
			else 																
				endplot = iHighBLP(end) + def.endslow *def.rate;	
				if countartifacts~=1 
					disp(['A', num2str(countartifacts),  ' begins at ', num2str(beginplot/def.fsample), 's;    ',...
						 num2str(iHighBHP(h)/def.fsample), 's: end of fast comp.;    ',... 		
						'       ?: end of first slow comp. (no ZC found)']);					
				else 
					disp(['A1 begins at ', num2str(iHighBHP(1)/def.fsample), 's;   ',...					
						 num2str(iHighBHP(h)/def.fsample), 's: end of fast comp.;    ',... 		
						'       ?: end of first slow comp. (no ZC found)']);						
				end				
			end
			% red(iHighBHP(h)+1 :ZC) = V(iHighBHP(h)+1 :ZC);	
			red(iHighBHP(h)+1 :endplot) = 1;			% red(iHighBHP(h)+1 :endplot) = V(iHighBHP(h)+1 :endplot);			
		else 
			if countartifacts~=1 
				disp(['A', num2str(countartifacts),  ' begins at ', num2str(beginplot/def.fsample), 's;    ',...
					num2str(iHighBHP(h)/def.fsample), 's: end of fast comp.;    ',... 		
					'        (there''s no slow comp.)']);					
			else 
				disp(['A1 begins at ', num2str(iHighBHP(1)/def.fsample), 's;    ',...					
					num2str(iHighBHP(h)/def.fsample), 's: end of fast comp.;    ',... 	 
					'        (there''s no slow comp.)']);					
			end					
			endplot=iHighBHP(h);
		end						
		
		%% Diapason (we want to see exactly where the slow component ends, as it's possible the slow component lasts several seconds)
		upperbounddiapason = endplot + def.durationdiapason*def.rate;
		testupperbounddiapason = length(V) - upperbounddiapason;
		if testupperbounddiapason > 0 
			abovediapason = find(abs(b(endplot:upperbounddiapason)) > def.amplitudediapason) + endplot;
		else 
			abovediapason = find(abs(b(endplot:end)) > def.amplitudediapason) + endplot; 
		end
		
		if isempty(abovediapason)		% If there's no values above amplitude of diapason, then the "endplot" found is the real ending of the artifact. 
			realending = endplot;
			disp(['                                                           ', num2str(realending/def.fsample), 's: end of total artifact']);		
			disp(['                                                           Nothing above diapason from ', num2str(endplot/def.fsample), 's to ', num2str(upperbounddiapason/def.fsample), 's']);
			% figure; plot(s(endplot:upperbounddiapason), b(endplot:upperbounddiapason)); grid; xlabel('Time [s]');	ylabel('Low-pass filtered signal [microV]');			%%% b_endplot_to_upperbounddiapason = b(endplot:upperbounddiapason)	% TEST
			
		else							% If there are values above amplitude of diapason, then we have to look further to find the real ending of artifact, because what is above diapason is still part of the slow component of artifact. 
			if length(V) - (abovediapason(end)+def.endslow*def.rate) > 0
				realending = min(find(V(abovediapason(end): abovediapason(end)+def.endslow*def.rate)==0)) + abovediapason(end); % The first ZC, appearing just after the last peak of the slow component (exactly like procedeed before to find the endplot ZC, before the step of diapason)

				abovediapason1 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
				if ~isempty(abovediapason1)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
					realending = min(find(V(abovediapason1(end): abovediapason1(end)+def.endslow*def.rate)==0)) + abovediapason1(end);
					
					abovediapason2 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
					if ~isempty(abovediapason2)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
						realending = min(find(V(abovediapason2(end): abovediapason2(end)+def.endslow*def.rate)==0)) + abovediapason2(end);
						
						abovediapason3 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
						if ~isempty(abovediapason3)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
							realending = min(find(V(abovediapason3(end): abovediapason3(end)+def.endslow*def.rate)==0)) + abovediapason3(end);
							
							abovediapason4 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
							if ~isempty(abovediapason4)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
								realending = min(find(V(abovediapason4(end): abovediapason4(end)+def.endslow*def.rate)==0)) + abovediapason4(end);
								
								abovediapason5 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
								if ~isempty(abovediapason5)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
									realending = min(find(V(abovediapason5(end): abovediapason5(end)+def.endslow*def.rate)==0)) + abovediapason5(end);
									
									abovediapason6 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
									if ~isempty(abovediapason6)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
										realending = min(find(V(abovediapason6(end): abovediapason6(end)+def.endslow*def.rate)==0)) + abovediapason6(end);
										
										% abovediapason7 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
										% if ~isempty(abovediapason7)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
											% realending = min(find(V(abovediapason7(end): abovediapason7(end)+def.endslow*def.rate)==0)) + abovediapason7(end);
										% end	
									end									
								end
							end
						end						
					end					
				end

			else	
				realending = min(find(V(abovediapason(end): end)==0)) + abovediapason(end);	
			end
			
			if isempty(realending)
				realending = endplot;	
				disp(['                                                           ', num2str(realending/def.fsample), 's: end of total artifact (arbitrary as no ZC has been found with def.endslow)']);			
				disp(['                                                           Perhaps SW after. Sth above diapason (', num2str(endplot/def.fsample), 's to ', num2str(upperbounddiapason/def.fsample), 's)']);		
			else	% realending has been found and this is a ZC 
				red(endplot:realending) = 1;		% red(endplot:realending) = V(endplot:realending);
				disp(['                                                           ', num2str(realending/def.fsample), 's: end of total artifact']);			
				disp(['                                                           Sth above diapason (', num2str(endplot/def.fsample), 's to ', num2str(upperbounddiapason/def.fsample), 's)']);				
			end 
		end 		
			
		%%%%%% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		%%%%%% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		countartifacts = countartifacts+1;   
		disp(' ');
		beginplot = iHighBHP(h+1);
	end 
end 

%% Last artifact: the last peak of high-pass filtered signal is outside the for-loop. (h+1 gives a MATLAB-error) 
if iHighBHP ~=0					% if ~isempty(iHighBHP)						% We examine the last artifact (unless iHighBHP(end) is empty); but this is very similar to what was done in the loop
	red( (iHighBHP(end)) ) = 1;			% red( (iHighBHP(end)) ) = V( (iHighBHP(end)) );							

	upperboundmax = iHighBHP(end)+ def.duration_slow_artifact *def.rate;
	testupperboundmax = length(V) - upperboundmax;
	if testupperboundmax > 0 
		iHighBLP = find(abs(b(iHighBHP(end)+1 : upperboundmax)) > def.amplitude_slow_artifact) + iHighBHP(end);
	else 
		iHighBLP = find(abs(b(iHighBHP(end)+1 : end)) > def.amplitude_slow_artifact) + iHighBHP(end); 
	end 
	
	if ~isempty(iHighBLP)
		if length(V)- (iHighBLP(end)+ def.endslow *def.rate) > 0
			ZC = min(find(V( iHighBLP(end) : iHighBLP(end)+ def.endslow *def.rate) ==0)) + iHighBLP(end); 	% The first ZC encountered, just after the last high value of slow component 			
		else	
			ZC = min(find(V( iHighBLP(end) : end) ==0)) + iHighBLP(end); 									% The first ZC encountered, just after the last high value of slow component 	
		end
			
		if ~isempty(ZC) 												
			endplot = ZC;
			disp(['A', num2str(countartifacts),  ' begins at ', num2str(beginplot/def.fsample), 's;    ',...
				 num2str(iHighBHP(end)/def.fsample), 's: end of fast comp.;    ',... 		
				 num2str(ZC/def.fsample), 's: end of first slow comp.']);			
		else 															
			endplot = iHighBLP(end) + def.endslow *def.rate;	
			disp(['A', num2str(countartifacts),  ' begins at ', num2str(beginplot/def.fsample), 's;    ',...
				 num2str(iHighBHP(end)/def.fsample), 's: end of fast comp.;    ',... 		
				 '       ?: end of first slow comp. (no ZC found)']);				
		end 		
		
		if endplot < length(V)
			% red(iHighBHP(end)+1 :ZC) = V(iHighBHP(end)+1 :ZC);
			red(iHighBHP(end)+1 :endplot) = 1;		% red(iHighBHP(end)+1 :endplot) = V(iHighBHP(end)+1 :endplot);
		else 
			red(iHighBHP(end)+1 :end) = 1; 			% red(iHighBHP(end)+1 :end) = V(iHighBHP(end)+1 :end);
		end	
		
		% Diapason not here as it's possible there's a slow component further even if the slow component has not yet been detected. 
	else 
		disp(['A', num2str(countartifacts),  ' begins at ', num2str(beginplot/def.fsample), 's;    ',...
			 num2str(iHighBHP(end)/def.fsample), 's: end of fast comp.;    ',... 		
			 '        (there''s no slow comp.)']);			
		endplot = iHighBHP(end);
	end
	
	%% Diapason (we want to see exactly where the slow component ends)
	upperbounddiapason = endplot + def.durationdiapason*def.rate;
	testupperbounddiapason = length(V) - upperbounddiapason;
	if testupperbounddiapason > 0 
		abovediapason = find(abs(b(endplot:upperbounddiapason)) > def.amplitudediapason) + endplot;
	else 
		abovediapason = find(abs(b(endplot:end)) > def.amplitudediapason) + endplot; 
	end
	
	if isempty(abovediapason)		% If there's no peak above amplitude of diapason, then the "endplot" found is the real ending of the artifact. 
		realending = endplot;
		disp(['                                                        ', num2str(realending/def.fsample), 's: end of total artifact']);		
		disp(['                                                        Nothing above diapason from ', num2str(endplot/def.fsample), 's to ', num2str(upperbounddiapason/def.fsample), 's']);
		
	else							% If there's a peak above amplitude of diapason, then we have to look further to find the real ending of artifact, because what is above diapason is still part of the slow component of artifact. 
		if length(V) - (abovediapason(end)+def.endslow*def.rate) > 0
			realending = min(find(V(abovediapason(end): abovediapason(end)+def.endslow*def.rate)==0)) + abovediapason(end); % The first ZC, appearing just after the last peak of the slow component (exactly like procedeed before to find the endplot ZC, before the step of diapason)
		
			abovediapason1 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
			if ~isempty(abovediapason1)		% If there's something above amplitude of diapason, then we can find the new "realending"  
				realending = min(find(V(abovediapason1(end): abovediapason1(end)+def.endslow*def.rate)==0)) + abovediapason1(end);
				
				abovediapason2 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
				if ~isempty(abovediapason2)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
					realending = min(find(V(abovediapason2(end): abovediapason2(end)+def.endslow*def.rate)==0)) + abovediapason2(end);
					
					abovediapason3 = find(abs(b(realending : realending+def.durationdiapason*def.rate)) > def.amplitudediapason) + realending;
					if ~isempty(abovediapason3)		% If there's still something above amplitude of diapason, then we can find again the new "realending"   
						realending = min(find(V(abovediapason3(end): abovediapason3(end)+def.endslow*def.rate)==0)) + abovediapason3(end);
					end
					
				end
			end

		else												% This case won't be developed. 
			realending = min(find(V(abovediapason(end): end)==0)) + abovediapason(end);	
		end
				
		if isempty(realending)
			realending = endplot;	
			disp(['      Perhaps SW after. Sth above diapason (', num2str(endplot/def.fsample), ' to ', num2str(upperbounddiapason/def.fsample), ').   ', num2str(realending/def.fsample), 's: end of total artifact (arbitrary as no ZC has been found with def.endslow)']);		
		else	% realending has been found and this is a ZC 
			red(endplot:realending) = 1;
			% red(endplot:realending) = V(endplot:realending);
			disp(['      Something above diapason (', num2str(endplot/def.fsample), 's to ', num2str(upperbounddiapason/def.fsample), 's).       ', num2str(realending/def.fsample), 's: end of total artifact']);			
		end 
	end 

	%%%%%% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	%%%%%% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
else 
	disp('There''s no artifact');
end



