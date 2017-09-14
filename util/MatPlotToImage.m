function MatPlotToImage()
%MAT PLOT TO IMAGE Generates image files from plot mat files
%   Generates image files from eye position traces plot mat files. 
%   We assume the user will select final mat files, which contain the 
%   the data called timeArray and eyePositionTraces. This script takes
%   that data, plots it, and re-saves as a jpg with the same name in the
%   same directory. This is useful for generating images for reporting
%   purposes.

%% Pixels to degrees constants

% choose from the three video classification options below
VIDEO_CLASSIFICATION = 2;

% video classification 1
aosloFieldSize = 0.83;
aosloNumPixels = 512;

% video classification 2
tsloFieldSize = 10;
tsloNumPixels = 512;

% video classification 3
rodenstockFieldSize = 40;
rodenstockNumPixels = 664;
% 40 degrees horizontally, pixels are square shaped

if VIDEO_CLASSIFICATION == 1
    degreesPerPixel = aosloFieldSize/aosloNumPixels;
elseif VIDEO_CLASSIFICATION == 2
    degreesPerPixel = tsloFieldSize/tsloNumPixels;
else
    degreesPerPixel = rodenstockFieldSize/rodenstockNumPixels;
end

%% Render and save images
addpath(genpath('..'));

filenames = uipickfiles;
if ~iscell(filenames)
    if filenames == 0
        fprintf('User cancelled file selection. Silently exiting...\n');
        return;
    end
end

for i = 1:length(filenames)
    % Grab path out of cell.
    matFilePath = filenames{i};
    originalNameEnd = strfind(matFilePath, '_dwt');
    jpgFilePath = matFilePath(1:originalNameEnd-1);
    
    load(matFilePath);
    
    % Convert from pixels to degrees
    eyePositionTraces = eyePositionTraces * degreesPerPixel;

    plot(timeArray, eyePositionTraces)
    title('Raw Eye Position Traces');
    xlabel('Time (sec)');
    ylabel('Eye Position Traces (degrees)');
    legend('show');
    legend('Horizontal Traces', 'Vertical Traces');
    saveas(gcf, jpgFilePath, 'jpg')
end

close all;
fprintf('Process Completed.\n');

end
