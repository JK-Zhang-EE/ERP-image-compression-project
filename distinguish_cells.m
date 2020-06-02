function [p_matrix, count_num] = distinguish_cells(All_cells)


p_matrix = cell(1,5);
for i = 1:length(p_matrix)
    p_matrix{1,i} = [0 0];
    p_matrix{2,i}(1) = 0;
end


% Use loop finding different symbols of whole cells
% Output is 'p_matrix' , 'count_num': different symbols of whole cells
count_num = 0;
count_mode = 0;
for i = 1:length(All_cells)
    for j = 1: length(All_cells{1,i})
        if ischar(All_cells{1,i}{1,j})
            break
        else
            for k = 1:length(p_matrix)
                if  (All_cells{1,i}{1,j}(1) == p_matrix{1,k}(1)) && (All_cells{1,i}{1,j}(2) == p_matrix{1,k}(2))
                    p_matrix{2,k}(1) = p_matrix{2,k}(1) + 1;
                    count_mode = 1;                   
                    
                    break
                else
                    count_mode = 0;
                end
            end
            if count_mode ~= 1
                count_num = count_num + 1;
                p_matrix{1,count_num} = All_cells{1,i}{1,j};
                p_matrix{2,count_num}(1) = 1;
                count_mode = 0;
            end
            
        end
    end
end


% transpose the p_matrix
p_matrix{1,count_num+1} = 'EOB';
p_matrix{2,count_num+1} = length(All_cells);


p_matrix = p_matrix';







