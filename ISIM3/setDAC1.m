function voltage = setDAC1(DACvalue)
    arguments 
        DACvalue    {mustBeInteger, mustBeInRange(DACvalue,0,4095)}
    end
    global DAC1;
    DAC1 = DACvalue;
    voltage = DACbinToVolt(DAC1);
end