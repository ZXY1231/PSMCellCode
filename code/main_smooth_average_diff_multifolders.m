% clear all;
format long;
% Main function
% Matlab is pass-by-value.
% | Version | Author | Date     | Commit
% | 0.1     | ZhouXY | 20.02.12 | The init version
% | 0.2     | ZhouXY | 20.07.03 | Reconstruct the model for compatbility
% | 0.3     | ZhouXY | 20.07.09 | add gap filling
% | 1.0     | ZhouXY | 20.07.31 | Modify model structure, commit to github
% | 1.1     | ZhouXY | 21.03.03 | For PSM filtering
% | 1.2     | ZhouXY | 21.03.28 | For PSM statistics
% TODO: put the parameters outside function but main function
%test version is used for testing center fitting in time series
%% % Parameters
tic;
frames_path = 'D:\20210601\20210601\SLD_135mA_5nMIgM_0_5ms_10fold\IgM_files\';

result_path = ["D:\20210601\20210601\SLD_135mA_5nMIgM_0_5ms_10fold_smooth10avg_diff\" ,...
               "D:\20210530\20210530\L450_140mA_5nMIgA_5nMantiIgA_5ms_smooth10avg_diff_15_16min\" ,...
                ];

averageN = 10;
%%
all_images = LoadImages(frames_path);% size (#frames,h,w)

%%
tic
img_s = size(all_images);
leng = floor(img_s(1)/averageN)*averageN;

for i = 1:leng-2*averageN+1
    image_stack1 = all_images(i:i+averageN-1,:,:);
    image_stack2 = all_images(i+averageN:i+2*averageN-1,:,:);
    stack1_averageN = squeeze(mean(reshape(image_stack1,averageN,[],img_s(2),img_s(3)),1));
    stack2_averageN = squeeze(mean(reshape(image_stack2,averageN,[],img_s(2),img_s(3)),1));
    averageN_diff = single(stack2_averageN - stack1_averageN);
    
    folder_indx = ceil(i/1800000000);
    saveastifffast(averageN_diff, append(result_path(folder_indx), num2str(i,'%06d'), ".tif"));
end
toc





