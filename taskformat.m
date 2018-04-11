

function taskformat(inits) 
clear global;
global vars; global task; global data; global go; global step; global InitPL;

try
%Initialize all variables
% Set up Psychtoolbox 
% Set up Eyelink
%set up keys for task
go = 0;
step=task.nextstep_initFix;
disp('Right Arrow to start');
gokey=KbName('RightArrow');
nokey=KbName('ESCAPE');
while(go == 0)
    [~,~,keyCode] = KbCheck;
    if keyCode(gokey)
        go = 1;
        NewStrobe(0); %strobe: start experiment
    elseif keyCode(nokey)
        go = -1;
        NewStrobe(0); %strobe: experiment escaped           
    end
end
home
% task flow
while(go==1)
    switch step
        case 1
            firstStep();
        case 2
            secondStep(); 
        case 3 
            thirdStep();
    end
    go = keyCapture;
end
catch
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    psychrethrow(psychlasterror); % output the error message that describes the error
end
sca;
Priority(0); %no clue what this does but || code had it so -PM
end

function firstStep()
end

function secondStep()
end

function thirdStep()
end