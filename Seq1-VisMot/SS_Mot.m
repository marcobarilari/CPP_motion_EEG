function SS_Mot()
%% script to present either EEG motion FVP or motion ERP


%% TO DO
% fix timing in DoDotMo
%  - time of presentation does not match actual presented time
%  - fix inhomogeneous dot density in direction opposite of motion 
%  - express lifetime of dots on seconds and not in number of killed by frame
%  - add possibility to add actual response collection

% for FVP
%  - make target stim not directly linked to base frequency

% for ERP
%  - add ISI
%  - include triggers in response

%% 
clc
clear
cleanUp


%% Setting
Cfg.debug = true;

% 1 will skip sync tests, 0 otherwise
SkipSyncTest = 1 ;


%% Experimental Design
[Cfg, directions, speeds, EventDuration] = SS_Mot_ExpDesign(Cfg);
numEvents = length(directions);


%%  Get Subject Name and run number
if Cfg.debug
    subjName = [];
    runNumber = [];
else
    subjName = input('Enter Subject Name: ','s');
    runNumber = input('Enter the run Number: ','s');
end

if isempty(subjName)
    subjName = 'trial';
end
if isempty(runNumber)
    runNumber = '1';
end


%% logfiles
DateFormat = 'yyyy_mm_dd_HH_MM';

Filename = fullfile(pwd, 'logfiles', ...
    ['sub-' subjName, ...
    '_run-' num2str((runNumber)), ...
    '_task-' Cfg.task, ...
    '_seq-' num2str(Cfg.sequence), ...
    '_events', ...
    datestr(now, DateFormat)]);

[~, ~, ~] = mkdir('logfiles');

EventTxtLogFile = fopen([Filename '.tsv'], 'w');

fprintf(EventTxtLogFile, '%s\t%s\t%s\t%s\t%s\n',...
    'EventNumber',...
    'Direction',...
    'Speed',...
    'Onset',...
    'End');


% put everything into a try / catch in case the poop hits the fan
try
    
    
    %% Open Parallel port if EEG
    if strcmp(Cfg.device, 'EEG')
        openparallelport_inpout32(hex2dec('d010'))
    end
    
    
    %%  Initialize
    
    if Cfg.debug
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
    Cfg.d_ppd = floor(Cfg.apD * Cfg.ppd);                  % Convert the aperture diameter to pixels
    Cfg.dotSize = floor (Cfg.ppd * Cfg.dotSize);           % Convert the dot Size to pixels
    Cfg.ndots = min(Cfg.maxDotsPerFrame, ceil( Cfg.d_ppd .* Cfg.d_ppd  / Cfg.monRefresh));
    speeds = speeds * Cfg.ppd; % Convert the dot speed to pixels
    
    
    %% Fixation Cross
    xCoords = [-Cfg.fixCrossDimPix Cfg.fixCrossDimPix 0 0] + Cfg.xDisplacementFixCross;
    yCoords = [0 0 -Cfg.fixCrossDimPix Cfg.fixCrossDimPix] + Cfg.yDisplacementFixCross;
    Cfg.allCoords = [xCoords; yCoords];
    
    
    %% Empty vectors and matrices for speed
    eventOnsets    = zeros(numEvents,1);
    eventEnds      = zeros(numEvents,1);
    
    
    %% Experiment Start
    
    HideCursor;
    
    Screen('DrawLines', Cfg.win, Cfg.allCoords, Cfg.lineWidthPix, Cfg.fixationCross_color , [Cfg.center(1) Cfg.center(2)], 1);
    
    Screen('Flip',Cfg.win);
    
    WaitSecs(Cfg.onsetDelay);
    
    Cfg.Experiment_start = GetSecs;
    
    if strcmp(Cfg.device,'EEG')
        sendparallelbyte(Cfg.trigger.start);
        sendparallelbyte(0);
    end
    
    
    % For each event
    for iEvent = 1:numEvents
        
        iEventDirection = directions(iEvent,1);    % Direction of that event
        iEventSpeed = speeds(iEvent,1);            % Speed of that event
        iEventDuration = EventDuration(iEvent,1);           % Duration of events
        
        % Event Onset
        eventOnsets(iEvent,1) = GetSecs-Cfg.Experiment_start;
        
        %% RUN DO DOTS
        
        [QUIT, responseTime] = DoDotMo( Cfg, iEventDirection, iEventSpeed, iEventDuration );
        
        if strcmp(Cfg.device, 'EEG')
            sendparallelbyte(0);
        end
        
        if QUIT
            
            if strcmp(Cfg.device, 'EEG')
                sendparallelbyte(Cfg.trigger.abort);
                sendparallelbyte(0);
            end
            
            cleanUp
            
            disp(' ');
            disp('Experiment aborted by user!');
            disp(' ');
            
            return
        end
        
        
        %% ISI
        WaitSecs(Cfg.ISI);
        
        
        %% Event txt_Logfile
        
        eventEnds(iEvent,1) = GetSecs-Cfg.Experiment_start;
        
        fprintf(EventTxtLogFile,'%f\t%f\t%f\t%f\t%f\n',...
            iEvent,...
            iEventDirection,...
            iEventSpeed,...
            eventOnsets(iEvent,1),...
            eventEnds(iEvent,1));
        
        
        
        
        
        % collect responses
        
        
        
        
    end
    
    if strcmp(Cfg.device, 'EEG')
        sendparallelbyte(Cfg.trigger.end);
        sendparallelbyte(0);
    end
    
    % write to log file and log files
    fclose(EventTxtLogFile);
    
    TotalExperimentTime = GetSecs-Cfg.Experiment_start;
    
    fprintf('\n\n This experiment lasted %04.0f seconds. \n\n', TotalExperimentTime)
    
    
    %% Save mat log files
    if IsOctave
        save([Filename '.mat'], '-mat7-binary');
    else
        save([Filename '.mat'], '-v7.3');
    end
    
    cleanUp
    
    
catch
    cleanUp
    psychrethrow(psychlasterror);
end


end

function cleanUp
Priority(0);
ShowCursor
sca
clear Screen % remove PsychDebugWindowConfiguration
end



