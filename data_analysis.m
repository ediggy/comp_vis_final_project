% Analysis script for bead detection and trajectory
clear; clc; close all;

% Parameters
violationLineRatio = 0.5;  % Same as in your main program (e.g., 60% of height)

% Load coordinates
coordinatesFile = 'Videos\outputs\ball1_detected_coordinates.csv';
violationFile = 'Videos\outputs\ball1_violation_record.csv';

% Load coordinates
coordinatesData = readmatrix(coordinatesFile);

% Load violation records
violationData = readcell(violationFile);

% Get number of detections
numDetections = size(coordinatesData, 1);

% Estimate total frames (assume no missing frames)
inputVideo = VideoReader('Videos\inputs\ball1.mp4');
totalFrames = floor(inputVideo.Duration * inputVideo.FrameRate);

% Detection percentage
detectionPercentage = (numDetections / totalFrames) * 100;

fprintf('Detection Success Rate: %.2f%% (%d detections / %d frames)\n', ...
    detectionPercentage, numDetections, totalFrames);

% Plot 1: Trajectory
figure;
plot(coordinatesData(:,1), coordinatesData(:,2), 'g-o', 'MarkerFaceColor', 'g');
hold on;
set(gca, 'YDir','reverse');  % Flip Y axis so it matches image coordinates

% Draw violation line
violationLineY = violationLineRatio * inputVideo.Height;
yline(violationLineY, '--r', 'Violation Line', 'LineWidth', 2);

xlabel('X Coordinate');
ylabel('Y Coordinate');
title('Bead Trajectory Over Time');
grid on;
legend('Bead Path', 'Violation Line', 'Location', 'best');
hold off;

% Plot 2: Violations over time
if ~isempty(violationData)
    % Extract times and event types
    times = [];
    events = {};
    for i = 2:size(violationData,1)  % Skip header if you have one
        times(end+1) = violationData{i,1};
        events{end+1} = violationData{i,4};  % Event type ('Violation' or 'Exit Violation')
    end

    figure;
    scatter(times, 1:length(times), 100, 'r', 'filled');
    xlabel('Time (s)');
    ylabel('Event #');
    title('Violation Events Over Time');
    grid on;
end

