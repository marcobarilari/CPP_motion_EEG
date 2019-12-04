function generateAudio(EventDuration)

CurrentDir = pwd;

cd('Audio')
% Events
EventDuration = .2 ;
BaseFreq = 5; 

% Total audio
FinalAudioDuration = 60;  

% do the plots of the RMS audio files
plotAudioFigs = 1; 
DoEquateRMS = 1;

% load the pink noise static template
[Y, FS] = audioread('PinkNoise.wav');
FS
% Get the number of sampling points & trim the audio to desired duration
NrPoints = FS * EventDuration;
Y = Y(1:NrPoints,:) ; 

%% Linear ramp at onset & ofset to avoid burst effects
% if LengthRamp>0
% TimePoints2Change = LengthRamp*FS;
% 
% % Initial ascending ramp
% Y([1:TimePoints2Change] ,:) = Y([1:TimePoints2Change] ,:) .* [(1/TimePoints2Change) :(1/TimePoints2Change) :1]';
% % End descending ramp
% Y([end-TimePoints2Change+1:end] ,:) = Y([end-TimePoints2Change+1:end] ,:) .* [fliplr((1/TimePoints2Change) :(1/TimePoints2Change) :1)]';
% end
%%  Generate Right and left motion by changing the ILV using a linear function
% the audio channels are multiplied by a linear line between 0 and 1

