% Function computing the mean and standard deviation of the amount of slow waves on all channels. 

% Please re-name each structure SW as follows: 		SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9

% >>     [mean_SW, SD_SW] = mean_and_SD(SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9)


function [mean_SW, SD_SW] = mean_and_SD(SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9)

n = 8; 

mean_SW = 1/n * (length(SW_2) + length(SW_3) + length(SW_4) + length(SW_5) + length(SW_6) + length(SW_7) + length(SW_8) + length(SW_9)); 			% \sum p_i *x_i  

sum_of_squares_SW =  length(SW_2)^2 + length(SW_3)^2 + length(SW_4)^2 + length(SW_5)^2 + length(SW_6)^2 + length(SW_7)^2 + length(SW_8)^2 + length(SW_9)^2;

SD_SW = sqrt( 1/n * sum_of_squares_SW - mean_SW^2 ); 




