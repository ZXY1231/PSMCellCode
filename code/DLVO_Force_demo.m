KT = 4.11*10^(-21); %J
e = 1.6*10^(-19);%AS
r = 1*10^(-6);%m
eps = 80*8*10^(-12);%F/m
phi1 = -50*10^(-1);%V
phi2 = -25*10^(-3);%V
Debye = 20;
% phi = 64*pi*(KT/e)^2*r*eps*tanh(e*phi1/(4*KT))*tanh(e*phi2/(4*KT))*exp(-50/20)/KT;
phi = 64*pi*(KT/e)^2*r*eps*tanh(e*phi1/(4*KT))*tanh(e*phi2/(4*KT))/KT;
%%

DLVO_path=('');
z_path = ('');
result_path = ('');

%%
erg_images = LoadImages(DLVO_path, 'single');
z_images = LoadImages(z_path, 'single');

for frame0 = 1:size(erg_images,1)-1
    one_image_erg_diff = squeeze(erg_images(frame0+1,:,:))-squeeze(erg_images(frame0,:,:))+1e-6;
    one_image_z_diff = squeeze(z_images(frame0+1,:,:))-squeeze(z_images(frame0,:,:))+1e-6;
    one_image_force = abs(one_image_erg_diff./one_image_z_diff);
    saveastifffast(single(one_image_force/1000),append(result_path, num2str(frame0,'%06d'), 'force_nN.tif'));
end

%% solution 2
image_path = ('');
result_path2 = ('');
images = dir(append(image_path ,'*.tif'));
image_num = length(images);
shapes = size(imread(append(images(1).folder, '/' ,images(1).name)));
zero_intensity = ; %% avg+3*std

for frame0 = 1:size(images,1)
    img = single(imread(append(images(frame0).folder, '/' ,images(frame0).name)));
    one_image_force = (phi/Debye)*(img./zero_intensity).^(100/Debye); % intensity, Debye
    saveastifffast(single(one_image_force/1000),append(result_path2, num2str(frame0,'%06d'), 'force_nN.tif'));
end

