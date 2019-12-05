function SS_Mot()
%% experience eye tracking and auditory motion

clc
clear
% cleanUp


%% Setting
% 1 will skip sync tests, 0 otherwise
SkipSyncTest = 1 ; 

debug = true;

% set to EEG to use triggers
device = 'F'; %EEG





% event speed
Cfg.speed = .00001; % in visual angle per second






% number of event per condition
Cfg.numRepetitions = 60; 
Cfg.BaseFreq = 4;

onsetDelay = 2; % number of seconds before the motion stimuli are presented

% manual displacement of the fixation cross
xDisplacementFixCross = 0 ;
yDisplacementFixCross = 0 ;


%% Experimental Design
[Cfg, directions, speeds, EventDuration] = SS_Mot_ExpDesign(Cfg);
numEvents = length(directions);


%%  Get Subject Name and run number
if debug
    subjName = [];
    runNumber = [];
else
    subjName = input('Enter Subject Name: ','s'); %#ok<UNRCH>
    runNumber = input('Enter the run Number: ','s');
end

if isempty(subjName)
    subjName = 'trial';
end
if isempty(runNumber)
    runNumber = '1';
end

DateFormat = 'yyyy_mm_dd_HH_MM';

Filename = fullfile(pwd, 'output', ...
    ['sub-' subjName, ...
    '_run_' num2str((runNumber)), ...
    '_task_motionFVP_events', ...
    datestr(now, DateFormat)]);


