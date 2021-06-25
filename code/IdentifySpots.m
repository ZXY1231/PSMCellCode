function imgxy = IdentifySpots(img, thresh, region)
% Extract locations from image
% | Version | Author | Date     | Commit
% | 0.1     | ZhouXY | 18.07.19 | The init version
% | 0.2     | H.F.   | 18.09.05 |
% | 1.0     | ZhouXY | 20.07.05 | Reconstruction
% | 2.0     | ZhouXY | 21.04.24 | firstly use centroid then 2DGaussian
% To Do: Binarize image with locally adaptive thresholding or only take
% threshold but keep graydrade
%We use function LocateSpotCentre_b1 here, which is outside the main file.
if nargin<3
    region = [12,12];
end

% Choose the threshold of image
img_thresh = imbinarize(img,thresh);

% img_thresh = RemoveBigArea(img_thresh,600);

% img_thresh = bwareaopen(img_thresh,3);

% Find connected components in binary image
CC = bwconncomp(img_thresh, 6); % should use 8 connected for 2d image

% Due to cellfun limit, size of img must be a cell form, all inout arguments must be cell form  
s = size(img_thresh);
SizeCell = cell(1,numel(CC.PixelIdxList));
SizeCell(1:end) = {s};

CenterTypeCell = cell(1,numel(CC.PixelIdxList));
CenterTypeCell(1:end) = {'Centroid'};

ImgCell = cell(1,numel(CC.PixelIdxList));
ImgCell(1:end) = {img};

% Find out the centroids
[imgy, imgx] = cellfun(@LocateSpotCentre_b3, CC.PixelIdxList, SizeCell, CenterTypeCell, ImgCell);

% % 2D gaussian 
% CenterTypeCell(1:end) = {'2DGaussian'};
% centroidxy = round(cat(2,imgx',imgy'));
% CentroidsCell = cell(1,numel(CC.PixelIdxList));
% for cc = 1:numel(CC.PixelIdxList)
%     CentroidsCell(cc) = {centroidxy(cc,:)};
% end
% 
% [imgy, imgx] = cellfun(@LocateSpotCentre_b3, CentroidsCell, SizeCell, CenterTypeCell, ImgCell);
% 
imgxy = cat(2,imgx',imgy');

end