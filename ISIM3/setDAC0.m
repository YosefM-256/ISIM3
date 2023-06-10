function voltage = setDAC0(DACvalue)
    arguments 
        DACvalue    {mustBeInteger, mustBeInRange(DACvalue,0,4095)}
    end
    global DAC0;
    DAC0 = DACvalue;
    voltage = 2*DACbinToVolt(DAC0);
end