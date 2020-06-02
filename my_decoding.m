function All_cells_hat = my_decoding(All_bitstreams,dicts,src_size)

%src_size = [New_image_length,New_image_width];
% This function is decoding with Huffman method
length_cells = (src_size(1)/8) * (src_size(2)/8);

copy_bitstreams = All_bitstreams;
All_cells_hat = {};

deal_bits = 0;
for loop = 1:length(dicts)
    
    % define the dict max & min bit length
    min_length =  length(dicts{1,loop}{1,2});
    max_length = length(dicts{1,loop}{1,2});
    for i = 1:length(dicts{1,loop})
        if length(dicts{1,loop}{i,2}) < min_length
            min_length = length(dicts{1,loop}{i,2});
        elseif length(dicts{1,loop}{i,2}) > max_length
            max_length = length(dicts{1,loop}{i,2});
        end
    end
    
    cells_hat = cell(1,10);
    symbols_hat = {};
    % search the bits dict for decoding
    count_EOB = 0;
    count_Element = 1;

    % Output is 'All_cells_hat'
    while true
        %disp(['Processing bit length : ' num2str(deal_bits)]);
        decoding_mode = 0;
        for j=min_length:max_length
            
            % adjust the decoding state 
            if decoding_mode == 1
                break
            end

            part_bits = copy_bitstreams(deal_bits+1:j+deal_bits);
            for k=1:length(dicts{1,loop})
                if isequal(part_bits,dicts{1,loop}{k,2})
                    symbols_hat = dicts{1,loop}{k,1};
                    deal_bits = deal_bits + j;
                    decoding_mode = 1;

                    % build the 'All_cells_hat' of decode result
                    if ischar(symbols_hat)
                        count_EOB = count_EOB + 1;
                        cells_hat{1,count_EOB}{1,count_Element} = symbols_hat;
                        count_Element = 1;
                    else
                        cells_hat{1,count_EOB+1}{1,count_Element} = symbols_hat;
                        count_Element = count_Element + 1;
                    end
                    break
                end
            end
        end
            
        if count_EOB == length_cells
            All_cells_hat{1,loop} = cells_hat;
            disp('Processing channel');
            break
        end
    end

end
