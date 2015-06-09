% Please re-name each structure SW as follows: 		SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9

% >>     [mean_SW, SD_SW] = mean_and_SD(SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9)


function [mean_SW, SD_SW] = mean_and_SD(SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9)
% function [mean_SW, SD_SW,   mean_countBP, SD_countBP,    mean_P3, SD_P3,    mean_rand, SD_rand] = mean_and_SD(SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8, SW_9,      countBP_2, countBP_3, countBP_4, countBP_5, countBP_6, countBP_7, countBP_8, countBP_9,      countP300_2, countP300_3, countP300_4, countP300_5, countP300_6, countP300_7, countP300_8, countP300_9,         countrandSW_2, countrandSW_3, countrandSW_4, countrandSW_5, countrandSW_6, countrandSW_7, countrandSW_8, countrandSW_9, )

n = 8; 

mean_SW = 1/n * (length(SW_2) + length(SW_3) + length(SW_4) + length(SW_5) + length(SW_6) + length(SW_7) + length(SW_8) + length(SW_9)); 			% \sum p_i *x_i  

sum_of_squares_SW =  length(SW_2)^2 + length(SW_3)^2 + length(SW_4)^2 + length(SW_5)^2 + length(SW_6)^2 + length(SW_7)^2 + length(SW_8)^2 + length(SW_9)^2;

SD_SW = sqrt( 1/n * sum_of_squares_SW - mean_SW^2 ); 




%% Mean and SD for pre-waves 
% mean_countBP = 1/n * (length(countBP_2) + length(countBP_3) + length(countBP_4) + length(countBP_5) + length(countBP_6) + length(countBP_7) + length(countBP_8) + length(countBP_9)); 			% \sum p_i *x_i  

% sum_of_squares_countBP =  length(countBP_2)^2 + length(countBP_3)^2 + length(countBP_4)^2 + length(countBP_5)^2 + length(countBP_6)^2 + length(countBP_7)^2 + length(countBP_8)^2 + length(countBP_9)^2;

% SD_countBP = sqrt( 1/n * sum_of_squares_countBP - mean_countBP^2 ); 


%% Mean and SD for post-waves 
% mean_P3 = 1/n * (length(countP300_2) + length(countP300_3) + length(countP300_4) + length(countP300_5) + length(countP300_6) + length(countP300_7) + length(countP300_8) + length(countP300_9)); 			% \sum p_i *x_i  

% sum_of_squares_P3 =  length(countP300_2)^2 + length(countP300_3)^2 + length(countP300_4)^2 + length(countP300_5)^2 + length(countP300_6)^2 + length(countP300_7)^2 + length(countP300_8)^2 + length(countP300_9)^2;

% SD_P3 = sqrt( 1/n * sum_of_squares_P3 - mean_P3^2 ); 


%% Mean and SD for random slow waves
% mean_rand = 1/n * (length(countrandSW_2) + length(countrandSW_3) + length(countrandSW_4) + length(countrandSW_5) + length(countrandSW_6) + length(countrandSW_7) + length(countrandSW_8) + length(countrandSW_9)); 			% \sum p_i *x_i  

% sum_of_squares_rand =  length(countrandSW_2)^2 + length(countrandSW_3)^2 + length(countrandSW_4)^2 + length(countrandSW_5)^2 + length(countrandSW_6)^2 + length(countrandSW_7)^2 + length(countrandSW_8)^2 + length(countrandSW_9)^2;

% SD_rand = sqrt( 1/n * sum_of_squares_rand - mean_rand^2 ); 



