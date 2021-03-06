% This function aims to find slow waves. The argument of this function is the low-pass filtered signal.

% The criteria used are CRC's criteria (which were based on Massimini's but were softened to detect all waves) and we had to adapt the corresponding values of thresholds (see lfp_defaults.m):
% - criterion on slope between the negative and the positive peaks: criteria of minimum percentile 90 (has been added to the Massimini criteria)
% - magnitude criteria in microV (minimum negative peak amplitude, minimum total peak-to-peak magnitude) 
% - duration criteria in ms (duration of negative peak, duration between the up zero-crossing subsequent to negative peak and the down zero-crossing subsequent to the positive peak). 

% At indexes of downward zero-crossing, negative peak, upward zero-crossing and positive peak, the vector 'red' returned by the function 'find_artifacts' 
% is useful to indicate if these indexes are parts of artifacts or not.
% (When an artifact is detected, the algorithm skips the event and doesn't check if it's a slow wave)

% This function was built based on 'crc_SWS_detect' written by J. Schrouff & C. Phillips, 2009, Cyclotron Research Centre, University of Liege, Belgium
% from the FASST toolbox: Leclercq Y., Schrouff J., Noirhomme Q., Maquet P. and Phillips C. (2011) 
% fMRI Artefact Rejection and Sleep Scoring Toolbox, Computational Intelligence and Neuroscience, vol. 2011, Article ID, 598206, 11 pages. doi:10.1155/2011/598206.


