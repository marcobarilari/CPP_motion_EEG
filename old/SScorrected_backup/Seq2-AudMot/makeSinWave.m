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
 
 
