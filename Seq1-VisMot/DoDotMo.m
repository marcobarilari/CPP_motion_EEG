function responseTimeWithinEvent = DoDotMo(Cfg, directions, dotSpeed, duration)
%DODOTMO This function draws a specific type of dots

dontclear = Cfg.dontclear;

w = Cfg.win;


% Show for how many frames
blank_frames = 1;
FrameInMovie = floor(duration/Cfg.ifi) - blank_frames;

FrameInMovie = 1000;

% dot stuff
ndots = Cfg.ndots;

if directions < 0
    dotSpeed = 0;
end

% dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
dxdy = repmat(dotSpeed * Cfg.ppd / Cfg.monRefresh ...
    * [cos(pi*directions/180.0) -sin(pi*directions/180.0)], ndots, 1);

% dxdy = repmat([.0001 0] * Cfg.ppd / Cfg.monRefresh, ndots,1);

% ARRAYS, INDICES for loop
dotPosition = rand(ndots, 2); % array of dot positions raw [xposition, yposition]

% Create a ones vector to update to dotlife time of each dot
% dotTime = ones(size(dotPosition,1),2);


%%
responseTimeWithinEvent = [];

FrameLeft = FrameInMovie

while FrameLeft > 0

%     Lthis  = Ls(:, 1)
%     this_s = dotPosition;
% 
%     % Compute new locations
%     % L are the dots that will be moved
%     L = rand(ndots,1) < Cfg.coh;
%     this_s(L,:) = this_s(L,:) + dxdy(L,:);	% Offset the selected dots
    
%     if sum(~L) > 0  % if not 100% coherence
%         this_s(~L,:) = rand(sum(~L),2);	% get new random locations for the rest
%     end
    
%     N = sum((this_s > 1 || this_s < 0 || repmat(dotTime(:,1) > Cfg.dotLifeTimeFrame,1,2))')' ~= 0 ;
%     
%     %% Re-allocate the dots to random positions
%     if sum(N) > 0
%         this_s(N,:) = rand(sum(N),2);             % re-allocate the chosen dots to random positions
%         dotTime(find(N==1),:) = 1;                % find the dots that were re-allocated and change its lifetime to 1
%     end
    
    %%
    % add one frame to the dot lifetime to each dot
%     dotTime = dotTime + 1;
    
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
    
    % Now do next drawing commands
    % Draw the fixation 
    Screen('DrawLines', w, Cfg.allCoords, Cfg.lineWidthPix, Cfg.fixationCross_color, [Cfg.center(1) Cfg.center(2)], 1);
    
    Screen('DrawDots', w, dots2Display, Cfg.dotSize, Cfg.dotColor, Cfg.center,2);
    
    Screen('DrawingFinished', w);
    
    Screen('Flip', w, 0);
    
    
    dotPosition = dotPosition + dxdy;    
    
    %% Check for end of loop
    FrameLeft = FrameLeft - 1;
    
end


%% Present last dots
% Draw the fixation cross
Screen('DrawLines', w, Cfg.allCoords, Cfg.lineWidthPix, Cfg.fixationCross_color, [Cfg.center(1) Cfg.center(2)], 1); 

Screen('Flip', w, 0, dontclear);

WaitSecs(Cfg.ifi*blank_frames);


