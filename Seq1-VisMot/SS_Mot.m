%% experience eye tracking and auditory motion

clc;
clear;

SkipSyncTest = 1 ; % 1 will skip sync tests for mac issues
% but should be set to 0 afterwards and during testing

debug = true,
more off

% % if you would like to test on a part of the screen, change to 1;
% TestingSmallScreen = 1;
device = 'F'

debug

% Open Parallel port if EEG
if strcmp(device,'EEG')
    openparallelport_inpout32(hex2dec('d010'))
end

%% Setting
Cfg.experimentType = 'Dots';   % Visual modality is in RDKs
Cfg.possibleModalities = {'visual'}; % nombre de possibilites

Cfg.numEventsPerCondition = 1; % Since its an event design, every block will have 1 event.
Cfg.speedEvent = 6; % event speed
Cfg.numRepetitions = 60; % number of event per condition
Cfg.BaseFreq = 2;
onsetDelay = 2; % number of seconds before the motion stimuli are presented
endDelay = 2; % number of seconds after the end all the stimuli before ending the run


%% Parameters for monitor setting
monitor_width  	  = 42;                            % Monitor Width in cm
screen_distance   = 134;                           % Distance from the screen in cm
diameter_aperture = 8;                             % diameter/length of side of aperture in Visual angles


%% Dots param
Cfg.coh = 1;                                      % Coherence Level (0-1)
Cfg.maxDotsPerFrame = 300;                        % Maximum number dots per frame (Number must be divisible by 3)
Cfg.dotLifeTime = 0.2;                            % Dot life time in seconds
Cfg.dontclear = 0;
Cfg.dotSize = 0.1;

% manual displacement of the fixation cross
xDisplacementFixCross = 0 ;
yDisplacementFixCross = 0 ;

% Check that the number is divisible by 3
if mod(Cfg.maxDotsPerFrame,3) ~= 0
    error('Number of dots should be divisible by 3.')
end


%% Fixation Cross parameters
% Used Pixels here since it really small and can be adjusted during the experiment
Cfg.fixCrossDimPix = 10;   % Set the length of the lines (in Pixels) of the fixation cross
Cfg.lineWidthPix = 4;      % Set the line width (in Pixels) for our fixation cross


%% Color Parameters
White = [255 255 255]; 
Black = [ 0   0   0 ]; 
Grey  = mean([Black;White]);

Cfg.textColor           = White ; 
Cfg.Background_color    = Black ; 
Cfg.fixationCross_color = White ; 
Cfg.dotColor            = White ; 


%%  Get Subject Name and run number
subjectName = input('Enter Subject Name: ','s');
if isempty(subjectName)
    subjectName = 'trial';
end

runNumber = input('Enter the run Number: ','s');
if isempty(runNumber)
    runNumber = 'trial';
end


% Check if logfile already exists
% if exist(fullfile('logfiles',[subjectName,'_run_',num2str(runNumber),'.mat']),'file')>0
%     error('This file is already present in your logfiles. Delete the old file or rename your run!!')
% end

HideCursor;

%%  Experiment
AssertOpenGL;

if debug
    PsychDebugWindowConfiguration
end

% Select screen with maximum id for output window:
screenid = max(Screen('Screens'));
PsychImaging('PrepareConfiguration');
Screen('Preference','SkipSyncTests', SkipSyncTest);
[Cfg.win, Cfg.winRect] = PsychImaging('OpenWindow', screenid, Cfg.Background_color);


%%  Get the Center of the Screen
Cfg.center = [Cfg.winRect(3), Cfg.winRect(4)]/2;


%% Fixation Cross
xCoords = [-Cfg.fixCrossDimPix Cfg.fixCrossDimPix 0 0] + xDisplacementFixCross;
yCoords = [0 0 -Cfg.fixCrossDimPix Cfg.fixCrossDimPix] + yDisplacementFixCross;
Cfg.allCoords = [xCoords; yCoords];


%% Screen details
% Query frame duration
WaitSecs(1);
Cfg.ifi = Screen('GetFlipInterval', Cfg.win);
Cfg.monRefresh =  1/Cfg.ifi;

% monitor distance
Cfg.mon_horizontal_cm  	= monitor_width;                         % Width of the monitor in cm
Cfg.view_dist_cm 		= screen_distance;                       % Distance from viewing screen in cm
Cfg.apD = diameter_aperture;                                     % diameter/length of side of aperture in Visual angles

% % Everything is initially in coordinates of visual degrees, convert to pixels
% (pix/screen) * (screen/rad) * rad/deg
V = 2* (180 * (atan(Cfg.mon_horizontal_cm/(2*Cfg.view_dist_cm)) / pi));
Cfg.ppd = Cfg.winRect(3) / V ;

