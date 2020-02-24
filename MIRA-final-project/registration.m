% Reset the workspace
clear all; close all, clc;
folder = fileparts(which('C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\main'));   % Get current folder
addpath(genpath(folder));               % Add all subfolders to path

tic
% Define all the paths for input and output images,files etc.

% paths for inputs
fixed_points_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_300_iBH_xyz_r1.txt';
moving_points_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_300_eBH_xyz_r1.txt';

% paths for new inputs
fixed_image_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_m_iBHCT.nii';
moving_image_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_m_eBHCT.nii'; 
fixed_image_path_mask = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_mask_iBHCT.nii';
moving_image_path_mask = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\copd1\copd1_mask_eBHCT.nii'; 

% paths for outputs
elastix_out = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\elastix-output';
elastix_out2 = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\elastix-output2';
elastix_out3 = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\elastix-output3';
transformix_out = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\transformix-output';
registered_points_path = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\transformix-output\outputpoints.txt';

% path for input parameters files
param = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\parameters-files';

% Get all files in train images, labels and parameter folders
param_names = dir(strcat(param,'\*.txt'));
para1 = param_names(1).name;
para2 = param_names(2).name;
para3 = param_names(3).name;

% Make paths for input parameters files
para1_path = strcat(param,'\',para1);
para2_path = strcat(param,'\',para2);
para3_path = strcat(param,'\',para3);

% Make and run the command for elastix
cmd = strcat('elastix -f'," ",fixed_image_path," ",'-m '," ",moving_image_path...
    ," ",'-out'," ",elastix_out," ",'-p'," ", para1_path);
system(cmd);
elastix_out_p0 = 'C:\Users\natal\OneDrive\Escritorio\MIRA-final-project\elastix-output\TransformParameters.0.txt';

cmd = strcat('elastix -f'," ",fixed_image_path," ",'-m '," ",moving_image_path...
    ," ",'-out'," ",elastix_out2," ",'-p'," ", para2_path," ",'-t0'," ", elastix_out_p0);
system(cmd);

cmd = strcat('elastix -f'," ",fixed_image_path," ",'-m '," ",moving_image_path...
    ," ",'-out'," ",elastix_out3," ",'-p'," ", para3_path," ",'-t0'," ", elastix_out_p0," ",...
    "-fMask"," ", fixed_image_path_mask, " ","-mMask"," ", moving_image_path_mask);
system(cmd);

% Get the paths for transform parameters files
transform_param_names = dir(strcat(elastix_out3,'\','*TransformParameters*'));

transform_Param_path = strcat(elastix_out3,'\',transform_param_names(1).name);

% Change the transform parameter files (output parameters of elastix)
% for better results from transformix function.
old_string = 'FinalBSplineInterpolationOrder 3';
replace_with_string = 'FinalBSplineInterpolationOrder 0';
ChangeParametersInElastixTransformFile(transform_Param_path, old_string, replace_with_string)

% Now make and run command for transformix
cmd = strcat('transformix -def'," ",fixed_points_path," ",'-out '," ",transformix_out," ",'-tp'," ", transform_Param_path);
system(cmd);

points = fopen(moving_points_path);
copd1_300_eBH_xyz = fscanf(points,'%f');
fclose(points);

points = fopen(registered_points_path);
copd1_300_iBH_xyz = textscan(points,'%s','Delimiter',';');
fclose(points);
points_type = 'registered'; % registered or original

% inputs to the TRE calculation function
voxel_spacing = [0.625; 0.625; 2.5];
target_points = copd1_300_eBH_xyz; 
registered_points = copd1_300_iBH_xyz;

% call TRE calculation function here
[tre_mean,tre_std] = calculateTRE(target_points, registered_points, points_type, voxel_spacing);
toc;












