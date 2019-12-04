
function [directions, speeds, modalities, EventDuration] = SS_Mot_ExpDesign(Cfg)


% if Trial set the trial Cfg
if nargin<1 %nargin = number of input arguments to an INLINE object or function.
    Cfg = trial_Cfg(); 
    fprintf('\n\n###################################\n')
    fprintf('This is a trial experiment design\n')
    fprintf('###################################\n\n')
end



Freq = Cfg.BaseFreq  %#ok<*NOPRT>
EventDuration = 1/Freq

speedEvent = Cfg.speedEvent;
numRepetitions = Cfg.numRepetitions 

directions = repmat(-1,(Freq*numRepetitions), 1)
numEvents = length(directions);

directions([Freq:Freq*2:length(directions)])=0 ; %#ok<*NBRAK>
directions([Freq*2:Freq*2:length(directions)])=180 ;

speeds=ones(numEvents,1)* speedEvent ;       % a matrix of speed values for each event 

modalities = repmat({'visual'}, numEvents, 1);

end

%% Trial Cfg 
% Setting a trial Cfg for testing purposes only
function Cfg = trial_Cfg()
Cfg.BaseFreq = 2; % hz
Cfg.speedEvent = 6 ;
Cfg.numRepetitions = 2;
Cfg.possibleModalities = {'visual'};
end