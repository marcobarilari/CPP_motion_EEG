
function [directions,speeds,modalities,EventDuration] = SS_Mot_ExpDesign(Cfg)


% if Trial set the trial Cfg
if nargin<1 %nargin = number of input arguments to an INLINE object or function.
    Cfg = trial_Cfg(); 
    fprintf('\n\n###################################\n')
    fprintf('This is a trial experiment design\n')
    fprintf('###################################\n\n')
end



Freq = Cfg.BaseFreq 
EventDuration = 1/Freq

speedEvent = Cfg.speedEvent;
numRepetitions = Cfg.numRepetitions 

%numRepetitions = 4;
%%Freq = 5; 

directions = repmat(0,(Freq*numRepetitions) ,1)
numEvents = length(directions);

%directions([Freq:Freq*2:length(directions)])=0 ;
%directions([Freq*2:Freq*2:length(directions)])=180 ;


speeds=ones(numEvents,1)* speedEvent ;       % a matrix of speed values for each event 


if strcmp(Cfg.possibleModalities,'visual')
    modalities = repmat({'visual'},numEvents,1)
elseif strcmp(Cfg.possibleModalities,'auditory')
    modalities = repmat({'auditory'},numEvents,1)
elseif strcmp(Cfg.possibleModalities,'CrossMod_Vis')
    modalities = repmat({'visual'},numEvents,1);
    modalities([Freq:Freq:length(modalities)])= {'auditory'} ; 
elseif strcmp(Cfg.possibleModalities,'CrossMod_Aud')
    modalities = repmat({'auditory'},numEvents,1);
    modalities([Freq:Freq:length(modalities)])= {'visual'};
end

end

%% Trial Cfg 
% Setting a trial Cfg for testing purposes only
function Cfg = trial_Cfg()
Cfg.BaseFreq = 5;
Cfg.speedEvent = 6 ;
Cfg.numRepetitions =2;
Cfg.possibleModalities = {'CrossMod_Vis'};
end