% Leftward motion (ascending left channel and descending rightward channel)
Y_L = [Y(:,1) .* [1/size(Y,1):1/size(Y,1):1]' , ...
       Y(:,2) .* fliplr([1/size(Y,1):1/size(Y,1):1])' ] ; 

% rightward motion: Reverse the channels of the leftward motion
Y_R = [Y_L(:,2), Y_L(:,1)] ;

% Static is the same as the original
Y_S = [Y] ; 

% Save the wav files
audiowrite(['Audio_R_',num2str(EventDuration),'.wav'],Y_R,FS);
audiowrite(['Audio_L_',num2str(EventDuration),'.wav'],Y_L,FS);
audiowrite(['Audio_S_',num2str(EventDuration),'.wav'],Y_S,FS);

%% Equate the Root mean squares (RMS)

if DoEquateRMS
    
    % Take the reference as the rightward motion
    reference_wav_fn = ['Audio_R_',num2str(EventDuration),'.wav'];
    target_wav1_fn   = ['Audio_S_',num2str(EventDuration),'.wav'];
    target_wav2_fn   = ['Audio_L_',num2str(EventDuration),'.wav'];
    
    % equate the rms using the function 
    equate_rms (reference_wav_fn,target_wav1_fn)
    equate_rms (reference_wav_fn,target_wav2_fn)
    equate_rms (reference_wav_fn,reference_wav_fn)
    
    % Plot the wav files for visualization
    if plotAudioFigs
        
        % load the equated RMS files
        [rms_Y_S ] = audioread(['rms_Audio_S_',num2str(EventDuration),'.wav']);
        [rms_Y_R ] = audioread(['rms_Audio_R_',num2str(EventDuration),'.wav']);
        [rms_Y_L ] = audioread(['rms_Audio_L_',num2str(EventDuration),'.wav']);
        
        % figures
        figure
        subplot(2,3,1); plot(Y); title('Static') ;ylim([-1 1])
        subplot(2,3,2); plot(Y_R); title('Right');ylim([-1 1])
        subplot(2,3,3); plot(Y_L); title('Left');ylim([-1 1])
        
        subplot(2,3,4); plot(rms_Y_S); title('rms Static');ylim([-1 1])
        subplot(2,3,5); plot(rms_Y_R); title('rms Right');ylim([-1 1])
        subplot(2,3,6); plot(rms_Y_L); title('rms Left');ylim([-1 1])
        
    end
end


%% 
%FinalAudioDuration = 20;
%BaseFreq = 5; 
% For each Channel, create the static events 
% Number of Trials = Base frequncy x num Seconds 
X1= repmat(rms_Y_S(:,1),1,BaseFreq*FinalAudioDuration);
X2= repmat(rms_Y_S(:,1),1,BaseFreq*FinalAudioDuration);

X1(:,BaseFreq*2:BaseFreq*2:end)= repmat(rms_Y_L(:,1),1,FinalAudioDuration/2);
X2(:,BaseFreq*2:BaseFreq*2:end)= repmat(rms_Y_L(:,2),1,FinalAudioDuration/2);

X1(:,BaseFreq:BaseFreq*2:end)= repmat(rms_Y_R(:,1),1,FinalAudioDuration/2);
X2(:,BaseFreq:BaseFreq*2:end)= repmat(rms_Y_R(:,2),1,FinalAudioDuration/2);

Y = [X1(:), X2(:)];

SinWave = makeSinWave(FS,(EventDuration*BaseFreq*FinalAudioDuration),BaseFreq,0.5);

Y = Y .* [SinWave' , SinWave']; 
audiowrite(['Y_BF_',num2str(FinalAudioDuration),'_sec.wav'],Y,FS)

cd(CurrentDir)

end



function equate_rms (reference_wav_fn,target_wav_fn)
%% This Script takes a file (target_wav_fn) and equates its rms with
% another reference audio file (reference_wav_fn) amd gives the equated 
% wav file as an output ('final_wave.wav')

%reference_wav_fn = 'R_L.wav';
%target_wav_fn = 'L_R.wav';

% Get the rms of the original sound
[reference_wav , FS_reference]= audioread(reference_wav_fn); 
rms_reference = rms(reference_wav) ;
disp('rms of the reference wav file')
disp(rms_reference)

% Get the rms for the edited combined sound (static)
[target_wav, FS_target] = audioread(target_wav_fn); 
rms_target = rms(target_wav) ;
disp('rms of the target wav file')
disp(rms_target)


% correct for the rms differences in each channel
final_wave = [ target_wav(:,1)*(rms_reference(1)/rms_target(1)) ...
               target_wav(:,2)*(rms_reference(2)/rms_target(2))] ;
           
% check that the rms of the final is similar to the original           
rms_final = rms(final_wave);
disp('rms of the final wav file')
disp(rms_final)
%wavwrite(new_wave,'new_wave.wav')
%audiowrite(target_wav_fn,final_wave,FS_reference)
%wavwrite(final_wave,FS_reference,16,['rms_',target_wav_fn])
audiowrite(['rms_',target_wav_fn],final_wave,FS_reference)
%% plot the reference wav and final wav files
% figure()
% subplot(2,1,1)
% plot(reference_wav(:,1),'r')
% hold on 
% plot(reference_wav(:,2),'b')
% title('Reference wav file')
% 
% subplot(2,1,2)
% plot(final_wave(:,1),'r')
% hold on 
% plot(final_wave(:,2),'b')
% title('Final wav file')

end


function SinWave = makeSinWave(Fs,duration,Fc,Amplitude)
%% Function creates a sin wave to be multiplied with the audio files to 
% lead to an increase and decrease of the audio at the beginning and the end respectively.
% The function creates a sin wave with the following properties 
%
% Input: 
%       Fs: Sampling frequency of the audio file (eg. 44100)
%       duration: duration in seconds of the total audio file
%       Fc: Frequency of the sin wave (also the base frequency of the audio file)
%       Amplitude: Amplitude of the sin wave 
%
% Output:
%       SinWave: Sin wave that will be multiplied with the audiofile
%
% eg: makeSinWave(44100,1,5,0.5)
 
if nargin<1
    
    Fs = 44100 ;
    duration = 1 ;
    Fc = 5 ;
    Amplitude = 0.5 ;
    
end

VerticalShift = 0.5;     % Vertical shift of the wave
phase =  -pi/2 ;         % Phase shift to move the wave to the right/left

% plot the sin wave for visualization
plotSinWav = 1 ;


 numTimePoints = Fs* duration; % number of time points
 t = 1:numTimePoints;         % create a vector [1 to num of points]
 
 % Compute the sin wave
 SinWave = Amplitude * sin(2*pi*Fc/Fs*t+ phase)+VerticalShift ;
        
 % plot
 if plotSinWav 
     figure()
     t=t/Fs; % This creates the time line, in seconds, for the display.
     plot(t,SinWave);
 end
 
end
