function SampleRunner
% SampleRunner
%  An example script of how to run the modules.
%
%  MTS 8/22/19 wrote the initial version

%% Example of running pipeline without writing result after each module.

% Ensure abortTriggered is false!
global abortTriggered
abortTriggered = false;

tic;
inputVideoPath = fullfile(pwd, 'demo/sample10deg.avi');
outputVideoPath = fullfile(pwd, 'demo/sampleRunnerResult.avi');

% Read the input video and pass the matrix into the functions to skip
% writing intermediate videos to file after each module.
reader = VideoReader(inputVideoPath);
numberOfFrames = reader.Framerate * reader.Duration;

% preallocate
video = zeros(reader.Height, reader.Width, numberOfFrames, 'uint8');

for frameNumber = 1:numberOfFrames
    video(1:end, 1:end, frameNumber) = readFrame(reader);
end


% Run desired modules.
% Also see example usages in the header comment of each module file.
parametersStructure = struct;
video = TrimVideo(video, parametersStructure);

stimulus = struct;
stimulus.size = 11;
stimulus.thickness = 1;
video = RemoveStimuli(video, stimulus, parametersStructure);

parametersStructure.isHistEq = false;
parametersStructure.isGammaCorrect = true;
video = GammaCorrect(video, parametersStructure);

video = BandpassFilter(video, parametersStructure);

refFrame = CoarseRef(video, parametersStructure);

[refFrame, ~, ~] = FineRef(refFrame, video, parametersStructure);

parametersStructure.adaptiveSearch = true;
parametersStructure.enableSubpixelInterpolation = true;
[~, eyeTraces, timeArray, ~] = StripAnalysis(video, refFrame, parametersStructure);

eyeTraces = FilterEyePosition([eyeTraces timeArray], parametersStructure);

eyeTraces = ReReference(eyeTraces, refFrame, 'demo/globalRef.tif', parametersStructure);

parametersStructure.isAdaptive = true;
[saccades, drifts] = FindSaccadesAndDrifts([eyeTraces timeArray], parametersStructure);


% Write the video when finished with desired modules.
writer = VideoWriter(outputVideoPath, 'Grayscale AVI');
% some videos are not 30fps, we need to keep the same framerate as
% the source video.
writer.FrameRate=reader.Framerate;
open(writer);
for frameNumber = 1:numberOfFrames
   writeVideo(writer, video(1:end, 1:end, frameNumber));
end

close(writer);
toc;

%% Example of running pipeline with result videos written between each module.

% Ensure abortTriggered is false!
global abortTriggered
abortTriggered = false;

tic;
inputVideoPath = fullfile(pwd, 'demo/sample10deg.avi');

% Run desired modules.
% Also see example usages in the header comment of each module file.
parametersStructure = struct;
parametersStructure.overwrite = true;
TrimVideo(inputVideoPath, parametersStructure);
inputVideoPath = Filename(inputVideoPath, 'trim');

stimulus = struct;
stimulus.size = 11;
stimulus.thickness = 1;
RemoveStimuli(inputVideoPath, stimulus, parametersStructure);
inputVideoPath = Filename(inputVideoPath, 'removestim');

parametersStructure.isHistEq = false;
parametersStructure.isGammaCorrect = true;
GammaCorrect(inputVideoPath, parametersStructure);
inputVideoPath = Filename(inputVideoPath, 'gamma');

BandpassFilter(inputVideoPath, parametersStructure);
inputVideoPath = Filename(inputVideoPath, 'bandpass');

CoarseRef(inputVideoPath, parametersStructure);
refFramePath = Filename(inputVideoPath, 'coarseref');

FineRef(refFramePath, inputVideoPath, parametersStructure);
refFramePath = Filename(inputVideoPath, 'fineref');

parametersStructure.adaptiveSearch = true;
parametersStructure.enableSubpixelInterpolation = true;
StripAnalysis(inputVideoPath, refFramePath, parametersStructure);
tracesPath = Filename(inputVideoPath, 'usefultraces');

FilterEyePosition(tracesPath, parametersStructure);
filteredPath = Filename(tracesPath, 'filtered');

ReReference(filteredPath, refFramePath, 'demo/globalRef.tif', parametersStructure);
rerefPath = Filename(filteredPath, 'reref');

parametersStructure.isAdaptive = true;
[saccades, drifts] = FindSaccadesAndDrifts(rerefPath, parametersStructure);


toc;

end