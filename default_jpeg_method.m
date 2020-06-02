function [All_bitstreams,encoding_time] = jpeg_encoding(X_float)

% Defined
filter_size = 8;

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

X_float = double(X);

[image_length ,image_width, image_chanel] = size(X_float);

% Padding
copy_image = X_float;

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


%% Start encoding processing


% adjust RGB or Gray image
if image_chanel > 1
    image_loop = 3;
else
    image_loop = 1;
end


timer1 = tic;

dicts = {};
All_bitstreams = [];
All_cells = {};

for j = 1:image_loop
    
    New_copy_image = copy_image(:,:,j);
        
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
%{
% write stream to file
new_image_name = strsplit(image_name,'.');

file_ID = fopen([new_image_name{1} '.abc'],'wb');
fwrite(file_ID,All_bitstreams);
fclose(file_ID);
%}