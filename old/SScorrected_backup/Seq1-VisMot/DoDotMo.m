function responseTimeWithinEvent = DoDotMo(Cfg, directions, dotSpeed, duration)
%DODOTMO This function draws a specific type of dots
%   Detailed explanation goes here
%duration = Cfg.eventDuration;
dontclear = Cfg.dontclear;
% Dot stuff    
coh = Cfg.coh;
%speed = Cfg.speed;
%direction = Cfg.direction;    
dotSize = Cfg.dotSize;
dotLifeTime = Cfg.dotLifeTime; 
maxDotsPerFrame = Cfg.maxDotsPerFrame; 
%maxDotsPerFrame = maxDotsPerFrame*3 ;
DoSinWavBrightness = 0;

if directions == -1
    dotSpeed = 0;
    %coh = 0;
    %dotLifeTime= duration;
end

dotColor = Cfg.dotColor ;
%t_duration = Cfg.t_duration ;
%fixationChangeDuration = Cfg.fixationChangeDuration;

responseTimeWithinEvent = [];

w = Cfg.win;


ndots = min(maxDotsPerFrame, ceil( Cfg.d_ppd .* Cfg.d_ppd  / Cfg.monRefresh));

% dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
%   deg/sec * Ap-unit/deg * sec/jump = unit/jump
dxdy = repmat(dotSpeed * 10/(Cfg.apD*10) * (3/Cfg.monRefresh) ...
    * [cos(pi*directions/180.0) -sin(pi*directions/180.0)], ndots,1);

% ARRAYS, INDICES for loop
ss = rand(ndots*3, 2); % array of dot positions raw [xposition, yposition]    

% Divide dots into three sets
Ls = cumsum(ones(ndots,3)) + repmat([0 ndots ndots*2], ndots, 1);
loopi = 1; % Loops through the three sets of dots

% Show for how many frames
continue_show = floor(duration/Cfg.ifi) ;    

dotLifeTime = ceil(dotLifeTime/Cfg.ifi);   % Covert the dot LifeTime from seconds to frames

% Create a ones vector to update to dotlife time of each dot
dotTime = ones(size(Ls,1),2);  


%% Do sin wave brightness
B=ones(1,continue_show);
if DoSinWavBrightness
   Amplitude = 0.5; 
   VerticalShift = 0.5;     % Vertical shift of the wave
   phase =  -pi/2 ;         % Phase shift to move the wave to the right/left

   Fc = Cfg.BaseFreq ; 
   Fs = Cfg.ifi ;
   numTimePoints = continue_show;
   t = 1:numTimePoints;         % create a vector [1 to num of points]
   % Compute the sin wave
    B = Amplitude * sin(2*pi*Fc/Fs*t+ phase)+VerticalShift ; 
end
%% 
movieStartTime= GetSecs();

%moviePtr = Screen('CreateMovie', w, ['Movie_',num2str(directions)])
%Screen('AddFrameToMovie', Cfg.win,Cfg.winRect)

while continue_show && GetSecs<=movieStartTime+duration


    %Counter = Counter + 1 ;

    % Get ss & xs from the big matrices. xs and ss are matrices that have 
    % stuff for dots from the last 2 positions + current.
    Lthis  = Ls(:,1);% Ls picks out the previous set (1:5, 6:10, or 11:15)    Lthis  = Ls(:,loopi); % Lthis picks out the loop from 3 times ago, which 
                          % is what is then moved in the current loop
    this_s = ss(Lthis,:);  % this is a matrix of random #s - starting position
    % Update the loop pointer
    loopi = loopi+1;   
    if loopi == 4
        loopi = 1;
    end
    % Compute new locations
    % L are the dots that will be moved
    L = rand(ndots,1) < coh;                
    this_s(L,:) = this_s(L,:) + dxdy(L,:);	% Offset the selected dots

    if sum(~L) > 0  % if not 100% coherence
        this_s(~L,:) = rand(sum(~L),2);	% get new random locations for the rest                        
    end

    N = sum((this_s > 1 | this_s < 0 | repmat(dotTime(:,1) > dotLifeTime,1,2))')' ~= 0 ;

      %% Re-allocate the dots to random positions
    if sum(N) > 0
        this_s(N,:) = rand(sum(N),2);             % re-allocate the chosen dots to random positions
        dotTime(find(N==1),:) = 1;                % find the dots that were re-allocated and change its lifetime to 1
    end

    %%      
        % add one frame to the dot lifetime to each dot
        dotTime = dotTime + 1; 

        % Convert to stuff we can actually plot
        this_x(:,1:2) = floor(Cfg.d_ppd(1) * this_s); % pix/ApUnit

        % This assumes that zero is at the top left, but we want it to be in the 
        % center, so shift the dots up and left, which just means adding half of 
        % the aperture size to both the x and y direction.
        dot_show = (this_x(:,1:2) - Cfg.d_ppd/2)';

        % Now do next drawing commands
        %Screen('DrawDots', Cfg.win, dot_show, dotSize, dotColor, Cfg.center,2);   %if you want to change location change Cfg.center        
        %Screen('DrawLines', Cfg.win, Cfg.allCoords,Cfg.lineWidthPix, Cfg.fixationCross_color , [Cfg.center(1) Cfg.center(2)], 1);   

            %Screen('DrawLines', w, Cfg.allCoords,Cfg.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);  % Draw the fixation cross
        Screen('DrawLines', w, Cfg.allCoords,Cfg.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);  % Draw the fixation cross
        
        % NaN out-of-circle dots  
        xyDis = dot_show;
        outCircle = sqrt(xyDis(1,:).^2 + xyDis(2,:).^2) + dotSize/2 > (Cfg.d_ppd/2);        
        dots2Display = dot_show;
        dots2Display(:,outCircle) = NaN;
        

        Screen('DrawDots',w,dots2Display,dotSize,dotColor.*B(continue_show),Cfg.center,2);
        
        Screen('DrawingFinished',w,dontclear);       
        Screen('Flip', w,0,dontclear);
        %Screen('AddFrameToMovie', Cfg.win,Cfg.winRect)

        % Update the arrays so xor works next time
        xs(Lthis, :) = this_x;
        ss(Lthis, :) = this_s;
      
       %% Check for end of loop 
        continue_show = continue_show - 1;
        
end


%% Present last dots
Screen('DrawLines', w, Cfg.allCoords,Cfg.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);  % Draw the fixation cross
Screen('Flip', w,0,dontclear);

%Erase last dots
%Screen('DrawLines', w, Cfg.allCoords,Cfg.lineWidthPix, Cfg.fixationCross_color , [Cfg.center(1) Cfg.center(2)], 1);   
%Screen('DrawingFinished',w,dontclear);
%Screen('Flip', w,0,dontclear);
%Screen('AddFrameToMovie', Cfg.win,Cfg.winRect)



