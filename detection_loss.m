% Clear environment
clear; clc; close all;

% Load coordinate data
coordinatesFile = 'Videos\outputs\Ball3\ball3_detected_coordinates.csv';
coordinatesData = readmatrix(coordinatesFile);

% Load video to get number of frames
inputVideo = VideoReader('Videos\outputs\Ball3\ball3_display_and_record_violations.mp4');
totalFrames = floor(inputVideo.Duration * inputVideo.FrameRate);

% Create detection status vector
detectionStatus = zeros(totalFrames, 1);  % 0 = detected, 1 = not detected

% Assume coordinatesData has one row per frame where bead is detected
% We'll create a list of detected frames
detectedFrames = 1:size(coordinatesData, 1); % Frames where bead was detected

% Set detected frames to 0 (already default), missing frames to 1
allFrames = 1:totalFrames;
missingFrames = setdiff(allFrames, detectedFrames);

detectionStatus(missingFrames) = 1;  % Set missing frames to 1

% Plot the detection loss
figure;
stem(allFrames, detectionStatus, 'Marker', 'none', 'Color', 'red', 'LineWidth', 2);
xlabel('Frame Number');
ylabel('Detection Loss');
ylim([-0.1, 1.1]);
yticks([0 1]);
yticklabels({'Detected', 'Missing'});
title('Bead Detection Loss per Frame');
grid on;

% Save the figure
saveas(gcf, 'Videos\outputs\Ball3\ball3_detection_loss_plot.png');
disp('Detection loss plot saved!');
