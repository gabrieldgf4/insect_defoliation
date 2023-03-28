% load_images in a specific directory and a file extention
%
%   'folder' the directory path
%   'ext' the files extention
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)

% images = load_images('../PlantVillage-Dataset/raw/color/Soybean___healthy/', 'JPG');

function [images, fileName] = load_images(folder, ext)
 
imagefiles = dir(strcat(folder, '/*.', ext));
nfiles = length(imagefiles);    % Number of files found

for i=1:nfiles
   fileNameWithExtension = convertCharsToStrings(imagefiles(i).name);
   [~,f,~] = fileparts(fileNameWithExtension);
   fileName{i,1} = f;
   
   currentfilename = strcat(imagefiles(i).folder, ('/'), imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
end

end