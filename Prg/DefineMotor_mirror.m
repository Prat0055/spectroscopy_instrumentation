function motor = DefineMotor_mirror(present_state,final_state,port)

    % Defines the constants of the motor connected to port

    motor.slot = 100;               % 100 or 200
    motor.port = port;              % 1, 2, 3, 4
    motor.numsteps = 4;             % number of step
    motor.step = [5, 6, 10, 9];     % Motor step secuence
    motor.current = present_state;              % Step current value
    motor.final=final_state;
    motor.factor = 7;              % Steps per turn
    motor.frequency = 24;           % Steps per second
end