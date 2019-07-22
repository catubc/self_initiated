% Process Dataset
%% Load Dataset and Allen map
addpath(genpath('/home/cat/matlab_code/npy-matlab-master'));
load('/home/cat/matlab_code/shreya/latest_code/atlas.mat')

% baseline spontaneous
fdir='/media/cat/10TB/in_vivo/tim/yuki/IA2/tif_files/IA2pm_Feb3_30Hz/';
fname = strcat(fdir,'Vs.npy');
data = readNPY(fname);
data = permute(double(data),[2,3,1]);

size(data)
% if not filtered
% data = permute(data, [2,3,1]);
% data = (data-mean(data,3))./mean(data,3); % \Delta_F

%% Align data to Allen + get brainmask
tform = align_recording_to_allen(max(data,[],3)); % align <-- input any function of data here
invT=pinv(tform.T); % invert the transformation matrix
invT(1,3)=0; invT(2,3)=0; invT(3,3)=1; % set 3rd dimension of rotation artificially to 0
invtform=tform; invtform.T=invT; % create the transformation with invtform as the transformation matrix
maskwarp=imwarp(atlas,invtform,'interp','nearest','OutputView',imref2d(size(data(:,:,1)))); % setting the 'OutputView' is important
maskwarp=round(maskwarp);

%% Plot the inverse brainmask
figure; imagesc(maskwarp); axis image

atlas=maskwarp;
save(strcat(fdir,'warped_atlas.mat'),'atlas','areanames','invtform');