function QUIT = DoDotMo(Cfg, directions, dotSpeed, duration)
%DODOTMO This function draws a specific type of dots

w = Cfg.win;

% Show for how many frames
blank_frames = 4;
FrameInMovie = floor(duration/Cfg.ifi) - blank_frames;





FrameInMovie = 200;
FractionToResamp = 5*10^-4; % per frame






% dot stuff
ndots = Cfg.ndots;

if directions < 0
    dotSpeed = 0;
end

% dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
dxdy = repmat(dotSpeed * Cfg.ppd / Cfg.monRefresh ...
    * [cos(pi*directions/180.0) -sin(pi*directions/180.0)], ndots, 1);

% ARRAYS, INDICES for loop
dotPosition = rand(ndots, 2); % array of dot positions raw [xposition, yposition]


FrameLeft = FrameInMovie;

while FrameLeft > 0
    
    [QUIT] = getBehResp(Cfg);

    % Convert to stuff we can actually plot
    this_x(:,1:2) = Cfg.d_ppd(1) * dotPosition;
    
    % This assumes that zero is at the top left, but we want it to be in the
    % center, so shift the dots up and left, which just means adding half of
    % the aperture size to both the x and y direction.
    dot_show = (this_x - Cfg.d_ppd/2)';
    
    % NaN out-of-circle dots
    xyDis = dot_show;
    outCircle = sqrt(xyDis(1,:).^2 + xyDis(2,:).^2) + Cfg.dotSize/2 > (Cfg.d_ppd/2);
    dots2Display = dot_show;
    dots2Display(:,outCircle) = NaN;
    
    %% Now do next drawing commands
    % Draw the fixation
    Screen('DrawLines', w, Cfg.allCoords, Cfg.lineWidthPix, Cfg.fixationCross_color, [Cfg.center(1) Cfg.center(2)], 1);
    
    Screen('DrawDots', w, dots2Display, Cfg.dotSize, Cfg.dotColor, Cfg.center,2);
    
    Screen('DrawingFinished', w);
    
    Screen('Flip', w, 0);
    
    %% update dot position, frame left to play and resample dots
    dotPosition = dotPosition + dxdy;
    
    resample = any([rand(ndots,1)<FractionToResamp outCircle'], 2);
    
    
    
    % improve to increase reseeding in direction opposite of motion to
    % avoid imbalance
    dotPosition(resample, :) = rand(sum(resample),2);
    
    
    
   
    FrameLeft = FrameLeft - 1;
    
end

% Draw the fixation cross
Screen('DrawLines', w, Cfg.allCoords, Cfg.lineWidthPix, Cfg.fixationCross_color, [Cfg.center(1) Cfg.center(2)], 1);

Screen('Flip', w, 0);

WaitSecs(Cfg.ifi*blank_frames);

end


function [QUIT] = getBehResp(Cfg)

[Keypr, ~, Key] = KbCheck;

QUIT = false;

if Keypr && Key(Cfg.KeyCodes.Escape)
    QUIT= true;
end

end

