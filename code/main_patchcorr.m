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
% | 1.2     | ZhouXY | 21.04.21 | For PSM binding statistics, simplified
% | 1.2.1   | ZhouXY | 21.04.25 | For PSM drift detection
%% % Parameters
tic;
frames_path = "F:\20210322\Drift_test\44nm_1_1000\";
patch_path = "F:\20210322\Drift_test\000001.tif";

particle_name = 'Patch1';

%% generate PSF from selected a particle, then use the PSF as a filter
% psf_path = 'F:\20210322\IgM 0004955.tif';
% psf_threshold = 0.1;
% interp_f = 1;
% 
% psf_images = LoadImages(psf_path);% size (#frames,h,w)
% log_images = zeros(size(psf_images));
% psf_size = ones(8,8);
% 
% psf_bright_particles = cell(1,size( psf_images,1));
% 
% for i = 1:size(psf_images,1) 
%     log_img = LogImage(psf_images(i,:,:),[11,11],3);
%     log_images(i,:,:) = log_img;
%     
%     psf_bright_particles(i) = {IdentifySpots(log_img, psf_threshold)};
% end 
% 
% psf_tracks = TrackerInitializaon(psf_bright_particles{1},1);
% pattern = psf_tracks{1}.MyFastPattern(squeeze(psf_images(1,:,:)), psf_size);
% pattern_interp = interp2(pattern,interp_f);
% average_radial_profile = psf_tracks{1}.PSF2LineProfile(pattern_interp);
% psf2d = psf_tracks{1}.LineProfile2PSF(average_radial_profile);
% 
% % saveastiff(single(pattern), append('PSF_raw','.tif'));
% % saveastiff(single(psf2d), append('PSF_interp','.tif'));
% % saveastiff(single(psf2d), append('PSF_interp_extracted','.tif'));
% 
% figure(3)
% subplot(1,3,1)
% imshow(pattern,'DisplayRange',[0,6], 'InitialMagnification', 1600)
% subplot(1,3,2)
% imshow(pattern_interp,'DisplayRange',[0,6], 'InitialMagnification', 1600)
% subplot(1,3,3)
% imshow(psf2d,'DisplayRange',[0,8], 'InitialMagnification', 1600)
% 
% figure(4)
% plot(average_radial_profile)

%% load images and initialize filter operated images, detected particles
all_images = LoadImages(frames_path);% size (#frames,h,w)
Pt1 = LoadImages(patch_path);
Pt1 = squeeze(Pt1);
Pt1 = (Pt1-min(Pt1,[],'all'))/(max(Pt1,[],'all')-min(Pt1,[],'all'));


filtered_images = zeros(size(all_images));

% filtered_images = zeros(size(all_images,1),size(Pt1,1),size(Pt1,2));

global all_images_bright_particles
all_images_bright_particles = cell(1,size( all_images,1));

%% detection
img_filter = Pt1; % use psf2d as a filter

for i = 1:size(all_images,1)
    img = double(squeeze(all_images(i,:,:)));
    img = imfilter(img, img_filter, 'symmetric', 'corr');
    filtered_images(i,:,:) = img;
    
%     all_images_bright_particles(i) = {IdentifySpots(img, high_threshold)};
end
Z = single(permute(filtered_images, [2 3 1]));
saveastiff(Z(:,:,:), append('Drift4_',particle_name,'.tif'));


toc