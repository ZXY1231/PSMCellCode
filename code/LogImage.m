function img_log = LogImage(image,hsize,sigma)
%function LogImage: filter the image with the Laplacian of Gaussian filter.
%Input    image                : array, m1*m2
%         hsize                : filter size
%         sigma                : standard deviation
%Refer to matlab doc fspecial for the details.
%Output:  img_log              : array, m1*m2, filtered image
    img = double(squeeze(image));
    if nargin<2
        hsize = [12,12];
    end
    
    if nargin<3
        sigma = 4.0;
    end
    
    Log_filter = -fspecial('log', hsize, sigma); % fspecial creat predefined filter.Return a filter.
                                       
    img_log = imfilter(img, Log_filter, 'symmetric', 'conv');
 
end 