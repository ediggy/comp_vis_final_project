% Clear environment
clear; clc; close all;

% Load the processed video
inputVideo = VideoReader('Videos\outputs\ball4_display_and_record_violations.mp4');

% Load the coordinates
coordinatesFile = 'Videos\outputs\ball4_detected_coordinates.csv';
coordinatesData = readmatrix(coordinatesFile);

% Set up the new output video
outputVideo = VideoWriter('Videos\outputs\ball4_accuracy_sbs.mp4', 'MPEG-4');
open(outputVideo);

% Violation line settings
violationLineRatio = 0.5;  % Same as detection
violationLineY = violationLineRatio * inputVideo.Height;

% Prepare figure
figure('Units', 'normalized', 'Position', [0.2 0.2 1.2 0.6]);

frameIdx = 1;

while hasFrame(inputVideo)
    % Read next frame
    videoFrame = readFrame(inputVideo);

    % Create subplot 1: show video frame
    subplot(1,2,1);
    imshow(videoFrame);
    hold on;
    title(sprintf('Video Frame %d', frameIdx));
    hold off;

    % Create subplot 2: show trajectory plot
    subplot(1,2,2);
    plot(coordinatesData(1:frameIdx,1), coordinatesData(1:frameIdx,2), 'g-o', 'MarkerFaceColor', 'g');
    hold on;
    set(gca, 'YDir','reverse');  % Match image coordinates
    yline(violationLineY, '--r', 'Violation Line', 'LineWidth', 2);
    xlim([0 inputVideo.Width]);
    ylim([0 inputVideo.Height]);
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    title('Bead Trajectory (up to current frame)');
    grid on;
    hold off;

    % Capture the current figure as a frame
    frame = getframe(gcf);
    writeVideo(outputVideo, frame.cdata);

    frameIdx = frameIdx + 1;

    % Safety check to avoid exceeding coordinates
    if frameIdx > size(coordinatesData, 1)
        break;
    end
end

% Close the video writer
close(outputVideo);
disp('Final overlay video created successfully!');