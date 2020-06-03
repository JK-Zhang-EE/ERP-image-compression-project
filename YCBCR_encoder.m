function [All_bitstreams,encoding_time,WPSNR,New_X_hat_float] = YCBCR_encoder(X_float)


timer1 = tic;


X = uint8(X_float);
X_YCBCR = rgb2ycbcr(X);
X_YCBCR_float = double(X_YCBCR);


% Defined
filter_size = 8;
YCbCr_sample = 4;

% JPEG QT
Q_table=[16 11 10 16 24 40 51 61
         12 12 14 19 26 58 60 55
         14 13 16 24 40 57 69 56
         14 17 22 29 51 87 80 62
         18 22 37 56 68 109 103 77
         24 35 55 64 81 104 113 92
         49 64 78 87 103 121 120 101
         72 92 95 98 112 100 103 99];

% Use my dct2 function
A = mydct2(filter_size);

% zapzag function
zz_matrix = my_zipzag(filter_size);


%% Preprocessing

[image_length ,image_width, image_chanel] = size(X_YCBCR_float);

% Padding
copy_image = X_YCBCR_float;

remainder_width = mod(image_width,filter_size);
remainder_length = mod(image_length,filter_size);
New_image_length = image_length;
New_image_width = image_width;

if remainder_length ~= 0
    New_image_length = image_length + (filter_size-remainder_length);
    copy_image(image_length+1:New_image_length,1:image_width) = 0;
end
    
if remainder_width ~= 0
    New_image_width = image_width + (filter_size-remainder_width);
    copy_image(1:New_image_length,image_width+1:New_image_width) = 0;
end

% Do the YCbCr sampling
New_image = copy_image;
for i=2:3
    for j=1:image_length/YCbCr_sample
        for k =1:image_width/YCbCr_sample
            part_ycbcr = fix(mean(mean(copy_image(j*YCbCr_sample-(YCbCr_sample-1):j*YCbCr_sample,k*YCbCr_sample-(YCbCr_sample-1):k*YCbCr_sample,i))));
            New_image(j*YCbCr_sample-(YCbCr_sample-1):j*YCbCr_sample,k*YCbCr_sample-(YCbCr_sample-1):k*YCbCr_sample,i) = part_ycbcr;
        end
    end
end

%% Start encoding processing

% adjust RGB or Gray image
if image_chanel > 1
    image_loop = 3;
else
    image_loop = 1;
end



dicts = {};
All_bitstreams = [];
All_cells = {};

for j = 1:image_loop
    
    New_copy_image = New_image(:,:,j);
        
    % build_cells function ---> Output is 'All_cells'
    All_cells{1,j} = build_cells(New_copy_image,filter_size,A,Q_table,zz_matrix);
    
    % Output is 'p_matrix' , 'cells_num': different symbols of whole cells
     [p_matrix, cells_num] = distinguish_cells(All_cells{1,j});

    % Huffman coding
    % VLC length = 'Huff_length'
    p_matrix_sum = 0;
    for i=1:length(p_matrix)
        p_matrix_sum = p_matrix_sum + p_matrix{i,2};
    end

    % calculate the probability of all symbols
    prob = zeros(length(p_matrix),1);
    symbols = cell(length(p_matrix),1);

    for i=1:length(p_matrix)
        symbols{i,1} = p_matrix{i,1};
        prob(i) = p_matrix{i,2}/p_matrix_sum;
    end

    [dict, avg] = huffmandict(symbols,prob);
    dicts{1,j} = dict;
    VLC_length = avg;

   
    %% encoding to 'bitstreams'

    % Use my_encoding function ---> 'bitstream'
    bitstreams = my_encoding(All_cells{1,j},dict);
    All_bitstreams = [All_bitstreams bitstreams];

    
end

encoding_time = toc(timer1);




X_part_hat = [];
New_X_hats = {};

All_cell_hat = All_cells;
for loop = 1:length(All_cell_hat)
    X_hat = [];
    New_X_hat = [];
    for k= 1:length(All_cell_hat{1,loop})
        Index_table_hat = zeros(length(Q_table));
        Index_value_matrix_hat = [];

        % Expand the Symbols to 1*64 matrix
        for i = 1:length(All_cell_hat{1,loop}{k})
            Index_value = All_cell_hat{1,loop}{1,k}{i};

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

    [m,n,channel] = size(X_YCBCR);
    New_X_hat = zeros(m,n);
    for i=1:length(X_hat)/n
            New_X_hat(8*i-7:8*i,1:n) = X_hat(1:8,n*i-(n-1):n*i);
    end
    
    New_X_hats{1,loop} = New_X_hat; 
    
end

% Remove padding result
New_X_hat = [];
for i = 1:length(New_X_hats)
    New_X_hat(:,:,i) = New_X_hats{1,i}(1:image_length,1:image_width);
end

New_X_hat_1 = ycbcr2rgb(uint8(New_X_hat));
New_X_hat_float = double(New_X_hat_1);

mean_total = [];
for loop = 1:image_chanel
    for i=1:image_length
        mean_total(1,i) = mean((X_float(i,:,loop)-New_X_hat_float(i,:,loop)).^2.*cos((i+0.5-image_length/2)*pi/image_length));
    end
    WMSE(1,loop) = mean(mean_total);
end

WPSNR = 10*log10(255.^2/mean(WMSE));




