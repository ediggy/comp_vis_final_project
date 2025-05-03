clear;
% Set up video reader and writer
inputVideo = VideoReader('Videos\inputs\ball1.mp4');  % Adjust with your input video filename
outputVideo = VideoWriter('Videos\outputs\Ball1\ball1_display_and_record_violations.mp4', 'MPEG-4');  % Output video filename

open(outputVideo);  % Open the video writer for writing
headers = {'X','Y'};
coordinates = [];

% Set the violation line to be at 50% of the video height (adjust as needed)
violationLineY = inputVideo.Height * 0.5;  % 50% of the height (you can change this percentage)

% Initialize flags and violation record
violationFlag = false;  % Flag to track if the bead has crossed the line
violationRecords = {};  % Store violation records

while hasFrame(inputVideo)
    % Read the next frame
    frame = readFrame(inputVideo);

    % Convert the frame to HSV color space
    hsvFrame = rgb2hsv(frame);

    % Extract the Hue channel
    hueChannel = hsvFrame(:,:,1);  % Hue is the first channel

    % Create a mask for green colors (adjust Hue range for green)
    greenMask = (hueChannel > 0.25) & (hueChannel < 0.45);  % Green hue range

    % Extract Saturation and Value channels
    saturation = hsvFrame(:,:,2);
    value = hsvFrame(:,:,3);

    % Combine conditions to focus on vibrant green areas (not too dark or grayish)
    greenMask = greenMask & (saturation > 0.3) & (value > 0.2);

    % Optionally, apply morphological operations to clean up the mask (remove small blobs)
    greenMask = imopen(greenMask, strel('disk', 5));  % Removes small noise blobs

    % Find circles in the green mask using imfindcircles
    [centers, radii] = imfindcircles(greenMask, [50 150], 'ObjectPolarity', 'bright', 'Sensitivity', 0.95);

    % Draw the violation line on the frame
    frame = insertShape(frame, 'Line', [0, violationLineY, inputVideo.Width, violationLineY], 'Color', 'red', 'LineWidth', 3);

    % If circles are found, annotate the frame with circles and coordinates
    if ~isempty(centers)
        for i = 1:size(centers, 1)
            x = round(centers(i, 1));  % X coordinate of the center
            y = round(centers(i, 2));  % Y coordinate of the center
            timestamp = inputVideo.CurrentTime;  % Get the current timestamp in seconds

            % Determine outline color based on the bead's position relative to the violation line
            if y < violationLineY  % Safe zone
                outlineColor = 'green';
            else  % Violation zone
                outlineColor = 'red';
            end

            % Draw the outline of the circle (bead) using insertShape
            frame = insertShape(frame, 'Circle', [x, y, radii(i)], 'Color', outlineColor, 'LineWidth', 5);

            % Check if the bead has crossed or is below the violation line
            if ~violationFlag && y > violationLineY
                violationFlag = true;
                % Record the violation in the violation record with the timestamp
                violationRecords = [violationRecords; {timestamp, x, y, 'Violation'}];
                % Change the text box color to red
                frame = insertText(frame, [x, y - radii(i) - 100], sprintf('(%d, %d)', x, y), ...
                    'TextColor', 'white', 'BoxColor', 'red', 'BoxOpacity', 0.7, 'FontSize', 64, 'AnchorPoint', 'Center');
            elseif violationFlag && y < violationLineY
                violationFlag = false;
                % Record the exit violation in the violation record
                violationRecords = [violationRecords; {timestamp, x, y, 'Exit violation'}];
                % Change the text box color back to green
                frame = insertText(frame, [x, y - radii(i) - 100], sprintf('(%d, %d)', x, y), ...
                    'TextColor', 'white', 'BoxColor', 'green', 'BoxOpacity', 0.7, 'FontSize', 64, 'AnchorPoint', 'Center');
            elseif violationFlag
                % If still in violation zone, keep the red text background
                frame = insertText(frame, [x, y - radii(i) - 100], sprintf('(%d, %d)', x, y), ...
                    'TextColor', 'white', 'BoxColor', 'red', 'BoxOpacity', 0.7, 'FontSize', 64, 'AnchorPoint', 'Center');
            else
                % Otherwise, keep the green text background
                frame = insertText(frame, [x, y - radii(i) - 100], sprintf('(%d, %d)', x, y), ...
                    'TextColor', 'white', 'BoxColor', 'green', 'BoxOpacity', 0.7, 'FontSize', 64, 'AnchorPoint', 'Center');
            end

            coordinates = [coordinates; centers];
        end
    end

    % Write the current processed frame to the output video
    writeVideo(outputVideo, frame);
end

% Close the video writer to finalize the video file
close(outputVideo);

% Write coordinates and violations to the CSV files
writecell(headers, 'Videos\outputs\Ball1\ball1_detected_coordinates.csv');
writematrix(coordinates, 'Videos\outputs\Ball1\ball1_detected_coordinates.csv', 'WriteMode', 'append');

% Write violation records to the violation CSV file
violationHeaders = {'Time', 'X', 'Y', 'Status'};
writecell(violationHeaders, 'Videos\outputs\Ball1\ball1_violation_record.csv');
writecell(violationRecords, 'Videos\outputs\Ball1\ball1_violation_record.csv', 'WriteMode', 'append');

disp('Done');
