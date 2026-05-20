function dev = OpenDevice(nGPIB)

    % Communicating with instrument num.

    dev = visadev(strcat("GPIB0::", string(nGPIB), "::INSTR"));
    fopen(dev)

    % Ensures correct openning of the device
    data = writeread(dev, '*IDN?');
    disp(data)
end