function SW = find_slow_waves(V)
global def b red t		
SW = struct('negpeak_seconds', [], 'pospeak_seconds', [], 'valmin', [], 'valmax', []);
countwaves=0;
F1 = zeros(1,size(V,1)); 
F2 = zeros(1,size(V,1)); 
F3 = zeros(1,size(V,1)); 
F1 = V';				
F2 = sign(V');			
DZC = find(diff(F2)== -2);	

% Criterion of maximum slope index percentile 90
F3 = [0 diff(V')]; 		
MSI_plot = zeros(1, size(F1,2));											
MSI_plot(find( F3 > crc_percentile(F3, def.percentile) )) = 100;
MSI = find(MSI_plot==100); 												

for imsi=1:size(MSI,2)-1		
    %% Find nearest MSI and DZC
    indiceDZC = find((DZC-MSI(imsi))<0);	
    if ~isempty(indiceDZC)			
        indiceDZC=indiceDZC(end);			% Keep only the last element of indiceDZC
        iDZC=DZC(indiceDZC);		
    else							
        iDZC=1;						
    end
	
	if red(iDZC) == 0  						% Check there's no artifact at the index iDZC 
		[valmin,indposmin]=min(F1(iDZC:MSI(imsi)));
		posmin = iDZC-1 +indposmin;		
		
		%% Negative peak magnitude
		if valmin <= def.SWmAmpl(1)					
		
			upperbound = size(F1,2) - (iDZC + def.rate * def.SWlength(2) /1000); 	   
			if upperbound >0
				iUZC = find(diff(F2(iDZC:iDZC+round(def.rate* def.SWlength(2)/1000))) == 2)+ iDZC-1; 	
			else
				iUZC= find(diff(F2(iDZC:end)) ==2) + iDZC-1;
			end	
			if ~isempty(iUZC)&& ~isempty(indiceDZC)	&& red(posmin)==0					
				iUZC=iUZC(1);		

			
				% Criterion on negative peak magnitude
				if ((iUZC-iDZC) <= 	(def.SWlength(2)*def.rate/1000) && ...
									(def.SWlength(1)*def.rate/1000) <= (iUZC-iDZC) )	&& ...
					red(iUZC) == 0								

					%% Negative peak magnitude
					
					upperboundPicPositif = size(F1,2) - (iUZC +(def.rate*def.SWlength(3)/1000));
					if upperboundPicPositif > 0
						% if ((indiceDZC+7)<size(DZC,2)) && (DZC(indiceDZC+7)-iUZC < def.rate*def.SWlength(3)/1000)
							% [valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+7)));							
							% disp('indiceDZC+7');						
						% elseif ((indiceDZC+6)<size(DZC,2)) && (DZC(indiceDZC+6)-iUZC < def.rate*def.SWlength(3)/1000)
							% [valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+6)));							
							% disp('indiceDZC+6');						
						% if ((indiceDZC+5)<size(DZC,2)) && (DZC(indiceDZC+5)-iUZC < def.rate*def.SWlength(3)/1000)
							% [valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+5)));							
							% disp('indiceDZC+5');											% TEST 								
						% if ((indiceDZC+4)<size(DZC,2)) && (DZC(indiceDZC+4)-iUZC < def.rate*def.SWlength(3)/1000)
							% [valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+4)));							
							% disp('indiceDZC+4');											% TEST 					
						if ((indiceDZC+3)<size(DZC,2)) && (DZC(indiceDZC+3)-iUZC < def.rate*def.SWlength(3)/1000)
							[valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+3)));							
							% disp('indiceDZC+3');											% TEST 
						elseif 	   ((indiceDZC+2)<size(DZC,2)) && (DZC(indiceDZC+2)-iUZC < def.rate*def.SWlength(3)/1000)			% We examine between iUZC and the DZC after the next DZC (we want to find the maximum, not the derivative)
							[valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+2)));				
							% disp('indiceDZC+2');											% TEST 
						elseif ((indiceDZC+1)<size(DZC,2)) && (DZC(indiceDZC+1)-iUZC < def.rate*def.SWlength(3)/1000)			% If the DZC after the next DZC is too far (i.e. is above duration threshold),
							[valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+1)));									% then we examine between iUZC and the next DZC (we want to find the maximum, not the derivative)
							% disp('indiceDZC+1');											% TEST 
						else 
							indposmax = [];
						end
						% disp('duration between the up-zero-crossing subsequent to negative peak and the down-zero-crossing subsequent to positive peak, is ok');
					else
						[valmax, indposmax]= max(F1(iUZC:end));
					end
					
					if ~isempty(indposmax)
						posmax = iUZC-1 + indposmax;
						% disp(num2str(valmax));


						if	red(posmax) == 0
						% disp('No artifact');
						%% Criterion on peak to peak magnitude 				
							if (abs(valmax) + abs (valmin)) >= def.SWmAmpl(2)
								% disp('Criterion on peak to peak magnitude respected');
		 
								if  isempty(SW(end).negpeak_seconds) || ... % nothing in SW.negpeak (1st pass)
										((all(abs(posmin - squeeze(cat(1,SW(:).negpeak_seconds) *def.fsample))  > def.rate*def.SWlength(4)/1000))&&...   % need ... ms between SW negativity
										 (all(abs(posmax - squeeze(cat(1,SW(:).pospeak_seconds) *def.fsample))  > def.rate*def.SWlength(4)/1000)))    								
										 
										countwaves = countwaves+1;    
										disp(' ');		
										disp(['SW', num2str(countwaves), ':    ', num2str(valmin) ' microV at ', num2str(posmin/def.fsample), 's;    ', num2str(valmax), ' microV at ', num2str(posmax/def.fsample), 's']) 										

										SW(countwaves).negpeak_seconds = 	posmin /def.fsample ;   % negative peak position in s
										SW(countwaves).pospeak_seconds = 	posmax /def.fsample ;   % positive peak position in s
										SW(countwaves).valmin = 			valmin ;   				% amplitude of negative peak in microV
										SW(countwaves).valmax = 			valmax ;   				% amplitude of positive peak in microV
								end
							end 
						end	
					end
				end 	
			end			
		end				
	end 	
end           

disp(' ');
if countwaves == 0 
	disp('----> No slow wave detected');	
elseif countwaves == 1 
	disp('----> 1 slow wave detected');
else
	disp(['----> ', num2str(countwaves), ' slow waves detected'])
end 



%% DISPLAY FEATURES OF ALL SLOW WAVES
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% for c = 1 : countwaves 
	% disp(' ');
	% disp(['SW', num2str(c), ':']);
	% SW = SW(1, c);
% end 
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