Cfg.d_ppd = floor(Cfg.apD * Cfg.ppd);                  % Covert the aperture diameter to pixels
Cfg.dotSize = floor (Cfg.ppd * Cfg.dotSize);           % Covert the dot Size to pixels

%%
% Enable alpha-blending, set it to a blend equation useable for linear superposition with 
% alpha-weighted source.
Screen('BlendFunction', Cfg.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initially sync us to VBL at start of animation loop.
Screen('Flip', Cfg.win);

% Select specific text font, style and size:
Screen('TextFont',Cfg.win, 'Courier New');
Screen('TextSize',Cfg.win, 18);
Screen('TextStyle', Cfg.win, 1);

fprintf('\n\n')


%% Experimental Design
[directions, speeds, modalities, EventDuration] = SS_Mot_ExpDesign(Cfg);
numEvents = length(directions);


%% Blank Trials  (for RDKs first mock trials)
Cfg.Experiment_start = GetSecs;
DoDotMo_blanks(Cfg, 0, Cfg.speedEvent , 1 );
Screen('Flip', Cfg.win, 0, Cfg.dontclear);
fprintf('Blank 1 finished \n');
DoDotMo_blanks( Cfg, 180, Cfg.speedEvent , 1 );
Screen('Flip', Cfg.win, 0, Cfg.dontclear);
fprintf('Blank 2 finished \n');
DoDotMo_blanks( Cfg, -1, Cfg.speedEvent , 1 );
Screen('Flip', Cfg.win, 0, Cfg.dontclear);
fprintf('Blank 3 finished \n');
WaitSecs(0.2);
Cfg.Experiment_start = [];


%% Empty vectors and matrices for speed
eventNames     = cell(numEvents,1);
eventOnsets    = zeros(numEvents,1);
eventEnds      = zeros(numEvents,1);
eventDurations = zeros(numEvents,1);

allResponses = [] ;


%% Fixation cross
Screen('DrawLines', Cfg.win, Cfg.allCoords, Cfg.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
Screen('Flip',Cfg.win);


%% txt logfiles
if ~exist('logfiles','dir')
    mkdir('logfiles')
end

EventTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_run_',num2str((runNumber)),'_Events.txt']),'w');
fprintf(EventTxtLogFile,'%12s %12s %12s %18s %12s %12s %12s \n',...
    'EventNumber','Modality','Direction','Speed','Onset','End','Duration');

ResponsesTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_run_',num2str((runNumber)),'_Responses.txt']),'w');
fprintf(ResponsesTxtLogFile,'%12s \n','Responses');

%% Experiment Start
Cfg.Experiment_start = GetSecs;
WaitSecs(onsetDelay);

% For each event
for iEvent = 1:numEvents
    
    iEventDirection = directions(iEvent,1);    % Direction of that event
    iEventSpeed = speeds(iEvent,1);            % Speed of that event
    iEventDuration = EventDuration ;           % Duration of events
    
    % Event Onset
    eventOnsets(iEvent,1) = GetSecs-Cfg.Experiment_start;
    
    %% RUN DO DOTS
    if strcmp(device,'EEG') && iEvent == 1
        b = 200;
        sendparallelbyte(b);
    end
    responseTimeWithinEvent = DoDotMo( Cfg, iEventDirection, iEventSpeed, iEventDuration );
    
    %% Event End and Duration
    eventEnds(iEvent,1) = GetSecs-Cfg.Experiment_start;
    eventDurations(iEvent,1) = eventEnds(iEvent,1) - eventOnsets(iEvent,1);
    
    %% Event txt_Logfile
    fprintf(EventTxtLogFile,'%12.0f %12s %12.0f %12.2f %12.5f %12.5f %12.5f \n',...
        iEvent,modalities{iEvent},iEventDirection,iEventSpeed,eventOnsets(iEvent,1),eventEnds(iEvent,1),eventDurations(iEvent,1));
    
    % wait for the inter-stimulus interval
    %WaitSecs(Cfg.interstimulus_interval);
    
end

if strcmp(device,'EEG')
    sendparallelbyte(0);
    b = 100;
    sendparallelbyte(b);
    sendparallelbyte(0);
end

% Assign the targets onsets (higher speed and change in fixation and sort
% them) to one variable to used later for behavioral assessment
%la fonction sort signifie tri ascendant
%targetOnsets = sort([eventOnsets(IsFixationTarget==1)]);

% End of the run for the BOLD to go down
Screen('Flip', Cfg.win);
WaitSecs(endDelay);

% close txt log files
fclose(EventTxtLogFile);
fclose(ResponsesTxtLogFile);

TotalExperimentTime = GetSecs-Cfg.Experiment_start

%% Save mat log files
save(fullfile('logfiles',[subjectName,'_run_',num2str((runNumber)),'_all.mat']))

clear Screen;

