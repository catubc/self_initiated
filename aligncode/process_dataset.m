% Process Dataset
%% Load Dataset and Allen map
addpath(genpath('npy-matlab'));
load('atlas.mat');

fdir = '../../IA2/';
fname = fullfile(fdir,'v.npy');
data = readNPY(fname);
if ndims(data)==2, data = reshape(data,128,128,size(data,2)); data = permute(data, [2,1,3]);
elseif ndims(data)==3, data = permute(data, [2,3,1]);
else, error('File has data with incorrect number of dimensions');
end

%% Align data to Allen
tform = align_recording_to_allen(data(:,:,1)); % align <-- input any function of data here

%% Calculate the inverse transform and warp the atlas
invT=pinv(tform.T); % invert the transformation matrix
invT(1,3)=0; invT(2,3)=0; invT(3,3)=1; % set 3rd dimension of rotation artificially to 0
invtform=tform; invtform.T=invT; % create the transformation with invtform as the transformation matrix
maskwarp=imwarp(atlas,invtform,'interp','nearest','OutputView',imref2d(size(data(:,:,1)))); % setting the 'OutputView' is important
maskwarp=round(maskwarp);

%% Plot the warped atlas
figure; imagesc(maskwarp); axis image

%% Save the warped atlas
atlas=maskwarp;
save(fullfile(fdir,'warped_atlas.mat'),'atlas','areanames','invtform');