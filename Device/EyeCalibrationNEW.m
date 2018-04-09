% MAM 20170206  Updated to work on PC using NI USB 6501 DIO card.
%   using reward_digital_JuicerN to drive multiple juicers
% CES MAM TB 2/6/2011

%*** Calibration program for monkey using Eyelink
% ESCAPE stops the calibration
% RIGHT ARROW starts/accepts trial
% ENTER starts/accepts trial AND rewards the monkey
% LEFT ARROW goes to previous trial
% SPACE rewards the monkey
% RIGHT CTRL takes dot off screen

function EyeCalibrationNEW
    clear

% Variables that can/should be changed according to calibration
rewardduration = .18; % Reward duration
flicker = 0; % Dot flickering on (1) or off (0)
hertz = 5; % Hertz of flicker
radius = 12; % Radius of dots
backcolor = [50 50 50]; % Background color
maincolor = [255 255 0]; % Dot color
offcolor = [0 255 0]; % Dot flicker color
feedbackcolor = [128 255 128]; % Feedback dot color
global s
%s = daq.createSession('ni');
%addDigitalChannel(s,'Dev3','Port2/line0:1','OutputOnly');

% Set up Eyelink
KbName('UnifyKeyNames');
% jheapcl; %Clear java heap, because psychtoolbox sucks

Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'Verbosity', 0); % Hides PTB Warnings
window = Screen('OpenWindow', 1, 0);
if ~Eyelink('IsConnected')
    Eyelink('initialize');
end % Connects to eyelink computer

Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, 1920, 1080); %3440 1440        VR

Eyelink('startrecording'); % Turns on the recording of eye position
Eyelink('Command', 'randomize_calibration_order = NO');

% Next two line is significant in controlling auto-trigger in calibrataion.
%   However, does not work before manually changing the eye-link software.
Eyelink('Command', 'auto_trigger = NO');
Eyelink('Command', 'force_manual_accept = YES');
Eyelink('StartSetup');
continuing = 1; % Wait until Eyelink actually enters Setup mode:
while (continuing == 1) && Eyelink('CurrentMode')~=2 % Mode 2 is setup mode
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        continuing = 0;
    end % ESCAPE aborts
end
Eyelink('SendKeyButton',double('c'),0,10); % Mode 10 is calibration mode

while (continuing == 1) && Eyelink('CurrentMode')~=10
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        continuing = 0;
    end % ESCAPE aborts
end

% Ask to start
Screen('FillRect', window, backcolor);
Screen(window,'flip');
go = 0;
disp('Right Arrow to start');
while((go == 0) && (continuing == 1))
    comm = keyCapture();
    if comm == 1
        go = 1;
    elseif comm == -1
        continuing = 0;
    end
end

trial = 1;
if(continuing == 1)
    home
    disp(['Fixation Dot #' num2str(trial)]);
end
time = GetSecs;
flick = 1;
feedback = 0;
between = 0;
while(continuing);
    
    % Set screen
    if(between == 0)
        [dummy, targX, targY] = Eyelink('TargetCheck');
        if(flicker ~= 1 && feedback==0)
            Screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
        elseif(flick == 1 && feedback==0)
            if(GetSecs > (time + (1/hertz)))
                flick = 0;
                Screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                time = GetSecs;
            else
                Screen('FillOval', window, offcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
            end
        elseif(flick == 0 && feedback==0)
            if(GetSecs > (time + (1/hertz)))    
                flick = 1;
                Screen('FillOval', window, offcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                time = GetSecs;
            end
        end
        Screen(window,'flip');
    end
    
    % Watch for keyboard interaction
    comm=keyCapture();
    if(comm==-1) % ESC stops the calibration
        continuing=0;
    elseif(comm==2) % Left arrow key goes to previous trial
        if(trial ~= 1)
            Eyelink('SendKeyButton',8,0,10); % 8 = backspace
            trial = trial - 1;
            home
            disp(['Fixation Dot #' num2str(trial)]);
        else
            Screen(window,'flip');
            between = 1;
        end
    elseif(comm==3) % Space rewards the monkey
        reward_digital_Juicer1(rewardduration);
    elseif(comm==4 || comm==1) % Right arrow accepts trial, ENTER accepts trial and rewards the monkey
        if(between == 0)
            Eyelink('SendKeyButton',13,0,10); % 13 = Return
            Screen('FillOval', window, feedbackcolor, [(targX-15) (targY-15) (targX+15) (targY+15)]);
            Screen(window,'flip');
            fbtime = GetSecs;
            feedback = 1;
            trial = trial + 1;
            home
            disp(['Fixation Dot #' num2str(trial)]);
            if(comm==4)
                reward_digital_Juicer1(rewardduration);
            end
        else
            between = 0;
        end
    elseif(comm==5) % Go back to between trials state
        between = 1;
    end
    
    % Process feedback period
    if(feedback==1 && GetSecs > (fbtime + 0.5))
        feedback = 0;
        between = 1;
        Screen(window,'flip');
    end
    if(flicker == 1 && feedback==0)
        Screen(window,'flip');
    end
end
Eyelink('stoprecording');
Eyelink('Shutdown');

sca;
%release code goes here for NIdaq
end

function r = keyCapture()
[keyIsDown,secs,keyCode] = KbCheck;
if keyCode(KbName('ESCAPE'))
    r = -1;
elseif keyCode(KbName('RightArrow'))
    r = 1;
elseif keyCode(KbName('LeftArrow'))
    r = 2;
elseif keyCode(KbName('space'))
    r = 3;
elseif keyCode(KbName('return'))
    r = 4;
elseif keyCode(KbName('RightControl'))
    r = 5;
else
    r = 0;
end
while keyIsDown, [keyIsDown,secs,keyCode] = KbCheck;
end
end


function reward_digital_Juicer1(rewardDuration)%MAM 20170206
%Changed by MAM 20160707 to use with Sesison-based Interface 
%This function is to be used with the NI USB 6501 card.
%Pin 17/P0.0 (Juicer 1) and 25/GND(ground)
%Pin 18/P0.1 (Juicer 2) and 26/GND(ground)
warning('off','all');
global s;
% rewardDuration = 1;
%%%Move this into the running code so it initializes when you start the
%%%program.  The addline command will also turn on strobing capability.
%%%
 s = daq.createSession('ni');
 addDigitalChannel(s,'Dev3','Port2/line0:1','OutputOnly');

% outputSingleScan(s,[1 0])= juicer1 
% outputSingleScan(s,[0 1])= juicer2
outputSingleScan(s,[1 0]);
tic;
while toc < rewardDuration;
end
outputSingleScan(s,[0 0]);

pause(0.001);


end
