% Process Dataset
%% Load Dataset and Allen map
addpath(genpath('npy-matlab-master'));
load('/home/cat/code/notebooks/self_initiated/locaNMF/data/AllenMap/allenDorsalMap.mat');

fname = '/media/cat/10TB/in_vivo/tim/yuki/IA2/tif_files/IA2am_Mar9_30Hz/IA2am_Mar9_30Hz_aligned_Uc_500SVD_GPU.npy';
Uc = readNPY(fname);
Uc = permute(Uc, [2,3,1]);
Uc = double(Uc);
data=Uc-mean(Uc,3); % \Delta_F

%% Align data to Allen + get brainmask
tform = align_recording_to_allen(max(data,[],3)); % align <-- input any function of data here
invT=pinv(tform.T); % invert the transformation matrix
invT(1,3)=0; invT(2,3)=0; invT(3,3)=1; % set 3rd dimension of rotation artificially to 0
invtform=tform; invtform.T=invT; % create the transformation with invtform as the transformation matrix
maskwarp=imwarp(dorsalMaps.dorsalMapScaled,invtform,'OutputView',imref2d(size(data(:,:,1)))); % setting the 'OutputView' is important
maskwarp=round(maskwarp);

Uc=imwarp(Uc,tform,'OutputView',imref2d(size(dorsalMaps.dorsalMapScaled)));

%% Plot the inverse brainmask
figure; imagesc(maskwarp); axis image