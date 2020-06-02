function All_cells = build_cells(image_src,filter_size,A,Q_table,zz_matrix)

% Defined
% image size = image_width,image_width
% con_size: filter size of each step

% Use loop find all cells
% Output is 'All_cells',1*1024 cell
%image_src = copy_image;

All_cells = {};
[image_length ,image_width] = size(image_src);

loop1 = image_length/filter_size;
loop2 = image_width/filter_size;

for i=1:loop1
    for j=1:loop2
        A_cell = {};
        Y_partial = A * image_src(filter_size*i-7:filter_size*i,filter_size*j-7:filter_size*j) *A';
        I = fix( Y_partial./Q_table);    
        % cell of Index
        input = I;
        count_zeros = 0;
        count_number = 0;
        for k=1:filter_size^2
            num = zz_matrix(k,:);
            if input(num(1),num(2)) == 0
                count_zeros = count_zeros + 1; 
            else
                count_number = count_number + 1; 
                A_cell{1,count_number} = [count_zeros input(num(1),num(2))];
                count_zeros = 0;
            end

            % End of block
            if k == filter_size^2
                count_number = count_number + 1; 
                A_cell{1,count_number} = 'EOB';
            end
        end
        
        All_cells{1,loop2*(i-1)+j} = A_cell; 

    end
end
