function [Cfg, directions, speeds, EventDuration] = SS_Mot_ExpDesign(Cfg)

if Cfg.debug
    % number of event per condition
    Cfg.numRepetitions = 20;
    Cfg.BaseFreq = 3;
    Cfg.speed = .00001; % event speed in visual angle per second
else
    % number of event per condition
    Cfg.numRepetitions = 60;
    Cfg.BaseFreq = 8;
    Cfg.speed = .00001; % event speed in visual angle per second
end

Cfg.task = 'motionFVP';
Cfg.sequence = 1;


%% Parameters for monitor setting
Cfg.mon_horizontal_cm = 30; % Width of the monitor in cm
Cfg.view_dist_cm = 20; % Distance from viewing screen in cm
Cfg.apD = 40; % diameter/length of side of aperture in Visual angles


%% Dots param
% Maximum number dots per frame
Cfg.maxDotsPerFrame = 300;                                                  
Cfg.dontclear = 0;
Cfg.dotSize = .7;


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
Cfg.onsetDelay = 2;


Cfg.ISI = 0.075;




%% Trigger EEG
% set to EEG to use triggers
Cfg.device = 'PC'; %EEG
Cfg.trigger.abort = 10;
Cfg.trigger.start = 1;
Cfg.trigger.end = 5;


%% if Trial set the trial Cfg
if nargin<1 %nargin = number of input arguments to an INLINE object or function.
    Cfg = trial_Cfg(); 
    fprintf('\n\n###################################\n')
    fprintf('This is a trial experiment design\n')
    fprintf('###################################\n\n')
end

Freq = Cfg.BaseFreq; 
EventDuration = 1/Freq;

directions = repmat(-1, (Freq * Cfg.numRepetitions), 1);
directions([ Freq:Freq*2:length(directions) ]) = 0 ; %#ok<*NBRAK>
directions([ Freq*2:Freq*2:length(directions) ]) =180 ;

% a matrix of speed values for each event
speeds = ones(length(directions),1) * Cfg.speed ; 

% a matrix of speed values for each event
EventDuration = ones(length(directions),1) * EventDuration ; 

more off

end

%% Trial Cfg 
% Setting a trial Cfg for testing purposes only
function Cfg = trial_Cfg()
Cfg.BaseFreq = 2; % hz
Cfg.speedEvent = 6 ;
Cfg.numRepetitions = 2;
end