clc
clear
close all

% Author: Simon Graham
% Tissue Image Analytics Lab
% Department of Computer Science, 
% University of Warwick, UK.
%-------------------------------------------------------------------

% Path 
probmap_path = '/probmap_path/';
image_ext = 'png';
list_images = dir([probmap_path,'*',image_ext]);
out_dir = '/out_dir/';
%-------------------------------------------------------------------

% Post processing options
threshold = 0.9; % set all pixels above 'threshold' to 1; otherwise to 0
morph_open = 'yes'; 
morph_close = 'yes';
remove_small_objects = 'yes';
erode = 'yes';
dilate = 'yes';

% structuring elements for post processing. Other options include 'diamond'
% and 'square'
str_open = strel('disk', 10); 
str_close = strel('disk', 10);
str_erode = strel('disk', 10);
str_dilate = strel('disk', 10);

% removes all connected components with fewer than 'smallobj_number'
smallobj_number = 10;

%-------------------------------------------------------------------

for i = 1:length(list_images)
    image_name = list_images(i).name
    image_file = [probmap_path, image_name];
    image = imread(image_file);
    image = im2bw(image, threshold);
    if morph_open == 'yes'
        image = imopen(image, str_open);
    end
    
    if morph_close == 'yes'
        image = imclose(image, str_close);
    end
    
    if remove_small_objects == 'yes'
        image = bwareaopen(image, smallobj_number);
    end
    
    if erode == 'yes'
        image = imerode(image, str_erode);
    end
    
    if dilate == 'yes'
        image = imdilate(image, str_dilate);
    end
    
    imwrite(image, [out_dir, list_images(i).name]);
end
