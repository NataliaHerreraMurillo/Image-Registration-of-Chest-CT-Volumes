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

%Create copies of the original images
fixed_image_n = fixed_image;
moving_image_n = moving_image;

%Set negative intensities to zero
fixed_image_n(fixed_image_n<0)=0;
moving_image_n(moving_image_n<0)=0;

% fixed_image_n= imadjustn(fixed_image_n);
% moving_image_n= imadjustn(moving_image_n);

%Save header information of original images
hdr_fixed = niftiinfo(fixed_image_path);
hdr_moving = niftiinfo(moving_image_path);

%Write images
niftiwrite(int16(fixed_image_n), 'copd1_m_iBHCT.nii', hdr_fixed);
movefile('copd1_m_iBHCT.nii', 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1');
niftiwrite(int16(moving_image_n),'copd1_m_eBHCT.nii',hdr_moving );
movefile('copd1_m_eBHCT.nii', 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1');

toc;
