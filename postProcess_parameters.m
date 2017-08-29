clc
clear
close all

% Author: Simon Graham
% Tissue Image Analytics Lab
% Department of Computer Science, 
% University of Warwick, UK.
%-------------------------------------------------------------------

% Path 
probmap_path = '/Volumes/TIALab_1/TUPAC/Pretrained_results/Results/';
image_ext = 'mat';
list_images = dir([probmap_path,'TUPAC*']);
groundtruth_path = '/Volumes/Simon_Drive/ground_truth1/';

%-------------------------------------------------------------------
image_name_list = {'TUPAC-TR-351','TUPAC-TR-353','TUPAC-TR-354','TUPAC-TR-360','TUPAC-TR-369','TUPAC-TR-375','TUPAC-TR-377','TUPAC-TR-382','TUPAC-TR-390','TUPAC-TR-392','TUPAC-TR-393'};
threshold_list = {0.6,0.8,0.85,0.9};
str_open_list = {50};
str_close_list = {100};


for p = 1:length(threshold_list)
    threshold = threshold_list(p);
    for q = 1:length(str_open_list)
        str_open = str_open_list(q);
        for r = 1:length(str_close_list)
            str_close = str_close_list(r);
            tp = 0;
            fp = 0;
            fn = 0;
            for i = 1:length(image_name_list)
                image_name = image_name_list(i);
                %disp( sprintf( 'Processing Image: %s', image_name{1}));
                image_file = [probmap_path, image_name{1}, '/', image_name{1} ,'.', image_ext];
                load(image_file);
                image = result;
                image = image*2.55;
      
                image = im2bw(image, threshold{1});
                image = imopen(image, strel('disk', str_open{1}));
                image = imclose(image, strel('disk', str_close{1}));
                %image = imresize(image,0.5);

                gt_path = [groundtruth_path,image_name{1},'.png'];
                gt = imread(gt_path);
                image = imresize(image, [size(gt,1) size(gt,2)]);

                [tp_,fp_,fn_] = find_tp_fp_fn(image,gt);
                tp = tp_ + tp;
                fp = fp_ + fp;
                fn = fn_ + fn;
            end
            [F1_score,Pr,Re] =  Calculate_F1Score(tp, fp, fn);
            formatSpec = 'F1 Score: %d, threshold: %d, open: %d, close: %d';
            A = F1_score;
            B = threshold{1};
            C = str_open{1};
            D = str_close{1};
            str = sprintf(formatSpec,A,B,C,D)
        end
    end
end