% put everything into a try / catch in case the poop hits the fan
try
    
    %% Open Parallel port if EEG
    if strcmp(device,'EEG')
        openparallelport_inpout32(hex2dec('d010'))
    end
    
    %%  Initialize
    
    if debug
        PsychDebugWindowConfiguration
    end
    
    AssertOpenGL;
    
    Cfg.KeyCodes = setupKeyCodes;
    
    Screen('Preference','SkipSyncTests', SkipSyncTest);
    
    % Select screen with maximum id for output window:
    screenid = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    [Cfg.win, Cfg.winRect] = PsychImaging('OpenWindow', screenid, Cfg.Background_color);
    Cfg.center = [Cfg.winRect(3), Cfg.winRect(4)]/2; %  Get the Center of the Screen
    
    % Enable alpha-blending, set it to a blend equation useable for linear superposition with
    % alpha-weighted source.
    Screen('BlendFunction', Cfg.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    

    %% Screen details
    % Query frame duration
    Cfg.ifi = Screen('GetFlipInterval', Cfg.win);
    
    Cfg.monRefresh =  1/Cfg.ifi;

    % % Everything is initially in coordinates of visual degrees, convert to pixels
    % (pix/screen) * (screen/rad) * rad/deg
    V = 2 * (180 * (atan(Cfg.mon_horizontal_cm/(2*Cfg.view_dist_cm)) / pi));
    Cfg.ppd = Cfg.winRect(3) / V ;
    
    % Select specific text font, style and size:
    Screen('TextFont',Cfg.win, 'Courier New');
    Screen('TextSize',Cfg.win, 18);
    Screen('TextStyle', Cfg.win, 1);
    
    
    %% Dots
    Cfg.dotLifeTimeFrame = ceil(Cfg.dotLifeTime/Cfg.ifi);
    Cfg.d_ppd = floor(Cfg.apD * Cfg.ppd);                  % Convert the aperture diameter to pixels
    Cfg.dotSize = floor (Cfg.ppd * Cfg.dotSize);           % Convert the dot Size to pixels
    Cfg.ndots = min(Cfg.maxDotsPerFrame, ceil( Cfg.d_ppd .* Cfg.d_ppd  / Cfg.monRefresh)); 
    speeds = speeds * Cfg.ppd; % Convert the dot speed to pixels
    
    %% Fixation Cross
    xCoords = [-Cfg.fixCrossDimPix Cfg.fixCrossDimPix 0 0] + xDisplacementFixCross;
    yCoords = [0 0 -Cfg.fixCrossDimPix Cfg.fixCrossDimPix] + yDisplacementFixCross;
    Cfg.allCoords = [xCoords; yCoords];
    
    
    %% Empty vectors and matrices for speed
    eventNames     = cell(numEvents,1);
    eventOnsets    = zeros(numEvents,1);
    eventEnds      = zeros(numEvents,1);
    eventDurations = zeros(numEvents,1);
    

    %% txt logfiles
    [~, ~, ~] = mkdir('logfiles');

    
    
    
    
    
    EventTxtLogFile = fopen([Filename '.txt'],'w');
    % fprintf(EventTxtLogFile,'%12s %12s %12s %18s %12s %12s %12s \n',...
    %     'EventNumber','Direction','Speed','Onset','End','Duration');
    
    
    
    
    
    
    HideCursor;
    
    %% Experiment Start
    
    Screen('DrawLines', Cfg.win, Cfg.allCoords, Cfg.lineWidthPix, Cfg.fixationCross_color , [Cfg.center(1) Cfg.center(2)], 1);
    
    Screen('Flip',Cfg.win);
    
    WaitSecs(onsetDelay);
    
    Cfg.Experiment_start = GetSecs;

    % For each event
    for iEvent = 1:numEvents
        
        iEventDirection = directions(iEvent,1);    % Direction of that event
        iEventSpeed = speeds(iEvent,1);            % Speed of that event
        iEventDuration = EventDuration;           % Duration of events
        
        % Event Onset
        eventOnsets(iEvent,1) = GetSecs-Cfg.Experiment_start;
        
        %% RUN DO DOTS
        if strcmp(device,'EEG') && iEvent == 1
            sendparallelbyte(Cfg.trigger.start);
            sendparallelbyte(0);
        end
        
        QUIT = DoDotMo( Cfg, iEventDirection, iEventSpeed, iEventDuration );

        if strcmp(device,'EEG')
            sendparallelbyte(0);
        end
        
        if QUIT
            if strcmp(device,'EEG')
                sendparallelbyte(Cfg.trigger.abort);
                sendparallelbyte(0);
            end
            CleanUp
            disp(' ');
            disp('Experiment aborted by user!');
            disp(' ');
            
            return
        end
        
        
        
        
        
        
        
        
        
        
        
        
        %% Event End and Duration
        eventEnds(iEvent,1) = GetSecs-Cfg.Experiment_start;
        eventDurations(iEvent,1) = eventEnds(iEvent,1) - eventOnsets(iEvent,1);
        
        %% Event txt_Logfile
        %     fprintf(EventTxtLogFile,'%12.0f %12s %12.0f %12.2f %12.5f %12.5f %12.5f \n',...
        %         iEvent,modalities{iEvent},iEventDirection,iEventSpeed,eventOnsets(iEvent,1),eventEnds(iEvent,1),eventDurations(iEvent,1));

        
        
        
        
        
        
        
        
        
        
    end
    
    if strcmp(device,'EEG')
        sendparallelbyte(Cfg.trigger.end);
        sendparallelbyte(0);
    end
    
    % close txt log files
    fclose(EventTxtLogFile);
    
    TotalExperimentTime = GetSecs-Cfg.Experiment_start;
    
    %% Save mat log files
    if IsOctave
        save([Filename' '.mat'], '-mat7-binary');
    else
        save([Filename' '.mat'], '-v7.3');
    end
    
    cleanUp
    
catch
    cleanUp
    psychrethrow(psychlasterror);
end

end

function cleanUp
WaitSecs(0.5);
Priority(0);
ShowCursor
sca
clear Screen % remove PsychDebugWindowConfiguration
end

function KeyCodes = setupKeyCodes
% Setup keycode strusave([Filename' '.mat'])cture for typical keys
KbName('UnifyKeyNames')
KeyCodes.Resp = KbName('space');
KeyCodes.Escape = KbName('ESCAPE');
end

