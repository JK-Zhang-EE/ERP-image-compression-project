function [New_X_hats] = cells2Image(All_cells_hat,filter_size,zz_matrix,Q_table,A,image_src)


% This function is decoding with Huffman method

X_part_hat = [];
X_hat = [];
X_float = image_src;
New_X_hats = {};

for loop = 1:length(All_cells_hat)
    for k= 1:length(All_cells_hat{1,loop})
        Index_table_hat = zeros(length(Q_table));
        Index_value_matrix_hat = [];

        % Expand the Symbols to 1*64 matrix
        for i = 1:length(All_cells_hat{1,loop}{k})
            Index_value = All_cells_hat{1,loop}{1,k}{i};

            % EOB
            if ischar(Index_value)
                    Index_value_matrix_hat(1,length(Index_value_matrix_hat)+1:filter_size^2) = 0;
                break
            else
                if Index_value(1) == 0
                    Index_value_matrix_hat = [Index_value_matrix_hat Index_value(2)];
                else
                    for j=1:Index_value(1)
                        Index_value_matrix_hat = [Index_value_matrix_hat 0];                
                        if j==Index_value(1)
                            Index_value_matrix_hat = [Index_value_matrix_hat Index_value(2)];               
                        end
                    end
                end
            end
        end

        % 1. Transform the sysbols to 8*8 I_hat
        for j= 1:length(zz_matrix)
            zz_cordinate = zz_matrix(j,:);
            Index_table_hat(zz_cordinate(1),zz_cordinate(2)) = Index_value_matrix_hat(j); 
        end

        % 2. I_hat * Q_table to produce New_Y_hat
        % 3. Reconstruct to original image 
        New_part_Y_hat = Index_table_hat.*Q_table;
        X_part_hat = A'*New_part_Y_hat*A;
        X_hat =[X_hat X_part_hat];

    end

    [m,n] = size(X_float);
    New_X_hat = zeros(m,n);
    for i=1:length(X_hat)/n
            New_X_hat(8*i-7:8*i,1:n) = X_hat(1:8,n*i-(n-1):n*i);
    end
    
    New_X_hats{1,loop} = New_X_hat; 
    
end

