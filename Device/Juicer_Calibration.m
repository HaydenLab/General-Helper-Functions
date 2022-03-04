function Juicer_Calibration
n = 100; % run for 100 times
for i = 1:n
    reward_digital_Juicer1(.3);
    %     reward_digital_Juicer2(2);% for social task double juicers
    home %home moves the cursor to the upper left corner of the window.
    i
    WaitSecs(.5);
end
end
