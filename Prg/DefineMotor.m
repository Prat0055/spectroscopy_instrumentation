function motor = DefineMotor(port)

    % Defines the constants of the motor connected to port

    motor.slot = 100;               % 100 or 200
    motor.port = port;              % 1, 2, 3, 4
    motor.numsteps = 4;             % number of step
    motor.step = [5, 6, 10, 9];     % Motor step secuence
    motor.current = 0;              % Step current value
    motor.factor = 24;              % Steps per turn
    motor.frequency = 24;           % Steps per second
end