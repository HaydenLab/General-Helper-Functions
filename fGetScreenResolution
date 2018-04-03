% Sometimes the Psychltoolbox/Eyelink functions will need the screen resolution
% This function prevents the hard-coding of the resolution, which might cause problems when switching rigs.
% Alternatively the lines can be copied to the code.

function ScreenSize = fGetScreenResolution
% We can do this by calling
screenid = max(Screen('Screens')); % this will automatically capture the secondary display
resolution = Screen(screenid,'resolution');

% resolution is a structure with 4 fields
ScreenSize = [resolution.width,resolution.height]
end
