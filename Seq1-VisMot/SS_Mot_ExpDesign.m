function [Cfg, directions, speeds, modalities, EventDuration] = SS_Mot_ExpDesign(Cfg)

Cfg.experimentType = 'Dots';   % Visual modality is in RDKs
Cfg.possibleModalities = {'visual'}; % nombre de possibilites


%% Parameters for monitor setting
Cfg.mon_horizontal_cm = 30; % Width of the monitor in cm
Cfg.view_dist_cm = 20; % Distance from viewing screen in cm
Cfg.apD = 40; % diameter/length of side of aperture in Visual angles


%% Dots param
Cfg.coh = 1;                                      % Coherence Level (0-1)
Cfg.maxDotsPerFrame = 300;                        % Maximum number dots per frame (Number must be divisible by 3)
Cfg.dotLifeTime = 1;                            % Dot life time in seconds
Cfg.dontclear = 0;
Cfg.dotSize = .7;


%% Fixation Cross parameters
% Used Pixels here since it really small and can be adjusted during the experiment
Cfg.fixCrossDimPix = 10;   % Set the length of the lines (in Pixels) of the fixation cross
Cfg.lineWidthPix = 4;      % Set the line width (in Pixels) for our fixation cross


%% Color Parameters
White = [255 255 255]; 
Black = [ 0   0   0 ]; 


Cfg.textColor           = White ; 
Cfg.Background_color    = Black ; 
Cfg.fixationCross_color = White ; 
Cfg.dotColor            = White ; 


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

numEvents = length(directions);

speeds = ones(numEvents,1) * Cfg.speed ;% a matrix of speed values for each event 

more off

end

%% Trial Cfg 
% Setting a trial Cfg for testing purposes only
function Cfg = trial_Cfg()
Cfg.BaseFreq = 2; % hz
Cfg.speedEvent = 6 ;
Cfg.numRepetitions = 2;
end