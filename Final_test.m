clear all;

file_path =  '.\test_data\';% 影象資料夾路徑
img_path_list = dir(strcat(file_path,'*.jpg'));%獲取該資料夾中所有jpg格式的影象
img_num = length(img_path_list);%獲取影象總數量
        
All_bpp = [];
All_wpsnr = [];
All_psnr = [];
All_encoding_time = [];

if img_num > 0 %有滿足條件的影象
    for j = 1:img_num %逐一讀取影象
        image_name = img_path_list(j).name;% 影象名
        X = imread([file_path image_name]);
        X_float = double(X);
        [m,n,channel] = size(X_float);


        % JEPG
        [jpeg_bitstreams,jpeg_encoding_time,wpsnr_jpeg,jpeg_X_hat] = jpeg_encoding(X_float);
        bpp_jpeg = length(jpeg_bitstreams)*8/(m*n);
        mse_jpeg = mean(mean(mean((X_float-jpeg_X_hat).^2)));
        psnr_jpeg = 10*log10(255.^2/mean(mse_jpeg));
        disp('JPEG Processing');

        % YCbCr
        [YCbCr_bitstreams,YCbCr_encoding_time,wpsnr_YCbCr,YCbCr_X_hat] = YCBCR_encoder(X_float);
        bpp_ycbcr = length(YCbCr_bitstreams)*8/(m*n);
        mse_ycbcr = mean(mean(mean((X_float-YCbCr_X_hat).^2)));
        psnr_ycbcr = 10*log10(255.^2/mean(mse_ycbcr));
        disp('YCbCr Processing');
        
        

        % YCbCr + QP Adaptive
        QP = 0.4;
        [my_bitstreams,my_encoding_time,wpsnr_my,my_X_hat] = MY_encoder(X_float,QP);
        bpp_my = length(my_bitstreams)*8/(m*n);
        mse_my = mean(mean(mean((X_float-my_X_hat).^2)));
        psnr_my = 10*log10(255.^2/mean(mse_my));
        disp('Ending');

        %{
        bpp_All = [];
        my_encode_times = [];
        psnr_All = [];
        ratio_All = [];
        for i=0.1:0.1:1
            QP = i;
            [my_bitstreams,my_encoding_time,psnr_my,my_X_hat] = MY_encoder(X_float,QP);
            bpp_my = length(my_bitstreams)*8/(m*n);
            my_encode_times = [my_encode_times my_encoding_time]; 
            bpp_All = [bpp_All bpp_my];
            psnr_All = [psnr_All psnr_my];
            ratio = psnr_my/bpp_my;
            ratio_All = [ratio_All ratio];
            disp(['YCbCr + QP Adaptive Processing, QP:' num2str(QP)]);
        end
        %}
    
        
        
        All_bpp = [All_bpp bpp_jpeg bpp_ycbcr bpp_my];
        All_wpsnr = [All_wpsnr wpsnr_jpeg wpsnr_YCbCr wpsnr_my];
        All_psnr = [All_psnr psnr_jpeg psnr_ycbcr psnr_my];
        All_encoding_time = [All_encoding_time jpeg_encoding_time YCbCr_encoding_time my_encoding_time];
        
        
        %figure;
        figure('Position',[0 0 1680 932])
        subplot(2,2,1);
        imshow(uint8(X_float))
        title('Test ERP Image')

        subplot(2,2,2);
        imshow(uint8(jpeg_X_hat))
        xlabel(['BPP :', num2str(bpp_jpeg) ,' ,WS-PSNR :',num2str(wpsnr_jpeg),' ,PSNR :',num2str(psnr_jpeg), ' ,Coding time: ',num2str(jpeg_encoding_time), ' s'])
        title('JPEG Method')
        
        subplot(2,2,3);
        imshow(uint8(YCbCr_X_hat))
        xlabel(['BPP :', num2str(bpp_ycbcr) ,' ,WS-PSNR :',num2str(wpsnr_YCbCr),' ,PSNR :',num2str(psnr_ycbcr), ' ,Coding time: ',num2str(YCbCr_encoding_time), ' s'])
        title('YCbCr Method')

        subplot(2,2,4);
        imshow(uint8(YCbCr_X_hat))
        xlabel(['BPP :', num2str(bpp_my) ,' ,WS-PSNR :',num2str(wpsnr_my),' ,PSNR :',num2str(psnr_my), ' ,Coding time: ',num2str(my_encoding_time), ' s'])
        title(['YCbCr + QP Equator bias Method, QP: ' num2str(QP)])

        
        saveas(gcf, ['./test_result1/result_' image_name])

        
    end
end


% Calculate the result
result_bpp1 = [];
result_wp1 = [];
result_p1 = [];
result_t1 = [];

result_bpp2 = [];
result_wp2 = [];
result_p2 = [];
result_t2 = [];

for i = 1:10
    bpps = [];
    wspsnrs = [];
    psnrs = [];
    t1s = [];
    bpps = [All_bpp(3*i-2) All_bpp(3*i-1) All_bpp(3*i)];
    wspsnrs = [All_wpsnr(3*i-2) All_wpsnr(3*i-1) All_wpsnr(3*i)];
    psnrs = [All_psnr(3*i-2) All_psnr(3*i-1) All_psnr(3*i)];
    t1s = [All_encoding_time(3*i-2) All_encoding_time(3*i-1) All_encoding_time(3*i)];

    d_bpp1 = (bpps(2) - bpps(1))/bpps(1);
    d_bpp2 = (bpps(3) - bpps(1))/bpps(1);

    d_wpsnr1 = (wspsnrs(2) - wspsnrs(1))/wspsnrs(1);
    d_wpsnr2 = (wspsnrs(3) - wspsnrs(1))/wspsnrs(1); 
    
    d_psnr1 = (psnrs(2) - psnrs(1))/psnrs(1);
    d_psnr2 = (psnrs(3) - psnrs(1))/psnrs(1); 

    d_t1 = (t1s(2) - t1s(1))/t1s(1);
    d_t2 = (t1s(3) - t1s(1))/t1s(1);     
    
    result_bpp1 = [result_bpp1 d_bpp1];
    result_wp1 = [result_wp1 d_wpsnr1];
    result_p1 = [result_p1 d_psnr1];
    result_t1 = [result_t1 d_t1];

    result_bpp2 = [result_bpp2 d_bpp2];
    result_wp2 = [result_wp2 d_wpsnr2];
    result_p2 = [result_p2 d_psnr2];
    result_t2 = [result_t2 d_t2];
end




