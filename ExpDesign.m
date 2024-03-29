function [Cfg, directions, speeds, duration, ISI] = ExpDesign(Cfg)

Cfg.speed = .00001; % event speed in visual angle per second

switch Cfg.task
    
    case 'motionFVP'
        Cfg.numTrials = 20*4;
        Cfg.FixISI = 0.05; % fixed part of the ISI
        Cfg.MaxRandISI = 0; % random part of the ISI (uniform distribution)
        if mod(str2double(Cfg.runNumber), 2)==0
            Cfg.sequence = 'R'; % sequence where the RIGHT direction is tagged
        else
            Cfg.sequence = 'L'; % sequence where the LEFT direction is tagged
        end
        Cfg.EventDuration = 120/0 * 0.016; % in seconds --> 12 Hz
        Cfg.BaseFreq = 8;
        
        
        
        
        %         Cfg.EventDuration = 1/Cfg.BaseFreq;
        
        
        
        
    case 'motionERP'
        Cfg.numTrials = 120;
        Cfg.FixISI = 1;
        Cfg.MaxRandISI = 1;
        Cfg.sequence = '0';
        Cfg.EventDuration = 1200 * 0.016; % in seconds
        Cfg.percTarget = 10;
        Cfg.speedTarget = Cfg.speed * 2;
        
        
        
        %         Cfg.EventDuration = 1;
        
        
        
end

if Cfg.debug
    switch Cfg.task
        case 'motionFVP'
            Cfg.numTrials = 5*4;
        case 'motionERP'
            Cfg.numTrials = 20;
    end
end


%% Parameters for monitor setting
Cfg.mon_horizontal_cm = 30; % Width of the monitor in cm
Cfg.view_dist_cm = 20; % Distance from viewing screen in cm
Cfg.apD = 40; % diameter/length of side of aperture in Visual angles


%% Dots param
% Maximum number dots per frame
Cfg.maxDotsPerFrame = 300;
Cfg.dontclear = 0;
Cfg.dotSize = 1;


%% Fixation Cross parameters
% Used Pixels here since it really small and can be adjusted during the experiment
Cfg.fixCrossDimPix = 10;   % Set the length of the lines (in Pixels) of the fixation cross
Cfg.lineWidthPix = 4;      % Set the line width (in Pixels) for our fixation cross
% manual displacement of the fixation cross
Cfg.xDisplacementFixCross = 0 ;
Cfg.yDisplacementFixCross = 0 ;


%% Color Parameters
White = [255 255 255];
Black = [ 0   0   0 ];

Cfg.textColor           = White ;
Cfg.Background_color    = Black ;
Cfg.fixationCross_color = White ;
Cfg.dotColor            = White ;


%% Timing
% number of seconds before the motion stimuli are presented
Cfg.StartDelay = 2;


%% Trigger EEG
% set to EEG to use triggers
Cfg.device = 'PC'; %EEG
Cfg.trigger.abort = 10;
Cfg.trigger.start = 1;
Cfg.trigger.end = 5;
Cfg.trigger.resp = 3;


%% Create sequence

% 0 --> right (0 degrees)
% 1 --> up (90 degrees)
% 2 --> left (180 degrees)
% 3 --> down (270 degrees)
% -1 --> static

switch Cfg.task
    
    case 'motionFVP'
        
        numDirections = Cfg.BaseFreq * Cfg.numTrials;
        
        if mod(numDirections, 4)~=0
            error('Number of trials must be a multiple of 4')
        end
        
        switch Cfg.sequence
            case 'L'
                fillers = repmat([0 1 3], numDirections/4, 1);
                target = 2;
                
            case 'R'
                fillers = repmat([1 2 3], numDirections/4, 1);
                target = 0;
        end
        
        % loop through blocks of 4 directions the last being the target one
        % and the 3 previous being the fillers randomly shuffled
        directions = [];
        for iRepeats = 1:size(fillers, 1)
            directions = [directions fillers(iRepeats, randperm(3)) target]; %#ok<AGROW>
        end
        
        directions = directions';
        
        % a vector of speed values for each event
        speeds = ones(length(directions),1) * Cfg.speed ;
        
        % a vector of duration values for each event
        duration = ones(length(directions),1) * Cfg.EventDuration ;
        
        % a vector of ISI values for each event
        ISI = ones(length(directions),1) * Cfg.FixISI + rand(length(directions), 1) * Cfg.MaxRandISI;
        
    case 'motionERP'
        
        repeats = [...
            repmat(1, 6, 1) ; repmat(2, 3, 1) ; repmat(3, 3, 1); ...
            repmat(4, 6, 1) ; repmat(5, 3, 1) ; repmat(6, 3, 1)];
        
        repeats = repeats(randperm(length(repeats)));
        
        directions = [];
        speeds = [];
        duration = [];
        ISI = [];
        
        for iTrial = 1 : length(repeats)

            switch repeats(iTrial)

                
                
                % this needs refactoring
                
                
                
                
                % Static trials
                case -1
                    directions(end+1,1) = -1;
                    duration(end+1,1) = Cfg.EventDuration;
                    ISI(end+1,1) = Cfg.FixISI + rand(1) * Cfg.MaxRandISI;
                    speeds(end+1,1) = Cfg.speed; %#ok<*AGROW>
                    
                % Right - Left trials
                case 2
                    directions(end+1:end+2,1) = [0 2];
                    duration(end+1:end+2,1) = repmat(Cfg.EventDuration/2, 2, 1);
                    ISI(end+1:end+2,1) = [0 ; Cfg.FixISI + rand(1) * Cfg.MaxRandISI];
                    speeds(end+1:end+2,1) = repmat(Cfg.speed, 2, 1);
                    
                % Left - Right trials
                case 3
                    directions(end+1:end+2,1) = [2 0];
                    duration(end+1:end+2,1) = repmat(Cfg.EventDuration/2, 2, 1);
                    ISI(end+1:end+2,1) = [0 ; Cfg.FixISI + rand(1) * Cfg.MaxRandISI];
                    speeds(end+1:end+2,1) = repmat(Cfg.speed, 2, 1);
                
                % Static target trials
                case 4
                    directions(end+1,1) = -1;
                    duration(end+1,1) = Cfg.EventDuration * 2;
                    ISI(end+1,1) = Cfg.FixISI + rand(1) * Cfg.MaxRandISI;
                    speeds(end+1,1) = Cfg.speed; %#ok<*AGROW>
                
                % Right - Left target trials
                case 5
                    directions(end+1:end+2,1) = [0 2];
                    duration(end+1:end+2,1) = repmat(Cfg.EventDuration, 2, 1);
                    ISI(end+1:end+2,1) = [0 ; Cfg.FixISI + rand(1) * Cfg.MaxRandISI];
                    speeds(end+1:end+2,1) = repmat(Cfg.speed, 2, 1);
                    
                % Left - Right target trials    
                case 6
                    directions(end+1:end+2,1) = [2 0];
                    duration(end+1:end+2,1) = repmat(Cfg.EventDuration, 2, 1);
                    ISI(end+1:end+2,1) = [0 ; Cfg.FixISI + rand(1) * Cfg.MaxRandISI];
                    speeds(end+1:end+2,1) = repmat(Cfg.speed, 2, 1);
                    
                    
                    
                    
                    
                    
                    
            end
        end
        
end

directions(directions==1) = 90;
directions(directions==2) = 180;
directions(directions==3) = 270;



more off

end