function success = Tester_StripAnalysis

% suppress warnings
origState = warning;
warning('off','all');

try
    %% read in sample video
    
    % for tester, we're using an aoslo video, because tslo or larger fov
    % videos usually need to be preprocessed to remve within-frame
    % nonhomogeneities so that cross-correlation will be robust. 

    % the video resides under /testing folder.
    inputVideo = 'aoslo.avi';

    str = which(inputVideo);
    if isempty(str)
        success = false;
        return;
    else
        [filepath,name,ext] = fileparts(str);
        inputVideo = [filepath filesep inputVideo];
    end
    
    
    %% First test
    
    % use default params
    p = struct; 
    p.overwrite = true;
    p.enableVerbosity = 1;
    p.minPeakThreshold = 0.4;
    p.adaptiveSearch = true;
    [position1, timeSec, rawPosition, peakValueArray, p] = ...
        StripAnalysis(inputVideo, p); %#ok<*ASGLU>
    delete(p.outputFilePath);
    
    fprintf('\nStripAnalysis: first test is successfully completed.\n')
    fprintf('Next test will start in 2 seconds...\n')
    pause(2);
    
    %% Second test
    
    % test with a video array
    videoArray = ReadVideoToArray(inputVideo);
    
    % use fft method
    p = struct; 
    p.overwrite = true;
    p.enableVerbosity = 1;
    p.minPeakThreshold = 0.4;
    p.adaptiveSearch = false;
    p.badFrames = false(32,1);
    p.badFrames([2 6]) = true;
    p.corrMethod = 'fft';
    [position2, timeSec, rawPosition, peakValueArray, p] = ...
        StripAnalysis(videoArray, p); %#ok<*ASGLU>
    
    success = true;
catch 
    success = false;
end

warning(origState);