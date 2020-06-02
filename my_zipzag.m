function zz_matrix = my_zipzag(matrix_size)


% zigzag function
% 分成左上半部 & 右下半部 (以對角線作為區分)
% zz_matrix 為輸出, m = 矩陣大小
count_odd = 0;
count_even = 0;
loop = 2*matrix_size-1;
for i = 1:loop

    % odd state
    if count_odd == 1
        
        % 判斷是否過了對角線 (右下角)
        if i > matrix_size
            elements_num = loop - i + 1;
            matrix_val = [matrix_size,i-matrix_size+1];
        else     % 前半部 (左上角)
            matrix_val = [i,1];
            elements_num = i;
        end
            
        for j = 1:elements_num
            if j == 1
                zz_matrix = [zz_matrix;matrix_val];
            else
                matrix_val = [matrix_val(1)-1 matrix_val(2)+1];
                zz_matrix = [zz_matrix;matrix_val];
            end
        end
 
        count_odd = 0;
        count_even = 1;
      
    % even state    
    elseif count_even == 1
        
        if i > matrix_size
            elements_num = loop - i + 1;
            matrix_val = [i-matrix_size+1,matrix_size];
        else
            matrix_val = [1,i];
            elements_num = i;                       
        end
            
        for j = 1:elements_num
            if j ==1
                zz_matrix = [zz_matrix;matrix_val];
            else
                matrix_val = [matrix_val(1)+1 matrix_val(2)-1];
                zz_matrix = [zz_matrix;matrix_val];
            end
        end  

        count_odd = 1;
        count_even = 0;
    end

    % initial state
    if i == 1
        zz_matrix = [1 1];
        count_even = 1; 
    end
end