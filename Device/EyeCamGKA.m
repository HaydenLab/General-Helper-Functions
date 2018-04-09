% Updated 20180409 Cindy Jiaxin Tu
% Originally from Shadowlands
% Change the Screen Number according to rig
function retCode = EyeCamGKA(varargin)
% clear all  This is one step closer to getting EyeCamGKA working without
% running Eyecalibration first..  causes crash at line 17 and 40
% This is largely based on PsychEyelinkDispatchCallback.m, but is somewhat
% simplified for our purposes.

persistent scnWin
persistent scnSize
persistent scnCenter
persistent camTex
persistent hasReceivedImage
persistent const

env.screenNumber = 1; % CHANGE ME % 

% N.B.: The persistent variables are similar to global variables, but their
% values are not going to be changed by other functions

if ~nargin || ~isnumeric(varargin{1})
    Screen('Preference', 'VisualDebugLevel', 0);
    Screen('Preference', 'Verbosity', 0); % Hides PTB Warnings
    if ~Eyelink('IsConnected') 
        Eyelink('initialize');
    end % Connects to eyelink computer
    
    % This is a setup call: initialize everything
    scn = env.screenNumber; 
%     scn = 1; % for shadowlands setup -BRE
    [scnWin, scnRect] = Screen('OpenWindow', scn);
    scnSize = scnRect(3:4) - scnRect(1:2);
    scnCenter = scnSize / 2;
    hasReceivedImage = false;
    const = struct( ...
        'GL_RGBA', 6408, ...
        'GL_RGBA8', 32856, ...
        'GL_UNSIGNED_BYTE', 5121, ...
        'GL_UNSIGNED_INT_8_8_8_8', 32821, ...
        'GL_UNSIGNED_INT_8_8_8_8_REV', 33639);
    const.hostDataFormat = const.GL_UNSIGNED_INT_8_8_8_8_REV;
    camTex = [];
    
    fprintf('Press any key to exit camera display.\n');
    
    
    Eyelink('startrecording'); % Turns on the recording of eye position
    Eyelink('Command', 'randomize_calibration_order = NO');
    Eyelink('Command', 'force_manual_accept = YES');
    Eyelink('StartSetup');
    continuing = 1; 
    % Wait until Eyelink actually enters Setup mode:
    while (continuing == 1) && Eyelink('CurrentMode')~=2 % Mode 2 is setup mode
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('ESCAPE'))
            continuing = 0;
        end % ESCAPE aborts
    end
    Eyelink('SendKeyButton',double('c'),0,10); % Mode 10 is calibration mode
    while (continuing == 1) && Eyelink('CurrentMode')~=10
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('ESCAPE'))
            continuing = 0;
        end % ESCAPE aborts
    end
    
    % Open communications with Eyelink, with this as the SetupScreen 
    % callback: to display camera image with PTB
    Eyelink('Initialize', mfilename); 
    % Begin setup routine:
    Eyelink('StartSetup', 1);
    % Disconnect:
    Eyelink('Shutdown');
    Screen('CloseAll');
else
    % This is a callback from Eyelink('SetupScreen'): handle commands
    % accordingly
    retCode = 0;
    
    argList = varargin{1};
    if nargin > 1
        msg = varargin{2};
    end
    cmdCode = argList(1);
    
    newImage = false;
    
    switch cmdCode
        case 1 % Receive image from camera
            newImage = true;
            hasReceivedImage = true;
        case 2 % Eyelink requests keyboard input
            if ~hasReceivedImage
                % Send a magic number corresponding to "Return" to make
                % Eyelink supply us with the camera image:
                retCode = 13;
            else
                % If any key is pressed, send a magic number corresponding
                % to "Escape" to tell Eyelink to stop.
                if KbCheck
                    retCode = 27;
                end
            end
        case 3 % Alert message
            fprintf('Eyelink alert message: %s\n', msg);
        case 4 % Receive image title
            %             fprintf('Image title: %s\n', msg);
        case 8 % Setup image display (We probably don't care)
            
        case 9 % End image display (We probably don't care)
       
    end
    
    if ~newImage
        return;
    end
    
    imgPtr = argList(2);
    imgSize = argList(3:4);
    
    camTex = Screen('SetOpenGLTextureFromMemPointer', scnWin, camTex, ...
        imgPtr, imgSize(1), imgSize(2), 4, 0 , [], ...
        const.GL_RGBA8, const.GL_RGBA, const.hostDataFormat);
    
    if ~isempty(camTex)
        % Blow the image up to full-screen, preserving aspect ratio, and
        % display it:
        sizeScale = min(scnSize ./ imgSize);
        dispSize = sizeScale .* imgSize;
        imgPos = [-dispSize dispSize]./2 + [scnCenter scnCenter];
        
        Screen('DrawTexture', scnWin, camTex, [], imgPos);
    end
    Screen('Flip', scnWin);
end