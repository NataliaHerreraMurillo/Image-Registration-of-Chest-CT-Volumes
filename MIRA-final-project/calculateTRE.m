function [tre_mean,tre_std] = calculateTRE(target_points, registered_points, points_type, voxel_spacing)
% This function is calculating the TRE (target registration error) between
% target and registered points that are landmarks on CT 3D images.
%
% tre_ean = variable contains the mean TRE between two sets of input points
% tre_std = variable contains the standard deviation of TRE
% target_points = target landmark points
% registered_points = registered landmark points
% type = original points or registered points
%**************************************************************************
if (strcmp(points_type, 'registered'))
    CStr = registered_points;
    key = 'OutputIndexFixed';
    % CStr  = strsplit(registered_points);
    Match = strncmp(CStr{1}, key, length(key));
    strc  = (CStr{1}(Match));
    sl = strlength(strc{1});
    strb1 = (str2num((strc{1}(22:(sl-2)))))';
    
    for i = 2:length(strc)
        sl = strlength(strc{i});
        strb = (str2num((strc{i}(22:(sl-2)))));
        strb1 = vertcat(strb1,strb');
    end
    registered_points = strb1;
end



voxel_mm = voxel_spacing;
dim_points = size(target_points,2);
num_points = size(target_points,1)/3;
voxel_mm = repmat(voxel_mm,[num_points, dim_points]);

target_points_mm = target_points.*voxel_mm;
registered_points_mm = registered_points.*voxel_mm;

target_points_mm = reshape(target_points_mm',[dim_points*3,num_points]);
registered_points_mm = reshape(registered_points_mm',[dim_points*3,num_points]);


for i = 1:num_points
    tre(i) = sqrt(sum((target_points_mm(:,i)-registered_points_mm(:,i)).^2));
end
tre_mean = mean(tre);
tre_std = std(tre);
end