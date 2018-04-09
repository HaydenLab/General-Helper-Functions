% Updated 20180409 Cindy Jiaxin Tu
% Debug guide:

% 1. Error using reward_digital_Juicer1 (line 20)
% The hardware associated with this session is reserved. If you are using it in another session use the release function to unreserve the hardware. If you
% are using it in an external program exit that program. Then try this operation again.
% # Solution: daq.reset;

% 2. Error using reward_digital_Juicer1 (line 19)
% The device 'Dev3' is unknown. Valid device IDs are 'Dev1'.
% # Solution: Change DeviceID

% Changed by MAM 20160707 to use with Sesison-based Interface 
% This function is to be used with the NI USB 6501 card.
function reward_digital_Juicer1(rewardDuration)%MAM 20170206
%Pin 17/P0.0 (Juicer 1) and 25/GND(ground)
%Pin 18/P0.1 (Juicer 2) and 26/GND(ground)
% warning('off','all');
%% (1) Get the device info if you don't know
daq.getDevices; % will return a device ID
%% (2) Create a new session
s = daq.createSession('ni'); % create a daq session
%% (3) Add device channels
DeviceID = '1'; % CHANGE ME % Sometimes it is 1, will return an error
addDigitalChannel(s,['Dev',DeviceID],'Port2/line0:1','OutputOnly');  % this adds 2 channels to the session 
%  addDigitalChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)

outputSingleScan(s,[1 0]);% aka juicer1 on, juicer 2 off
% outputSingleScan(DATA) outputs DATA, a 1xn array of doubles
% where n is the number of output channels in the session.
% outputSingleScan(s,[1 0])= juicer1 
% outputSingleScan(s,[0 1])= juicer2

tic;
while toc < rewardDuration % time how long the juicer is going to be on for 
end
outputSingleScan(s,[0 0]); % both channels turned off

pause(0.001); % somehow there is a pause?

end


% help daq % provides more info
% In a typical workflow, 
%      (1) Discover hardware devices using daq.getDevices
%      (2) Create a daq Session using daq.createSession
%      (3) Add device channels
%      (4) Add device connections
%      (5) Set session and channel properties
%      (6) Perform on demand operations using inputSingleScan/outputSingleScan
%      (7) Perform clocked operations using startForeground/startBackground