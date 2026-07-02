clc; clear; close all;

% --- Step 1: Ask user to select a citrus leaf image ---
[filename, pathname] = uigetfile({'*.jpg;*.png;*.jpeg'}, 'Select a citrus leaf image');
if isequal(filename,0)
    disp('No file selected');
    return;
end

img = imread(fullfile(pathname, filename));
figure; imshow(img); title('Original Leaf Image');

% --- Step 2: Convert to HSV color space ---
hsvImg = rgb2hsv(img);
hue = hsvImg(:,:,1);
sat = hsvImg(:,:,2);
val = hsvImg(:,:,3);

% --- Step 3: Detect possible diseased areas ---
% Threshold for brown/spot areas typical in citrus leaf diseases
diseaseMask = (hue > 0.05 & hue < 0.15) & (sat > 0.2) & (val < 0.8);

% --- Step 4: Clean up mask ---
diseaseMask = bwareaopen(diseaseMask,50);         % Remove small noise
diseaseMask = imclose(diseaseMask, strel('disk',5)); % Fill small holes

% --- Step 5: Calculate diseased area percentage ---
diseaseArea = sum(diseaseMask(:));
totalArea = numel(diseaseMask);
percentDisease = (diseaseArea / totalArea) * 100;

% --- Step 6: Display detected diseased regions ---
figure; imshow(diseaseMask); title('Detected Diseased Regions');

% --- Step 7: Decide healthy or diseased ---
threshold = 5; % Adjust if needed
if percentDisease > threshold
    status = 'DISEASED';
else
    status = 'HEALTHY';
end

% --- Step 8: Show result ---
msgbox(sprintf('The leaf is %s\nDiseased area: %.2f%%', status, percentDisease), 'Result');
fprintf('The leaf is %s (%.2f%% diseased area)\n', status, percentDisease);