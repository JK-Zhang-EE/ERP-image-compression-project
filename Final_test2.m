clear all;

image_name = 'test2.jpg';
X = imread(image_name);
X_float = double(X);
[m,n,channel] = size(X_float);


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




