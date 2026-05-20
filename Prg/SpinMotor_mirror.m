function spin = SpinMotor_mirror(dev, motor, spin)
 global buffer
 buffer = [0 0 0 0];
    pause ("on")
    cte = spin * motor.factor;
    signspin = Sign(cte);
    steps = fix(abs(cte + 0.5 * signspin));
    if motor.port < 3
        slot = motor.slot + 1;
    else
        slot = motor.slot + 2;
    end
    for i = 1:steps
        motor.current = motor.current + signspin;
        if motor.current < 1
            motor.current = motor.current + motor.numsteps;
        end
        if motor.current > motor.numsteps
            motor.current = motor.current - motor.numsteps;
        end
        buffer(motor.port) = motor.step(motor.current);
        
        if mod(motor.port, 2) == 0
            value = buffer(motor.port - 1) + 16 * buffer(motor.port);
        else
            value = buffer(motor.port) + 16 * buffer(motor.port + 1);
        end
    
        coman = strcat(" ,(@", string(slot), ")" );
        coman = strcat("SOUR:DIG:DATA:BYTE ", string(value), coman);
        writeline(dev, coman)
        
        if i < 5
            pause (0.05)
        else
            pause (1/motor.frequency)
        end
    end

    % Locks the motor in the last position
    buffer(motor.port) = 0;
    if mod(motor.port, 2) == 0
        value = buffer(motor.port - 1);
    else
        value = 16 * buffer(motor.port + 1);
    end

    coman = strcat(" ,(@", string(slot), ")" );
    coman = strcat("SOUR:DIG:DATA:BYTE ", string(value), coman);
    writeline(dev, coman)
    
    pause ("off")
    spin = signspin * steps / motor.factor;

end