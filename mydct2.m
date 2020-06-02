function A = mydct2(matrix_size)


%This function calculates dct2

N = matrix_size;
% Build cos matrix
u_num = N - 1;

cos_box = zeros(N,N);
for u=0:u_num
        cos_var = [];
        if u == 0
            for x=0:N-1
                cos_var(x+1)=sqrt(1/N)*cos((2*x+1)*u*pi/(2*N));
            end
        else
            for x=0:N-1
                cos_var(x+1)=sqrt(2/N)*cos((2*x+1)*u*pi/(2*N));
            end
        end
        cos_box(u+1,:) = cos_var;
end

B = cos_box';
A=B';