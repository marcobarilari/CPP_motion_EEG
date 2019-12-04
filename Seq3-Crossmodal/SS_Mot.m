%% experience eye tracking and auditory motion

clc;
clear all;

%device = 'EEG'
device = 'PC'

SkipSyncTest = 1 ; % 1 will skip sync tests for mac issues
% but should be set to 0 afterwards and during testing

% % if you would like to test on a part of the screen, change to 1;
% TestingSmallScreen = 1;


%% Setting
Cfg.experimentType = 'Dots';   % Visual modality is in RDKs
Cfg.possibleModalities = {'CrossMod_Vis'}; % nombre de possibilités

Cfg.numEventsPerCondition            = 1 ; % Since its an event design, every block will have 1 event.
Cfg.speedEvent                       = 6  ; % Vitesse de l'événement
Cfg.numRepetitions                   = 60;%200 ; % Nombre d'événements par condition
Cfg.BaseFreq = 5;
onsetDelay = 2;                         % number of seconds before the motion stimuli are presented
endDelay = 2;                           % number of seconds after the end all the stimuli before ending the run

%% Parameters for monitor setting
monitor_width  	 = 42;                            % Monitor Width in cm
screen_distance  = 134;                           % Distance from the screen in cm
diameter_aperture= 8;                             % diameter/length of side of aperture in Visual angles

%% paramètres des points du stimulus visuel
Cfg.coh = 1;                                      % Coherence Level (0-1)= tous les points vont dans le même sens.
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

%% Color Parameters (définition des couleurs)
White = [255 255 255]; % définition de la couleur avec la fonction [r,g,b]pour [red,green,blue]
Black = [ 0   0   0 ]; % Blanc on a toutes les couleurs intensité max =255, pour le noir aucune couleur intensité =0
Grey  = mean([Black;White]);% le gris est obtenu avec la fonction mean=moyenne du blanc et du noir.

Cfg.textColor           = White ; % Couleur du texte
Cfg.Background_color    = Black  ; % couleur du fond
Cfg.fixationCross_color = White ; % couleur de la croix de fixation
Cfg.dotColor            = White ; % couleur des dots (points)

%%  Get Subject Name and run number
% input('Press Enter','s');
subjectName = input('Enter Subject Name: ','s');
if isempty(subjectName)
    subjectName = 'trial';
end

% Définir le nombre de run
runNumber = input('Enter the run Number: ','s');
if isempty(runNumber)
    runNumber = 'trial';
end
% subjectName = 'SS'
% runNumber = 1

% Check if logfile already exists
% if exist(fullfile('logfiles',[subjectName,'_run_',num2str(runNumber),'.mat']),'file')>0
%     error('This file is already present in your logfiles. Delete the old file or rename your run!!')
% end

HideCursor;

%%  Experiment
AssertOpenGL; % Permet de s'assurer de la compatibilité de la version de psychotoolbox avec la carte graphic library installée sur l'ordinateur.

% any preliminary stuff
%%%%%%%%%%%%%%%%%%%%%%%%%
% Select screen with maximum id for output window:
screenid = max(Screen('Screens'));% création de la variable screenid
PsychImaging('PrepareConfiguration');
Screen('Preference','SkipSyncTests', SkipSyncTest);
[Cfg.win, Cfg.winRect] = PsychImaging('OpenWindow', screenid, Cfg.Background_color);

%%  Get the Center of the Screen
Cfg.center = [Cfg.winRect(3), Cfg.winRect(4)]/2;

%% Fixation Cross
xCoords = [-Cfg.fixCrossDimPix Cfg.fixCrossDimPix 0 0] + xDisplacementFixCross;
yCoords = [0 0 -Cfg.fixCrossDimPix Cfg.fixCrossDimPix] + yDisplacementFixCross;
Cfg.allCoords = [xCoords; yCoords];

