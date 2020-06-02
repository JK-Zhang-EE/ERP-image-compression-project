function bitstreams = my_encoding(All_cells,dict)


% This function is encoding with Huffman method

bitstreams = [];
for k = 1:length(All_cells)
    for i = 1:length(All_cells{1,k})
        
        % adjust 'EOB'
        if ischar(All_cells{1,k}{1,i})
            bitstreams = [bitstreams dict{length(dict),2}];              
        else
            bit_map1 = All_cells{1,k}{1,i}(1);
            bit_map2 = All_cells{1,k}{1,i}(2);
            for j=1:length(dict)
                if (bit_map1 == dict{j,1}(1)) && (bit_map2 == dict{j,1}(2))
                    bitstreams = [bitstreams dict{j,2}];
                end
            end            
            
        end
    end
end
