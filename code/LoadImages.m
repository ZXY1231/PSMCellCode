function all_images = LoadImages(source_path)
try
    source_path
    imges = dir(append(source_path ,'*.tif'));
    imge_num = length(imges);
    shapes = size(imread(append(imges(1).folder, '/' ,imges(1).name)));
    all_images = zeros(imge_num, shapes(1), shapes(2),'single');

    for i = 1:imge_num
        img = imread(append(imges(i).folder, '/' ,imges(i).name));
        all_images(i,:,:) = img;

    end
catch
    source_path
    info = imfinfo(source_path);
    num_images = numel(info);
    all_images = zeros(num_images, info(1).Height, info(1).Width);
    
    for k = 1:num_images
        img = imread(source_path, k);
        all_images(k,:,:) = img;
        % ... Do something with image A ...
    end
end
end