%% A propos de l'écran d'ordinateur
% Query frame duration
WaitSecs(1);
Cfg.ifi = Screen('GetFlipInterval', Cfg.win); % permet de savoir la frame rate = The number of frames drawn per second
Cfg.monRefresh = 60; %1/Cfg.ifi;

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
% Enable alpha-blending, set it to a blend equation useable for linear
% superposition with alpha-weighted source.
Screen('BlendFunction', Cfg.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Initially sync us to VBL at start of animation loop.
vbl = Screen('Flip', Cfg.win);

% Text options/
% Select specific text font, style and size:
Screen('TextFont',Cfg.win, 'Courier New');
Screen('TextSize',Cfg.win, 18);
Screen('TextStyle', Cfg.win, 1);



% Loads the audio files from the the folder (Audio/SubjectName)
%[soundData, FS, phandle]=loadAudioFiles(fullfile('Audio',subjectName),subjectName);
fprintf('\n\n')

%% Experimental Design
[directions,speeds,modalities,EventDuration] = SS_Mot_ExpDesign(Cfg);
numEvents = length(directions);

%% Blank Trials  (for RDKs first mock trials)
%%%%%%%%%%%%%%%%%%%%%%
Cfg.Experiment_start = GetSecs;
DoDotMo_blanks( Cfg, 0, Cfg.speedEvent , 1 );
Screen('Flip', Cfg.win,0,Cfg.dontclear);
fprintf('Blank 1 finished \n');
DoDotMo_blanks( Cfg, 180, Cfg.speedEvent , 1 );
Screen('Flip', Cfg.win,0,Cfg.dontclear);
fprintf('Blank 2 finished \n');
DoDotMo_blanks( Cfg, -1, Cfg.speedEvent , 1 );
Screen('Flip', Cfg.win,0,Cfg.dontclear);
fprintf('Blank 3 finished \n');
WaitSecs(0.2);
Cfg.Experiment_start =[];


%% Load Audio
CurrentDir = pwd;
if strcmp(device,'EEG')
    openparallelport_inpout32(hex2dec('d010'))
    [Y, FS] = wavread(fullfile(CurrentDir,'Audio','rms_Audio_R_0.2.wav'));
else
    [Y, FS] = audioread(fullfile(CurrentDir,'Audio','rms_Audio_R_0.2.wav'));
end

%% Request Latency (PsychPortAudio)
% Level 0: Don't care about latency,
% Level 1 (the default) means: Try to get the lowest latency that is possible under
% the constraint of reliable playback, freedom of choice for all parameters and interoperability with other applications.
% Level 2 means: Take full control over the audio device, even if this causes other sound applications to fail or shutdown.
% Level 3 means: As level 2, but request the most aggressive settings for the given device.
% Level 4: Same as 3, but fail if device can't meet the strictest requirements
RequestLatency = 2;
masterVolume = 1;  % amplification factor

InitializePsychSound(1);
%pahandle = PsychPortAudio('Open',[],[],RequestLatency,FS,2);
pahandle = PsychPortAudio('Open',[],[],[],FS,2);
PsychPortAudio('Volume', pahandle,masterVolume)
% Fill Buffer
PsychPortAudio('FillBuffer', pahandle, Y');



%% Empty vectors and matrices for speed
eventNames     = cell(numEvents,1);
eventOnsets    = zeros(numEvents,1);
eventEnds      = zeros(numEvents,1);
eventDurations = zeros(numEvents,1);

allResponses = [] ;

%% Ouvertude d'une fenêtre avec la fonction DrawLines pour la croix
Screen('DrawLines', Cfg.win, Cfg.allCoords,Cfg.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
Screen('Flip',Cfg.win);

%% txt logfiles (enregistrement de fichiers nom du participant et du numéro de run
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
    
    if strcmp(device,'EEG') && iEvent == 1
        b = 200;
        sendparallelbyte(b);
    end
    %% RUN DO DOTS
    if strcmp(modalities{iEvent},'visual')
        DoDotMo( Cfg, iEventDirection, iEventSpeed, iEventDuration);
    elseif strcmp(modalities{iEvent},'auditory')
        PsychPortAudio('Start', pahandle);
        %Screen('DrawLines', Cfg.win, Cfg.allCoords,Cfg.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
        %Screen('Flip',Cfg.win);
        WaitSecs(length(Y)/FS)
    end
    
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
    b=100;
    sendparallelbyte(b);  % end trigger
    sendparallelbyte(0);
end


% End of the run for the BOLD to go down
Screen('Flip', Cfg.win);
WaitSecs(endDelay);

% close txt log files
fclose(EventTxtLogFile);
fclose(ResponsesTxtLogFile);

TotalExperimentTime=GetSecs-Cfg.Experiment_start

%% Save mat log files
save(fullfile('logfiles',[subjectName,'_run_',num2str((runNumber)),'_all.mat']))


clear Screen;
PsychPortAudio('Close',pahandle);


