% Reset the workspace
clear all; close all, clc;
folder = fileparts(which('C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\main'));   % Get current folder
addpath(genpath(folder));               % Add all subfolders to path

tic
% Define all the paths for input and output images,files etc.

% paths for inputs
fixed_image_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_iBHCT.nii';
moving_image_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_eBHCT.nii';

%Read images 
fixed_image = niftiread(fixed_image_path);
moving_image = niftiread(moving_image_path);

%Make copies of original images
fixed_image_n = fixed_image;
moving_image_n = moving_image;

%Set negative intensities to zero
fixed_image_n(fixed_image_n<0)=0;
moving_image_n(moving_image_n<0)=0;

%Apply gaussian denoising 
fixed_image_n = imgaussfilt3(fixed_image_n,1);
moving_image_n = imgaussfilt3(moving_image_n,1);

 %1) Set  the  initial  threshold  T=  (the  maximum  value of  the  image  brightness  + 
 %the  minimum  value  of  the image brightness)/2; 
[nrow, ncol, nslc] = size(fixed_image_n);
[nrow2, ncol2, nslc2] = size(moving_image_n);

fixed_image_reshaped = reshape(fixed_image_n,[],1);
moving_image_reshaped = reshape(moving_image_n,[],1);

Tmaxf=max(fixed_image_reshaped);
Tmaxm=max(moving_image_reshaped);

Tminf=min(fixed_image_reshaped);
Tminm=min(moving_image_reshaped);

%Initial threshold
Tf= (Tmaxf+Tminf)/2;
Tm= (Tmaxm+Tminm)/2;

%2) Using T segment the image to get two sets of pixels B (all the pixel values lesser than T) 
%and N (all the pixel values greater than T); 


for i=1:5
    %Creating copies of the original vectors
    fixed_image_reshaped_copy = fixed_image_reshaped;
    moving_image_reshaped_copy = moving_image_reshaped;
    fixed_image_reshaped_copy2 = fixed_image_reshaped;
    moving_image_reshaped_copy2 = moving_image_reshaped;
    %Segmenting fixed image
    indices_f_higher = find(fixed_image_reshaped >Tf);
    indices_f_lower= find(fixed_image_reshaped <Tf);
    fixed_image_reshaped_copy(indices_f_higher) = [];
    fixed_image_reshaped_copy2(indices_f_lower) = []; 
    %Segmenting moving image
    indices_m_higher = find(moving_image_reshaped >Tm);
    indices_m_lower= find(moving_image_reshaped <Tm);
    moving_image_reshaped_copy(indices_m_higher) = [];
    moving_image_reshaped_copy2(indices_m_lower) = [];
    % 3) Calculate the average value of B and N separately 
    Bf= mean(fixed_image_reshaped_copy);
    Nf= mean(fixed_image_reshaped_copy2);
    Bm= mean(moving_image_reshaped_copy);
    Nm= mean(moving_image_reshaped_copy2);
    % 4) Calculate the new threshold: T= (b+n)/2
    Tf= (Bf+ Nf)/2;
    Tm= (Bm+ Nm)/2;
    % Calculate new threshold
    Tfnew=Tf;
    Tmnew=Tm;
end

% Set binary values according to threshold
fixed_image_n(fixed_image_n>Tfnew)=0;
moving_image_n(moving_image_n>Tmnew)=0;

fixed_image_n(fixed_image_n>0)=1;
moving_image_n(moving_image_n>0)=1;

%Fill main holes
fixed_image_n = imfill(fixed_image_n, 'holes');
moving_image_n = imfill(moving_image_n, 'holes');

%Invert colors
fixed_image_n= ~fixed_image_n;
moving_image_n= ~moving_image_n;

%Positive pixels based holes, presenting volume lesser than 1000, are filled
rp = regionprops3(fixed_image_n, 'Volume', 'VoxelIdxList');
rpM = regionprops3(moving_image_n, 'Volume', 'VoxelIdxList');
indexesOfHoles = [rp.Volume]<1000;   
indexesOfHolesM = [rpM.Volume]<1000;   
voxelsToFill = rp.VoxelIdxList(indexesOfHoles); 
voxelsToFillM = rpM.VoxelIdxList(indexesOfHolesM); 
voxelsToFill=cell2mat(voxelsToFill);
voxelsToFillM=cell2mat(voxelsToFillM);

fixed_image_n(voxelsToFill)=0;
moving_image_n(voxelsToFillM)=0;

%Invert colors
fixed_image_n= ~fixed_image_n;
moving_image_n= ~moving_image_n;

%Fill positive pixels based background, corresponding to the biggest positive pixels volume in the mask.
rp = regionprops3(fixed_image_n, 'VoxelIdxList', 'ConvexVolume');
rpM = regionprops3(moving_image_n, 'VoxelIdxList','ConvexVolume');

maxA=max(rp.ConvexVolume);
maxB=max(rpM.ConvexVolume);
indexesOfHoles = [rp.ConvexVolume]==maxA;   
indexesOfHolesM = [rpM.ConvexVolume]==maxB;
voxelsToFill = rp.VoxelIdxList(indexesOfHoles); 
voxelsToFillM = rpM.VoxelIdxList(indexesOfHolesM); 
voxelsToFill=cell2mat(voxelsToFill);
voxelsToFillM=cell2mat(voxelsToFillM);

fixed_image_n(voxelsToFill)=0;
moving_image_n(voxelsToFillM)=0;

%Now the biggest positive pixels volume corresponds to the lungs. So, fill all the remaining positive pixel volumes
rp = regionprops3(fixed_image_n, 'VoxelIdxList', 'Volume');
rpM = regionprops3(moving_image_n, 'VoxelIdxList', 'Volume');

maxA=max(rp.Volume);
maxB=max(rpM.Volume);

indexesOfHoles = [rp.Volume]~=maxA;   
indexesOfHolesM = [rpM.Volume]~=maxB;
voxelsToFill = rp.VoxelIdxList(indexesOfHoles); 
voxelsToFillM = rpM.VoxelIdxList(indexesOfHolesM); 
voxelsToFill=cell2mat(voxelsToFill);
voxelsToFillM=cell2mat(voxelsToFillM);

fixed_image_n(voxelsToFill)=0;
moving_image_n(voxelsToFillM)=0;

%Write the new NiFTI mask, keeping the information contained in the header of the original image
hdr_original = niftiinfo(fixed_image_path);
hdr_mni = niftiinfo(moving_image_path);

% Write images
niftiwrite(int16(fixed_image_n), 'copd1_mask_iBHCT.nii', hdr_original);
movefile('copd1_mask_iBHCT.nii', 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1');
niftiwrite(int16(moving_image_n),'copd1_mask_eBHCT.nii',hdr_mni );
movefile('copd1_mask_eBHCT.nii', 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1');

toc;

