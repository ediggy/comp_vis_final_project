% Clear environment
clear; clc; close all;

% Load the processed video
inputVideo = VideoReader('Videos\outputs\ball1_display_and_record_violations.mp4');

% Load the coordinates
coordinatesFile = 'Videos\outputs\ball1_detected_coordinates.csv';
coordinatesData = readmatrix(coordinatesFile);

% Set up the new output video
outputVideo = VideoWriter('Videos\outputs\ball1_accuracy_overlay.mp4', 'MPEG-4');
open(outputVideo);

% Violation line settings
violationLineRatio = 0.5;  % Same as detection
violationLineY = violationLineRatio * inputVideo.Height;

frameIdx = 1;

while hasFrame(inputVideo)
    % Read next frame
    frame = readFrame(inputVideo);
    
    % Create an RGB frame if it's not already
    if size(frame, 3) ~= 3
        frame = repmat(frame, [1 1 3]);
    end

    % Get points up to current frame
    if frameIdx <= size(coordinatesData, 1)
        % Draw trajectory path
        for i = 2:frameIdx
            x1 = coordinatesData(i-1, 1);
            y1 = coordinatesData(i-1, 2);
            x2 = coordinatesData(i, 1);
            y2 = coordinatesData(i, 2);
            
            frame = insertShape(frame, 'Line', [x1, y1, x2, y2], 'Color', 'yellow', 'LineWidth', 3);
        end
        
        % Draw small circles at each point
        for i = 1:frameIdx
            x = coordinatesData(i, 1);
            y = coordinatesData(i, 2);
            frame = insertShape(frame, 'FilledCircle', [x, y, 5], 'Color', 'yellow');
        end
    end
    
    % Draw the violation line
    frame = insertShape(frame, 'Line', [0 violationLineY inputVideo.Width violationLineY], ...
        'Color', 'red', 'LineWidth', 5);
    
    % Write updated frame to output video
    writeVideo(outputVideo, frame);
    
    frameIdx = frameIdx + 1;
end

% Close the video writer
close(outputVideo);
disp('Overlay-on-video created successfully!');

