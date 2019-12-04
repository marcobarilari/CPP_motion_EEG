% function generateAudio(EventDuration)


fileName = 'Y_BF_60_sec.wav';

%device = 'EEG'
device = 'PC'

CurrentDir = pwd;

% load the pink noise static template


if strcmp(device,'EEG')
    openparallelport_inpout32(hex2dec('d010'))
    [Y, FS] = wavread(fullfile(CurrentDir,'Audio',fileName));
else
    [Y, FS] = audioread(fullfile(CurrentDir,'Audio',fileName));
end
FS
%% Square wave and Silence
silenceTime = 10; 
f = 10; 
t = [0:1/FS:1-1/FS]; %1 second, length 44100
sqwave = [square(2*pi*f*t)]'; sqwave = repmat(sqwave,1,2);
silence = zeros(silenceTime*FS,1); silence = repmat(silence,1,2);

%% Combine square wave + silence + audio
sToPlay = [sqwave;silence;Y]';

timePoints = 1:size(sToPlay,2);
plot(timePoints./FS,sToPlay')

%PsychPortAudio('FillBuffer', pahandle, [sToPlay'; sToPlay']);

%RequestLatency = 1;
masterVolume = 0.2;  % amplification factor

%% pahandle
InitializePsychSound(1)
%pahandle = PsychPortAudio('Open',[],[],RequestLatency,FS,2);
pahandle = PsychPortAudio('Open',[],[],[],FS,2);
PsychPortAudio('Volume', pahandle,masterVolume)
% Fill Buffer
PsychPortAudio('FillBuffer', pahandle, sToPlay);

ExperimentStart = GetSecs();
    if strcmp(device,'EEG') 
        b = 200; % start trigger
        sendparallelbyte(b);   
    end
    
    playTime = PsychPortAudio('Start',pahandle,[],[],1) ;

    WaitSecs(length(sToPlay)/FS);

     if strcmp(device,'EEG') 
       sendparallelbyte(0);
       b=100;
       sendparallelbyte(b);  % end trigger
       sendparallelbyte(0);   
     end
    
PracticalDuration = GetSecs()-ExperimentStart ;
fprintf('practical AudioDuration: %.2f sec \n\n',PracticalDuration)

% Stop the audio
PsychPortAudio('Stop',pahandle);
% Close PsychPort Audio
PsychPortAudio('Close',pahandle);

